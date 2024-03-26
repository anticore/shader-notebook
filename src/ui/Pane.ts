import { Pane } from "tweakpane";
import * as EssentialsPlugin from "@tweakpane/plugin-essentials";

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

    label: "fpsgraph",
    rows: 2,
  });
};

export default pane;
