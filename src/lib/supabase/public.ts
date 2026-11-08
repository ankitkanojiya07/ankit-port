import { createClient } from "@supabase/supabase-js";

/** Cookie-less client for public reads, so pages can be statically generated / ISR-cached. */
export function createPublicClient() {
  return createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
