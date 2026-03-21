import { createContext, useContext, useEffect, useState } from "react";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);   // admin user
  const [loading, setLoading] = useState(true);

  // Restore auth on refresh
  useEffect(() => {
    const token = localStorage.getItem("access_token");
    const role = localStorage.getItem("role");

    if (token && role === "admin") {
      setUser({ token, role });
    } else {
      setUser(null);
    }

    setLoading(false);
  }, []);

  const login = (token, role) => {
    localStorage.setItem("access_token", token);
    localStorage.setItem("role", role);

    setUser({ token, role });
  };

  const logout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("role");

    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,       
        loading,    
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
