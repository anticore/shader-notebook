import { useHash } from "react-use";
import shaders from "../shaders";
import { useEffect, useState } from "react";

const hashes = shaders.map((shader) => shader.hash);

function Controls() {
  const [hash, setHash] = useHash();
  const [currHash, setCurrHash] = useState("");

  function prevHash() {
    const indexOfHash = hashes.indexOf(currHash);
    let newIndex = 0;
    if (indexOfHash === -1) randomHash();
    else if (indexOfHash === 0) newIndex = hashes.length - 1;
    else newIndex = indexOfHash - 1;

    setHash(`#/${hashes[newIndex]}`);
  }

  function nextHash() {
    const indexOfHash = hashes.indexOf(currHash);
    let newIndex = 0;
    if (indexOfHash === -1) randomHash();
    else if (indexOfHash === hashes.length - 1) newIndex = 0;
    else newIndex = indexOfHash + 1;

    setHash(`#/${hashes[newIndex]}`);
  }

  function randomHash() {
    const randomHash = hashes[Math.floor(Math.random() * hashes.length)];

    setHash(`#/${randomHash}`);
  }

  useEffect(() => {
    if (hash !== "") {
      const urlHash = hash.split("/")[1];
      const currShader = shaders.find((shader) => shader.hash == urlHash);

      if (currShader) {
        setCurrHash(urlHash);
      }
    }
  }, [hash, setHash, currHash]);

  return (
    <div className="controls">
      <div className="controls__button" onClick={prevHash}>
        👈
      </div>
      <div className="controls__text">{currHash}</div>
      <div className="controls__button" onClick={randomHash}>
        🔃
      </div>
      <div className="controls__button" onClick={nextHash}>
        👉
      </div>
    </div>
  );
}

export default Controls;
