import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import TagManager from "react-gtm-module";

import App from "./App";

const tagManagerArgs = {
  gtmId: process.env.REACT_GTM_ID ?? "",
};

TagManager.initialize(tagManagerArgs);

const rootElement = document.getElementById("root") as HTMLElement;
const root = createRoot(rootElement);

root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
