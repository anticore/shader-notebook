import { useHash } from "react-use";
import shaders from "../shaders";

const shaderNames = shaders.map((shader) => shader.name);

function Controls() {
  const [hash, setHash] = useHash();

  // navigate to previous shader
  function prevHash() {
    const indexOfHash = shaderNames.indexOf(currHash);
    let newIndex = 0;
    if (indexOfHash === -1) randomHash();
    else if (indexOfHash === 0) newIndex = shaderNames.length - 1;
    else newIndex = indexOfHash - 1;

    setHash(`#/${shaderNames[newIndex]}`);
    // force reload to clean up state
    window.location.reload();
  }

  // navigate to next shader
  function nextHash() {
    const indexOfHash = shaderNames.indexOf(currHash);
    let newIndex = 0;
    if (indexOfHash === -1) randomHash();
    else if (indexOfHash === shaderNames.length - 1) newIndex = 0;
    else newIndex = indexOfHash + 1;

    setHash(`#/${shaderNames[newIndex]}`);
    // force reload to clean up state
    window.location.reload();
  }

  // generates random hash from list of shader names
  function randomHash() {
    const randomHash =
      shaderNames[Math.floor(Math.random() * shaderNames.length)];
    setHash(`#/${randomHash}`);

    // force reload to clean up state
    window.location.reload();
  }

  //  set text of control label
  let currHash = "";

  if (hash !== "") {
    const urlHash = hash.split("/")[1];
    const currShader = shaders.find((shader) => shader.name == urlHash);

    if (currShader) {
      currHash = urlHash;
    }
  }

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
