"use client";
import { useActionState } from "react";
import { sendMessage, type ContactState } from "./actions";

const field = "w-full rounded-xl border border-line bg-surface px-4 py-3 outline-none focus:border-accent";

export default function ContactForm() {
  const [state, action, pending] = useActionState<ContactState, FormData>(sendMessage, { ok: false, message: "" });
  return (
    <form action={action} className="space-y-4">
      <input name="website" tabIndex={-1} autoComplete="off" className="hidden" aria-hidden />
      <label className="block text-sm">Name<input name="name" required maxLength={120} className={`${field} mt-1`} /></label>
      <label className="block text-sm">Email<input name="email" type="email" required maxLength={200} className={`${field} mt-1`} /></label>
      <label className="block text-sm">Message<textarea name="message" required maxLength={4000} rows={6} className={`${field} mt-1`} /></label>
      <button disabled={pending} className="rounded-full bg-accent text-accent-ink px-6 py-3 font-medium disabled:opacity-60">
        {pending ? "Sending…" : "Send message"}
      </button>
      {state.message && <p role="status" className={state.ok ? "text-accent" : "text-red-400"}>{state.message}</p>}
    </form>
  );
}
