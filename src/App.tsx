import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { useState, useEffect } from 'react'
import Layout from './components/layout/Layout'
import Dashboard from './pages/Dashboard'
import Leads from './pages/Leads'
import CompletedLeads from './pages/CompletedLeads'
import OnTheFence from './pages/OnTheFence'
import UncompletedLeads from './pages/UncompletedLeads'
import Analytics from './pages/Analytics'
import LoginPage from './pages/auth/LoginPage'
import SignupPage from './pages/auth/SignupPage'
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage'
import { LeadsProvider } from './context/LeadsContext'
import { AuthProvider, useAuth } from './context/AuthContext'
import ProtectedRoute from './components/auth/ProtectedRoute'
import LoadingAnimation from './components/common/LoadingAnimation'

// Component to handle auth redirects
const AuthRedirectHandler: React.FC = () => {
  const { isAuthenticated, loading } = useAuth()

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-propello-blue mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  if (isAuthenticated) {
    return <Navigate to="/" replace />
  }

  return <Navigate to="/login" replace />
}

function App() {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Simulate loading time for demo purposes
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 3000)

    return () => clearTimeout(timer)
  }, [])

  if (isLoading) {
    return <LoadingAnimation onComplete={() => setIsLoading(false)} />
  }

  return (
    <AuthProvider>
      <LeadsProvider>
        <Router>
          <div className="min-h-screen bg-navy-50">
            <Routes>
              {/* Auth Routes */}
              <Route path="/login" element={<LoginPage />} />
              <Route path="/signup" element={<SignupPage />} />
              <Route path="/forgot-password" element={<ForgotPasswordPage />} />
              
              {/* Protected Routes */}
              <Route path="/" element={
                <ProtectedRoute>
                  <Layout>
                    <Dashboard />
                  </Layout>
                </ProtectedRoute>
              } />
              <Route path="/on-the-fence" element={
                <ProtectedRoute>
                  <Layout>
                    <OnTheFence />
                  </Layout>
                </ProtectedRoute>
              } />
              <Route path="/completed-leads" element={
                <ProtectedRoute>
                  <Layout>
                    <CompletedLeads />
                  </Layout>
                </ProtectedRoute>
              } />
              <Route path="/uncompleted-leads" element={
                <ProtectedRoute>
                  <Layout>
                    <UncompletedLeads />
                  </Layout>
                </ProtectedRoute>
              } />
              <Route path="/leads" element={
                <ProtectedRoute>
                  <Layout>
                    <Leads />
                  </Layout>
                </ProtectedRoute>
              } />
              <Route path="/analytics" element={
                <ProtectedRoute>
                  <Layout>
                    <Analytics />
                  </Layout>
                </ProtectedRoute>
              } />
              
              {/* Catch all route */}
              <Route path="*" element={<AuthRedirectHandler />} />
            </Routes>
            <Toaster 
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: '#363636',
                  color: '#fff',
                },
              }}
            />
          </div>
        </Router>
      </LeadsProvider>
    </AuthProvider>
  )
}

export default App

