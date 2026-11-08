"use client";
import { useEffect, useState } from "react";

export default function Clock() {
  const [t, setT] = useState("");
  useEffect(() => {
    const f = () =>
      setT(new Date().toLocaleTimeString("en-GB", { timeZone: "Asia/Kolkata", hour12: false }));
    f();
    const id = setInterval(f, 1000);
    return () => clearInterval(id);
  }, []);
  return <span className="font-mono text-xs text-muted tabular-nums">Delhi · {t || "--:--:--"} IST</span>;
}
