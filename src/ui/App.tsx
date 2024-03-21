import { useHash } from "react-use";
import { useEffect, useRef, useState } from "react";
import shaders from "../shaders";
import Renderer from "./Renderer";
import Controls from "./Controls";
import Code from "./Code";

const hashes = shaders.map((shader) => shader.hash);

function App() {
  const [hash, setHash] = useHash();
  const [frag, setFrag] = useState<string | null>(null);
  const loaded = useRef(0);

  useEffect(() => {
    if (loaded.current > 1) {
      window.location.reload();
    }
    loaded.current++;

    function randomHash() {
      const randomHash = hashes[Math.floor(Math.random() * hashes.length)];

      setHash(`#/${randomHash}`);
    }

    if (hash == "") {
      randomHash();
    } else {
      const currHash = hash.split("/")[1];
      const currShader = shaders.find((shader) => shader.hash == currHash);

      if (currShader) {
        setFrag(currShader.frag);
      } else {
        randomHash();
      }
    }
  }, [hash, setHash]);

  return (
    <>
      {frag && (
        <>
          <Renderer shader={frag} />
          <Controls />
          <Code shader={frag} />
        </>
      )}
    </>
  );
}

export default App;
