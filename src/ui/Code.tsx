import SyntaxHighlighter from "react-syntax-highlighter";
import { dark } from "react-syntax-highlighter/dist/esm/styles/hljs";

export interface CodeProps {
  shader: string;
}

function Code({ shader }: CodeProps) {
  return (
    <div className="code">
      <SyntaxHighlighter language="glsl" style={dark}>
        {shader}
      </SyntaxHighlighter>
    </div>
  );
}

export default Code;
