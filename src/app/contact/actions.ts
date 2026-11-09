"use server";
import nodemailer from "nodemailer";
import { createClient, hasSupabase } from "@/lib/supabase/server";

export type ContactState = { ok: boolean; message: string };

const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

async function sendMail(name: string, email: string, message: string): Promise<boolean> {
  const user = process.env.MAIL_USER;
  const pass = process.env.MAIL_PASS;
  if (!user || !pass) return false;
  try {
    const transporter = nodemailer.createTransport({ service: "gmail", auth: { user, pass } });
    await transporter.sendMail({
      from: `"Portfolio Contact" <${user}>`,
      to: process.env.MAIL_TO || user,
      replyTo: `"${name.replace(/["\r\n]/g, "")}" <${email}>`,
      subject: `New portfolio message from ${name.replace(/[\r\n]/g, " ")}`,
      text: `Name: ${name}\nEmail: ${email}\n\n${message}`,
      html: `<p><b>Name:</b> ${esc(name)}<br><b>Email:</b> ${esc(email)}</p><p style="white-space:pre-wrap">${esc(message)}</p>`,
    });
    return true;
  } catch (e) {
    console.error("Contact mail failed:", e);
    return false;
  }
}

export async function sendMessage(_: ContactState, form: FormData): Promise<ContactState> {
  const name = String(form.get("name") ?? "").trim();
  const email = String(form.get("email") ?? "").trim();
  const message = String(form.get("message") ?? "").trim();
  const trap = String(form.get("website") ?? "");
  if (trap) return { ok: true, message: "Thanks!" };
  if (!name || !/^\S+@\S+\.\S+$/.test(email) || !message) return { ok: false, message: "Please fill in all fields with a valid email." };
  if (name.length > 120 || email.length > 200 || message.length > 4000) return { ok: false, message: "Message is too long." };

  const mailed = await sendMail(name, email, message);

  let saved = false;
  if (hasSupabase()) {
    try {
      const sb = await createClient();
      const { error } = await sb.from("contact_messages").insert({ name, email, message });
      saved = !error;
    } catch {
      saved = false;
    }
  }

  if (!mailed && !saved) return { ok: false, message: "Something went wrong. Please email me directly." };
  return { ok: true, message: "Thanks! I'll get back to you soon." };
}
