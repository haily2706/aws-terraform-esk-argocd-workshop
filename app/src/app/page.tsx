// app/src/app/page.tsx
// ─────────────────────────────────────────────────────────────
// Fetches greetings from /api/greetings and displays them.
// ─────────────────────────────────────────────────────────────
"use client";

import { useEffect, useState } from "react";

interface Greeting {
  id: number;
  message: string;
}

export default function Home() {
  const [greetings, setGreetings] = useState<Greeting[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/greetings")
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((data) => {
        setGreetings(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  return (
    <main style={{ maxWidth: 600, width: "100%" }}>
      <h1
        style={{
          fontSize: "2rem",
          marginBottom: "0.5rem",
          textAlign: "center",
        }}
      >
        Greetings from Kubernetes
      </h1>
      <p
        style={{
          textAlign: "center",
          color: "#888",
          marginBottom: "2rem",
          fontSize: "0.9rem",
        }}
      >
        Running on EKS with ArgoCD GitOps - Updated ArgoCD Application
      </p>

      {loading && <p style={{ textAlign: "center" }}>Loading...</p>}

      {error && (
        <p style={{ color: "#ff6b6b", textAlign: "center" }}>Error: {error}</p>
      )}

      <ul
        style={{
          listStyle: "none",
          display: "flex",
          flexDirection: "column",
          gap: "1rem",
        }}
      >
        {greetings.map((g) => (
          <li
            key={g.id}
            style={{
              background: "#1a1a2e",
              border: "1px solid #333",
              borderRadius: "8px",
              padding: "1rem 1.5rem",
              fontSize: "1.1rem",
            }}
          >
            {g.message}
          </li>
        ))}
      </ul>

      {!loading && !error && greetings.length === 0 && (
        <p style={{ textAlign: "center", color: "#888" }}>
          No greetings found.
        </p>
      )}
    </main>
  );
}
