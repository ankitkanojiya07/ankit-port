import type { Metadata } from "next";
import Dashboard from "./Dashboard";

export const metadata: Metadata = { title: "Admin", robots: { index: false, follow: false } };

export default function AdminPage() {
  return (
    <div className="mx-auto max-w-5xl px-4 sm:px-6 pt-10">
      <Dashboard />
    </div>
  );
}
