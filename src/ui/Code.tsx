import SyntaxHighlighter from "react-syntax-highlighter";
import { atelierCaveDark } from "react-syntax-highlighter/dist/esm/styles/hljs";
import { type ShaderConfig } from "../types";

export interface CodeProps {
  shader: ShaderConfig;
}

function Code({ shader }: CodeProps) {
  return (
    <div className="code-wrapper" hidden={shader.hideCode}>
      <div className="code-box">
        <div className="code-tab">
          <span className="code-label">Code</span>
        </div>
        <SyntaxHighlighter language="glsl" style={atelierCaveDark}>
          {shader.frag}
        </SyntaxHighlighter>
      </div>
    </div>
  );
}

export default Code;
