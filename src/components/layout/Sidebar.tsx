import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { 
  LayoutDashboard, 
  Users, 
  BarChart3, 
  Settings,
  Home,
  X,
  CheckCircle
} from 'lucide-react'

const Sidebar: React.FC = () => {
  const location = useLocation()

  const navigation = [
    { name: 'Dashboard', href: '/', icon: LayoutDashboard },
    { name: 'All Leads', href: '/leads', icon: Users },
    { name: 'Completed Leads', href: '/completed-leads', icon: CheckCircle },
    { name: 'Analytics', href: '/analytics', icon: BarChart3 },
    { name: 'Settings', href: '/settings', icon: Settings },
  ]

  const isActive = (path: string) => {
    if (path === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(path)
  }

  return (
    <>
      {/* Desktop Sidebar */}
      <div className="hidden lg:flex lg:flex-shrink-0">
        <div className="flex flex-col w-64">
          <div className="flex flex-col flex-grow bg-white border-r border-gray-200 pt-5 pb-4 overflow-y-auto">
            <div className="flex items-center flex-shrink-0 px-4">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <Home className="h-8 w-8 text-propello-blue" />
                </div>
                <div className="ml-3">
                  <h2 className="text-lg font-semibold text-gray-900">Propello</h2>
                  <p className="text-sm text-gray-500">Lead Management</p>
                </div>
              </div>
            </div>
            
            <div className="mt-8 flex-grow flex flex-col">
              <nav className="flex-1 px-2 space-y-1">
                {navigation.map((item) => {
                  const Icon = item.icon
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      className={`${
                        isActive(item.href)
                          ? 'bg-propello-blue-50 border-propello-blue text-propello-blue'
                          : 'border-transparent text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      } group flex items-center px-2 py-2 text-sm font-medium rounded-md border-l-4 transition-colors duration-200`}
                    >
                      <Icon
                        className={`${
                          isActive(item.href) ? 'text-propello-blue' : 'text-gray-400 group-hover:text-gray-500'
                        } mr-3 flex-shrink-0 h-6 w-6`}
                      />
                      {item.name}
                    </Link>
                  )
                })}
              </nav>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Sidebar */}
      <div className="lg:hidden">
        {/* Mobile sidebar overlay */}
        <div className="fixed inset-0 flex z-40">
          <div className="fixed inset-0 bg-gray-600 bg-opacity-75" />
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white">
                <span className="sr-only">Close sidebar</span>
                <X className="h-6 w-6 text-white" />
              </button>
            </div>
            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4">
                <div className="flex items-center">
                  <Home className="h-8 w-8 text-propello-blue" />
                  <div className="ml-3">
                    <h2 className="text-lg font-semibold text-gray-900">Propello</h2>
                    <p className="text-sm text-gray-500">Lead Management</p>
                  </div>
                </div>
              </div>
              <nav className="mt-5 px-2 space-y-1">
                {navigation.map((item) => {
                  const Icon = item.icon
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      className={`${
                        isActive(item.href)
                          ? 'bg-propello-blue-50 border-propello-blue text-propello-blue'
                          : 'border-transparent text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      } group flex items-center px-2 py-2 text-base font-medium rounded-md border-l-4`}
                    >
                      <Icon
                        className={`${
                          isActive(item.href) ? 'text-propello-blue' : 'text-gray-400 group-hover:text-gray-500'
                        } mr-4 flex-shrink-0 h-6 w-6`}
                      />
                      {item.name}
                    </Link>
                  )
                })}
              </nav>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

export default Sidebar
