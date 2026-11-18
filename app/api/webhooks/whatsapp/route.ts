import { createHmac, timingSafeEqual } from "node:crypto";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

/** Verification challenge used when registering the Meta webhook. */
export async function GET(request: NextRequest) {
  const mode = request.nextUrl.searchParams.get("hub.mode");
  const token = request.nextUrl.searchParams.get("hub.verify_token");
  const challenge = request.nextUrl.searchParams.get("hub.challenge");
  const expected = process.env.META_VERIFY_TOKEN;
  if (!expected || mode !== "subscribe" || token !== expected || !challenge) {
    return new NextResponse("Forbidden", { status: 403 });
  }
  return new NextResponse(challenge, { status: 200, headers: { "Content-Type": "text/plain" } });
}

/**
 * Authenticates webhook deliveries from Meta. Persistence and message handling
 * must be implemented before activating production traffic.
 */
export async function POST(request: NextRequest) {
  const secret = process.env.META_APP_SECRET;
  if (!secret) return NextResponse.json({ error: "Webhook is not configured" }, { status: 503 });
  const signature = request.headers.get("x-hub-signature-256");
  if (!signature?.startsWith("sha256=")) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  const body = Buffer.from(await request.arrayBuffer());
  const digest = createHmac("sha256", secret).update(body).digest();
  const providedHex = signature.slice(7);
  if (!/^[a-f0-9]{64}$/i.test(providedHex)) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  const provided = Buffer.from(providedHex, "hex");
  if (provided.length !== digest.length || !timingSafeEqual(provided,digest))
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  // Intentionally do not log/store user messages until tenant mapping,
  // encrypted credential storage, idempotency and durable queues are ready.
  return NextResponse.json({ received: true, processing: "not-configured" });
}
