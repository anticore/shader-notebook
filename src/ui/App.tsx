import { useHash } from "react-use";
import { useEffect, useState } from "react";
import shaders from "../../config";
import Renderer from "./Renderer";
import Code from "./Code";
import { type ShaderConfig } from "../types";

function App() {
  // current URL hash
  const [hash, setHash] = useHash();

  // current shader configuration
  const [shader, setShader] = useState<ShaderConfig | null>(null);

  useEffect(() => {
    // generates random hash from list of shader names
    function randomHash() {
      const currHash = hash.split("/")[1];
      const shaderNames = shaders.map((shader) => shader.name);
      const newHash =
        shaderNames[Math.floor(Math.random() * shaderNames.length)];
      if (currHash == newHash) return randomHash();
      setHash(`#/${newHash}`);

      // force reload to clean up state
      window.location.reload();
    }

    // if no hash, generate a random hash
    if (hash == "") {
      randomHash();
    } else {
      const currHash = hash.split("/")[1];
      const currShader = shaders.find((shader) => shader.name == currHash);

      // if shader is found with name == hash, set it as current shader
      if (currShader) {
        setShader(currShader);
      }
      // if not, randomize another shader
      else {
        randomHash();
      }
    }
  }, [hash, setHash]);

  return shader ? (
    <>
      <Renderer shader={shader} />
      <Code shader={shader} />
    </>
  ) : (
    // TODO: proper loading
    <>Loading...</>
  );
}

export default App;
