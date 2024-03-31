import { BaseBladeParams, Pane } from "tweakpane";
import * as EssentialsPlugin from "@tweakpane/plugin-essentials";
import shaders from "../../config";
import { UniformConfig } from "../types";

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
      const methods = [prevHash, randomHash, nextHash];
      methods[x] && methods[x]();
    });

  const currHash = window.location.hash.split("/")[1];
  (
    pane.addBlade({
      view: "list",
      label: "Shader",
      options: shaders.map((shader) => ({
        text: shader.name,
        value: shader.name,
      })),
      value: currHash,
      // eslint-disable-next-line
    }) as any
  )
    // eslint-disable-next-line
    .on("change", (ev: any) => {
      window.location.hash = `#/${ev["value"]}`;
      // force reload to clean up state
      window.location.reload();
    });
};

export const addMonitors = (
  inUniforms: {
    [key: string]: number | string | number[];
  },
  monitor: ([string] | [string, BaseBladeParams])[]
) => {
  if (!pane) return;
  // eslint-disable-next-line
  monitor.forEach(([value, opts]) =>
    pane?.addBinding(inUniforms, value, { readonly: true, ...opts })
  );
  return inUniforms;
};

export const createUniforms = (
  inUniforms: { [key: string]: number | string | number[] },
  uniforms?: UniformConfig[]
) => {
  if (!uniforms || uniforms.length === 0) return inUniforms;

  const folder = getPane()?.addFolder({
    title: "Uniforms",
  });

  uniforms.forEach((uniform) => {
    inUniforms[uniform.name] = uniform.value;
    folder?.addBinding(inUniforms, uniform.name, uniform.options);
  });

  return inUniforms;
};

export default pane;
