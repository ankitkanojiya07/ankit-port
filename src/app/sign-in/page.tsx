import type { Metadata } from "next";
import SignInForm from "./SignInForm";

export const metadata: Metadata = { title: "Sign in", robots: { index: false, follow: false } };

export default async function SignInPage({ searchParams }: PageProps<"/sign-in">) {
  const sp = await searchParams;
  return (
    <div className="mx-auto max-w-md px-4 sm:px-6 pt-20">
      <p className="font-mono text-xs text-accent mb-2">/sign-in</p>
      <h1 className="font-display text-3xl font-semibold tracking-tight mb-6">Admin sign in</h1>
      {sp.setup && (
        <p className="mb-4 rounded-xl border border-line bg-surface p-4 text-sm text-muted">
          Supabase isn&apos;t configured yet. Add your keys to <code>.env.local</code> and restart the dev server.
        </p>
      )}
      <SignInForm />
    </div>
  );
}
