import jwtDecode from "jwt-decode";
import { FC, createContext, useContext, useEffect, useState } from "react";
import { z } from "zod";

import authenticate from "../api/authenticate";

interface AuthProviderProps {
  children: React.ReactNode;
}

interface AuthContextProps {
  isAuthenticated: boolean;
  login: (credentials: { name: string; code: string }) => Promise<void>;
  logout: () => void;
}

interface DecodedToken {
  exp: number;
}

const CredentialsSchema = z.object({
  name: z.string(),
  code: z.string(),
});

const AuthContext = createContext<AuthContextProps>({
  isAuthenticated: false,
  login: async () => {
    throw new Error("AuthProvider not found");
  },
  logout: () => {
    throw new Error("AuthProvider not found");
  },
});

export const AuthProvider: FC<AuthProviderProps> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("authToken");

    if (token) {
      const decodedToken = jwtDecode<DecodedToken>(token);
      const { exp } = decodedToken;
      const hasTokenExpired = exp && Date.now() >= exp * 1000;

      if (hasTokenExpired) {
        setIsAuthenticated(false);
        localStorage.removeItem("authToken");
      } else {
        setIsAuthenticated(true);
      }
    }
  }, []);

  const login = async (credentials: unknown) => {
    const parsedCredentials = CredentialsSchema.parse(credentials);
    const success = await authenticate(parsedCredentials);

    if (success) {
      setIsAuthenticated(true);
    }
  };

  const logout = () => {
    setIsAuthenticated(false);
    localStorage.removeItem("authToken");
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
