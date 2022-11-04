import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Route, BrowserRouter as Router, Routes } from "react-router-dom";

import { ToastRenderer } from "./components/molecules/Toast/Toast";
import PageLayout from "./components/organisms/Layout/Layout";
import { AppProvider } from "./context/AppProvider";
import { ModalProvider } from "./context/ModalContext";
import { AuthProvider } from "./hooks/useAuth";
import { ProtectedRoute } from "./utils/ProtectedRoute";
import { routesConfig } from "./utils/routesConfig";

const queryClient = new QueryClient();

export default function App() {
  return (
    <AuthProvider>
      <AppProvider>
        <ModalProvider>
          <QueryClientProvider client={queryClient}>
            <ToastRenderer />
            <Router>
              <PageLayout>
                <Routes>
                  {routesConfig.map(({ path, element, protected: isProtected }) =>
                    isProtected ? (
                      <Route
                        key={path}
                        path={path}
                        element={<ProtectedRoute>{element}</ProtectedRoute>}
                      />
                    ) : (
                      <Route key={path} path={path} element={element} />
                    )
                  )}
                </Routes>
              </PageLayout>
            </Router>
          </QueryClientProvider>
        </ModalProvider>
      </AppProvider>
    </AuthProvider>
  );
}
