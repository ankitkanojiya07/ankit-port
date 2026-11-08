import { ImageResponse } from "next/og";

export const ogSize = { width: 1200, height: 630 };

/** Branded 1200x630 share card. */
export function ogCard({ kicker, title, sub }: { kicker: string; title: string; sub?: string }) {
  const size = title.length > 70 ? 54 : title.length > 40 ? 64 : 76;
  return new ImageResponse(
    (
      <div style={{ width: "100%", height: "100%", display: "flex", flexDirection: "column", justifyContent: "space-between", background: "#0B0C0E", color: "#ECEAE4", padding: 72, fontFamily: "sans-serif" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          <svg width="64" height="64" viewBox="0 0 32 32" fill="none">
            <rect x="0.75" y="0.75" width="30.5" height="30.5" rx="8" fill="#14161A" stroke="#2a2d33" strokeWidth="1.5" />
            <path d="M16 7 L8 25 M16 7 L24 25" stroke="#C6FF3D" strokeWidth="2" strokeLinecap="round" />
            <path d="M11.4 18 H20.6" stroke="#C6FF3D" strokeWidth="1.8" strokeLinecap="round" strokeDasharray="1.5 3" />
            <circle cx="16" cy="7" r="2.6" fill="#C6FF3D" />
            <circle cx="8" cy="25" r="2.2" fill="#C6FF3D" />
            <circle cx="24" cy="25" r="2.2" fill="#C6FF3D" />
          </svg>
          <div style={{ fontSize: 30, color: "#8A8F98" }}>Ankit Kanojiya</div>
        </div>
        <div style={{ display: "flex", flexDirection: "column" }}>
          <div style={{ fontSize: 28, color: "#C6FF3D", letterSpacing: 2, textTransform: "uppercase", marginBottom: 20 }}>{kicker}</div>
          <div style={{ fontSize: size, fontWeight: 700, lineHeight: 1.08, letterSpacing: -1.5 }}>{title}</div>
          {sub ? <div style={{ fontSize: 30, color: "#8A8F98", marginTop: 24 }}>{sub}</div> : null}
        </div>
        <div style={{ display: "flex", height: 6, width: 180, background: "#C6FF3D", borderRadius: 3 }} />
      </div>
    ),
    ogSize,
  );
}
