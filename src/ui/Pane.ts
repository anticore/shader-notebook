import { Pane } from "tweakpane";
import * as EssentialsPlugin from "@tweakpane/plugin-essentials";
import shaders from "../shaders";

let pane: Pane | undefined;

export const createPane = () => {
  pane = new Pane();
  pane.registerPlugin(EssentialsPlugin);
  return pane;
};

export const getPane = () => pane;

// eslint-disable-next-line
export const addFPS = (): any => {
  if (!pane) return;

  return pane.addBlade({
    view: "fpsgraph",

    label: "FPS",
    rows: 2,
  });
};

// navigate to previous shader
function prevHash() {
  const currHash = window.location.hash.split("/")[1];
  console.log(currHash);
  const shaderNames = shaders.map((shader) => shader.name);
  const indexOfHash = shaderNames.indexOf(currHash);
  let newIndex = 0;
  if (indexOfHash === -1) randomHash();
  else if (indexOfHash === 0) newIndex = shaderNames.length - 1;
  else newIndex = indexOfHash - 1;

  window.location.hash = `#/${shaderNames[newIndex]}`;
  // force reload to clean up state
  window.location.reload();
}

// navigate to next shader
function nextHash() {
  const currHash = window.location.hash.split("/")[1];
  const shaderNames = shaders.map((shader) => shader.name);
  const indexOfHash = shaderNames.indexOf(currHash);
  let newIndex = 0;
  if (indexOfHash === -1) randomHash();
  else if (indexOfHash === shaderNames.length - 1) newIndex = 0;
  else newIndex = indexOfHash + 1;

  window.location.hash = `#/${shaderNames[newIndex]}`;
  // force reload to clean up state
  window.location.reload();
}

// generates random hash from list of shader names
function randomHash() {
  const currHash = window.location.hash.split("/")[1];
  const shaderNames = shaders.map((shader) => shader.name);
  const newHash = shaderNames[Math.floor(Math.random() * shaderNames.length)];
  if (currHash == newHash) return randomHash();
  window.location.hash = `#/${newHash}`;

  // force reload to clean up state
  window.location.reload();
}

export const addControls = () => {
  if (!pane) return;
  (
    pane.addBlade({
      view: "buttongrid",

      size: [3, 1],
      cells: (x: number, y: number) => ({
        title: [["👈", "🔃", "👉"]][y][x],
      }),
      label: "Controls",
      // eslint-disable-next-line
    }) as any
  )
    // eslint-disable-next-line
    .on("click", (ev: any) => {
      const x = ev.index[0];
      console.log("click", x);
      const methods = [prevHash, randomHash, nextHash];
      methods[x] && methods[x]();
    });
};

export default pane;
