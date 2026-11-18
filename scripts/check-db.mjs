import { neon } from "@neondatabase/serverless";
const url = process.env.DATABASE_URL;
if (!url) {
  console.error("DATABASE_URL is missing. Configure it in your private environment.");
  process.exitCode = 1;
} else {
  try {
    const sql = neon(url);
    const result = await sql`select current_database() as name, current_timestamp as checked_at`;
    console.log("Neon connection OK:", result[0].name, result[0].checked_at);
  } catch (err) {
    console.error("Neon connection failed:", err instanceof Error ? err.message : "unknown error");
    process.exitCode = 1;
  }
}
