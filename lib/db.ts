import "server-only";
import { neon } from "@neondatabase/serverless";

/**
 * Server-only pooled Neon SQL client.
 * The integration supplies DATABASE_URL in Vercel.
 * Never import this module from a Client Component.
 */
export function getSql() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL is not configured");
  }
  if (!connectionString.startsWith("postgresql://") && !connectionString.startsWith("postgres://")) {
    throw new Error("DATABASE_URL must be a PostgreSQL connection string");
  }
  return neon(connectionString);
}
