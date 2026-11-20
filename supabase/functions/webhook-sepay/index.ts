// Supabase Edge Function: nhận webhook biến động số dư từ SePay.
// Deploy: supabase functions deploy webhook-sepay --no-verify-jwt
// Secrets: supabase secrets set SEPAY_API_KEY=...
import { createClient } from "npm:@supabase/supabase-js@2";

interface SepayPayload {
  id: number;
  gateway: string;
  transactionDate: string;
  accountNumber: string;
  content: string;
  transferType: "in" | "out";
  transferAmount: number;
  accumulated: number;
  referenceCode: string;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });

  // SePay gửi header: Authorization: Apikey <key>
  const expected = `Apikey ${Deno.env.get("SEPAY_API_KEY")}`;
  if (req.headers.get("Authorization") !== expected) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body: SepayPayload;
  try {
    body = await req.json();
  } catch {
    return new Response("Bad Request", { status: 400 });
  }

  const { error } = await supabase.from("bank_events").upsert(
    {
      sepay_id: body.id,
      gateway: body.gateway,
      account_number: body.accountNumber,
      amount: body.transferType === "out" ? -body.transferAmount : body.transferAmount,
      content: body.content,
      reference_code: body.referenceCode,
      occurred_at: body.transactionDate,
    },
    { onConflict: "sepay_id" }, // idempotent: SePay có thể gửi lại
  );

  if (error) return new Response(JSON.stringify({ success: false }), { status: 500 });
  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
