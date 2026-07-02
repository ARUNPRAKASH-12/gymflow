import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('gymflow_token');
    if (token) {
      loadUser();
    } else {
      setLoading(false);
    }
  }, []);

  async function loadUser() {
    try {
      const data = await api.getProfile();
      setUser(data.user);
    } catch {
      localStorage.removeItem('gymflow_token');
    } finally {
      setLoading(false);
    }
  }

  async function login(email, password) {
    const data = await api.login(email, password);
    localStorage.setItem('gymflow_token', data.token);
    if (data.refresh_token) localStorage.setItem('gymflow_refresh', data.refresh_token);
    setUser(data.user);
    return data;
  }

  function logout() {
    localStorage.removeItem('gymflow_token');
    localStorage.removeItem('gymflow_refresh');
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
