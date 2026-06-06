import { createRoot } from "react-dom/client";

import TripBuilder from "./TripBuilder";
import type { Bootstrap } from "./types";

const dataElement = document.getElementById("trip-builder-data");
const rootElement = document.getElementById("trip-builder-root");

if (dataElement && rootElement) {
  const data: Bootstrap = JSON.parse(dataElement.textContent || "{}");
  createRoot(rootElement).render(<TripBuilder data={data} />);
}
