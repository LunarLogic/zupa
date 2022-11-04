import { FC, useEffect, useState } from "react";
import { Navigate } from "react-router-dom";

import { useAuth } from "./../hooks/useAuth";

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute: FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(false);
  }, [isAuthenticated]);

  return isLoading ? null : isAuthenticated ? <>{children}</> : <Navigate to="/" replace />;
};
