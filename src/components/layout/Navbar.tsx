import React, { useState, useRef, useEffect } from 'react'
import { Search, Bell, User, Menu, X, LogOut, Settings } from 'lucide-react'
import { useLeads } from '../../context/LeadsContext'
import { useAuth } from '../../context/AuthContext'
import Logo from '../common/Logo'
import toast from 'react-hot-toast'

interface NavbarProps {
  isMobileMenuOpen: boolean
  setIsMobileMenuOpen: (open: boolean) => void
}

const Navbar: React.FC<NavbarProps> = ({ isMobileMenuOpen, setIsMobileMenuOpen }) => {
  const { leads } = useLeads()
  const { profile, logout } = useAuth()
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false)
  const userMenuRef = useRef<HTMLDivElement>(null)
  
  // Count new leads (status: 'new')
  const newLeadsCount = leads.filter(lead => lead.status === 'new').length

  // Close user menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (userMenuRef.current && !userMenuRef.current.contains(event.target as Node)) {
        setIsUserMenuOpen(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [])

  const handleLogout = async () => {
    try {
      await logout()
      toast.success('Logged out successfully')
      setIsUserMenuOpen(false)
    } catch (error) {
      console.error('Logout error:', error)
      toast.error('Failed to logout. Please try again.')
    }
  }

  return (
    <nav className="bg-navy-800 shadow-lg border-b border-navy-700 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo and Brand */}
          <div className="flex items-center">
            <Logo size="md" showText={true} />
          </div>

          {/* Search Bar - Desktop */}
          <div className="hidden md:block flex-1 max-w-md mx-8">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search leads..."
                className="bg-navy-700 border-navy-600 text-white placeholder-gray-400 pl-10 w-full px-4 py-3 rounded-lg text-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          {/* Right side items */}
          <div className="flex items-center space-x-4">
            {/* Notifications */}
            <div className="relative">
              <button className="p-2 text-gray-300 hover:text-white relative transition-colors duration-200">
                <Bell className="h-6 w-6" />
                {newLeadsCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center font-semibold">
                    {newLeadsCount}
                  </span>
                )}
              </button>
            </div>

            {/* User Profile */}
            <div className="relative" ref={userMenuRef}>
              <div className="flex items-center space-x-3">
                <div className="hidden sm:block">
                  <p className="text-sm font-medium text-white">
                    {profile?.full_name || 'User'}
                  </p>
                  <p className="text-xs text-gray-300">
                    {profile?.company_name || 'Lead Manager'}
                  </p>
                </div>
                <button 
                  className="p-2 text-gray-300 hover:text-white transition-colors duration-200"
                  onClick={() => setIsUserMenuOpen(!isUserMenuOpen)}
                >
                  <User className="h-6 w-6" />
                </button>
              </div>

              {/* User Dropdown Menu */}
              {isUserMenuOpen && (
                <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 border border-gray-200">
                  <div className="px-4 py-2 border-b border-gray-100">
                    <p className="text-sm font-medium text-gray-900">
                      {profile?.full_name || 'User'}
                    </p>
                    <p className="text-xs text-gray-500">
                      {profile?.email}
                    </p>
                  </div>
                  
                  <button
                    className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors duration-200"
                    onClick={() => {
                      setIsUserMenuOpen(false)
                      // TODO: Navigate to settings page
                    }}
                  >
                    <Settings className="h-4 w-4 mr-3" />
                    Settings
                  </button>
                  
                  <button
                    className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors duration-200"
                    onClick={handleLogout}
                  >
                    <LogOut className="h-4 w-4 mr-3" />
                    Logout
                  </button>
                </div>
              )}
            </div>

            {/* Mobile menu button */}
            <button
              className="md:hidden p-2 text-gray-300 hover:text-white transition-colors duration-200"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile Search */}
        <div className="md:hidden pb-4">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search leads..."
              className="bg-navy-700 border-navy-600 text-white placeholder-gray-400 pl-10 w-full px-4 py-3 rounded-lg text-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar

