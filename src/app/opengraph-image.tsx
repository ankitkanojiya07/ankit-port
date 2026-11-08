import { ogCard, ogSize } from "@/lib/og";

export const alt = "Tech news and interview experiences for developers — Ankit Kanojiya";
export const size = ogSize;
export const contentType = "image/png";

export default function Image() {
  return ogCard({
    kicker: "Tech news · Interview experiences",
    title: "Tech news and interview experiences for developers. Software built for businesses.",
  });
}
