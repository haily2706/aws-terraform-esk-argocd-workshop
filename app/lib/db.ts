// app/lib/db.ts
// ─────────────────────────────────────────────────────────────
// PostgreSQL connection pool.
// Uses globalThis to prevent connection leaks during Next.js
// hot reloads in development.
// ─────────────────────────────────────────────────────────────

import { Pool } from "pg";

const globalForDb = globalThis as unknown as {
  pgPool: Pool | undefined;
};

export const pool =
  globalForDb.pgPool ??
  new Pool({
    connectionString: process.env.DATABASE_URL,
    //                ↑ Set via K8s Secret or .env locally
    //                Format: postgresql://user:pass@host:5432/dbname
    max: 10,                    // ← max 10 connections in pool
    idleTimeoutMillis: 30000,   // ← close idle connections after 30s
    connectionTimeoutMillis: 5000,
  });

if (process.env.NODE_ENV !== "production") {
  globalForDb.pgPool = pool;    // ← prevent pool leak in dev hot-reload
}
