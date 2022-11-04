import "@testing-library/jest-dom";
import { render } from "@testing-library/react";
import React, { ReactElement } from "react";
import { BrowserRouter } from "react-router-dom";

import { AuthProvider } from "./hooks/useAuth";

export const testRenderer = (
  children:
    | string
    | number
    | boolean
    | React.ReactElement<any, string | React.JSXElementConstructor<any>>
    | Iterable<React.ReactNode>
    | React.ReactPortal
    | null
    | undefined,
  { route = "/" } = {}
) => {
  window.history.pushState({}, "Test page", route);
  return render(<AuthProvider>{children}</AuthProvider>, {
    wrapper: BrowserRouter,
  });
};

export * from "@testing-library/react";
export { testRenderer as render };
