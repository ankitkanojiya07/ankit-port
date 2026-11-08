import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Protects /admin: requires a Supabase session, and (if set) the ADMIN_EMAIL account.
export async function proxy(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) {
    return NextResponse.redirect(new URL("/sign-in?setup=1", request.url));
  }

  let response = NextResponse.next({ request });
  const supabase = createServerClient(url, key, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll: (list) => {
        list.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        list.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
      },
    },
  });

  const { data } = await supabase.auth.getUser();
  const admin = process.env.ADMIN_EMAIL?.toLowerCase();
  const ok = data.user && (!admin || data.user.email?.toLowerCase() === admin);
  if (!ok) return NextResponse.redirect(new URL("/sign-in", request.url));
  return response;
}

export const config = { matcher: ["/admin/:path*"] };
