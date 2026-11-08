"use server";
import { createClient, hasSupabase } from "@/lib/supabase/server";

export type ContactState = { ok: boolean; message: string };

export async function sendMessage(_: ContactState, form: FormData): Promise<ContactState> {
  const name = String(form.get("name") ?? "").trim();
  const email = String(form.get("email") ?? "").trim();
  const message = String(form.get("message") ?? "").trim();
  const trap = String(form.get("website") ?? "");
  if (trap) return { ok: true, message: "Thanks!" };
  if (!name || !/^\S+@\S+\.\S+$/.test(email) || !message) return { ok: false, message: "Please fill in all fields with a valid email." };
  if (name.length > 120 || email.length > 200 || message.length > 4000) return { ok: false, message: "Message is too long." };
  if (!hasSupabase()) return { ok: false, message: "Messages aren't connected yet. Please email me directly." };
  const sb = await createClient();
  const { error } = await sb.from("contact_messages").insert({ name, email, message });
  if (error) return { ok: false, message: "Something went wrong. Please email me directly." };
  return { ok: true, message: "Thanks! I'll get back to you soon." };
}
