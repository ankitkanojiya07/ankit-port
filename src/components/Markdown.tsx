import ReactMarkdown from "react-markdown";

export default function Markdown({ children }: { children: string }) {
  return (
    <div className="prose-md">
      <ReactMarkdown skipHtml>{children}</ReactMarkdown>
    </div>
  );
}
