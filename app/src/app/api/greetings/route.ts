// app/src/app/api/greetings/route.ts
// ─────────────────────────────────────────────────────────────
// GET /api/greetings → returns all greetings from PostgreSQL
// ─────────────────────────────────────────────────────────────

import { NextResponse } from "next/server";
import { pool } from "@/lib/db";

export const dynamic = "force-dynamic";
//           ↑ Never cache — always query fresh data

export async function GET() {
  try {
    const result = await pool.query(
      "SELECT id, message FROM greetings ORDER BY id"
    );
    return NextResponse.json(result.rows);
    // → [{ id: 1, message: "Hello..." }, { id: 2, message: "Welcome..." }]
  } catch (error) {
    console.error("Database query failed:", error);
    return NextResponse.json(
      { error: "Failed to fetch greetings" },
      { status: 500 }
    );
  }
}
