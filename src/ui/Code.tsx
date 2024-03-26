import SyntaxHighlighter from "react-syntax-highlighter";
import { dark } from "react-syntax-highlighter/dist/esm/styles/hljs";
import { ShaderConfig } from "../shaders";

export interface CodeProps {
  shader: ShaderConfig;
}

function Code({ shader }: CodeProps) {
  return (
    <div className="code">
      <SyntaxHighlighter language="glsl" style={dark}>
        {shader.frag}
      </SyntaxHighlighter>
    </div>
  );
}

export default Code;
