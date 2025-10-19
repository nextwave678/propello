import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { useState, useEffect } from 'react'
import Layout from './components/layout/Layout'
import Dashboard from './pages/Dashboard'
import Leads from './pages/Leads'
import CompletedLeads from './pages/CompletedLeads'
import Analytics from './pages/Analytics'
import { LeadsProvider } from './context/LeadsContext'
import LoadingAnimation from './components/common/LoadingAnimation'

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
    <LeadsProvider>
      <Router>
        <div className="min-h-screen bg-navy-50">
          <Layout>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/leads" element={<Leads />} />
              <Route path="/completed-leads" element={<CompletedLeads />} />
              <Route path="/analytics" element={<Analytics />} />
            </Routes>
          </Layout>
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
  )
}

export default App

