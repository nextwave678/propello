import React, { useState } from 'react'
import { Search, Bell, User, Menu, X } from 'lucide-react'
import { useLeads } from '../../context/LeadsContext'

const Navbar: React.FC = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const { leads } = useLeads()
  
  // Count new leads (status: 'new')
  const newLeadsCount = leads.filter(lead => lead.status === 'new').length

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo and Brand */}
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <h1 className="text-2xl font-bold text-propello-blue">
                Propello
              </h1>
            </div>
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
                className="propello-input pl-10 w-full"
              />
            </div>
          </div>

          {/* Right side items */}
          <div className="flex items-center space-x-4">
            {/* Notifications */}
            <div className="relative">
              <button className="p-2 text-gray-400 hover:text-gray-600 relative">
                <Bell className="h-6 w-6" />
                {newLeadsCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-propello-hot text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                    {newLeadsCount}
                  </span>
                )}
              </button>
            </div>

            {/* User Profile */}
            <div className="flex items-center space-x-3">
              <div className="hidden sm:block">
                <p className="text-sm font-medium text-gray-700">Realtor</p>
                <p className="text-xs text-gray-500">Lead Manager</p>
              </div>
              <button className="p-2 text-gray-400 hover:text-gray-600">
                <User className="h-6 w-6" />
              </button>
            </div>

            {/* Mobile menu button */}
            <button
              className="md:hidden p-2 text-gray-400 hover:text-gray-600"
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
              className="propello-input pl-10 w-full"
            />
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar

