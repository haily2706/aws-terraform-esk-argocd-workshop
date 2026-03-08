# app/Dockerfile
# ─────────────────────────────────────────────────────────────
# Multi-stage build: ~150MB final image (vs 1GB+ without)
# Works with both Podman and Docker — same Dockerfile format.
# Requires: output: "standalone" in next.config.ts
# ─────────────────────────────────────────────────────────────

# ---- Stage 1: Install dependencies ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
#       ↑ clean install from lockfile (faster, deterministic)

# ---- Stage 2: Build the application ----
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build
#             ↑ produces .next/standalone/ (self-contained server)

# ---- Stage 3: Production image ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Run as non-root user (security best practice)
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy only what's needed to run
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
#                                          ↑ standalone doesn't include static
#                                            assets, so we copy them separately

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
