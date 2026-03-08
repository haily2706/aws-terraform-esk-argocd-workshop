// app/next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  // ↑ CRITICAL for containerization: produces a self-contained build
  //   Result: .next/standalone/server.js + only needed node_modules
  //   Image size: ~150MB instead of 1GB+
};

export default nextConfig;
