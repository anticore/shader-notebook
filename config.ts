import lineworkFrag from "./shaders/linework.glsl";
import { NotebookConfig } from "./src/types";

const notebookConfig: NotebookConfig = [
  {
    name: "linework",
    shaders: [
      {
        frag: lineworkFrag,
      },
    ],
  },
];

export default notebookConfig;
