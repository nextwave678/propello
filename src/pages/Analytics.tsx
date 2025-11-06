import React from 'react'
import { useLeads } from '../context/LeadsContext'
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line
} from 'recharts'
import { TrendingUp, Users, Target, Clock } from 'lucide-react'

const Analytics: React.FC = () => {
  const { analytics, loading } = useLeads()

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="spinner"></div>
        <span className="ml-2 text-gray-600">Loading analytics...</span>
      </div>
    )
  }

  if (!analytics) {
    return (
      <div className="text-center py-12">
        <TrendingUp className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 mb-2">No analytics data</h3>
        <p className="text-gray-600">Analytics will appear once you have leads in the system.</p>
      </div>
    )
  }

  // Prepare data for charts
  const qualityData = [
    { name: 'Hot', value: analytics.leadsByQuality.hot, color: '#ef4444' },
    { name: 'Warm', value: analytics.leadsByQuality.warm, color: '#f97316' },
    { name: 'Cold', value: analytics.leadsByQuality.cold, color: '#3b82f6' },
  ]

  const statusData = [
    { name: 'New', value: analytics.leadsByStatus.new, color: '#3b82f6' },
    { name: 'Contacted', value: analytics.leadsByStatus.contacted, color: '#f59e0b' },
    { name: 'Qualified', value: analytics.leadsByStatus.qualified, color: '#10b981' },
    { name: 'Closed', value: analytics.leadsByStatus.closed, color: '#059669' },
    { name: 'Dead', value: analytics.leadsByStatus.dead, color: '#6b7280' },
  ]

  const typeData = [
    { name: 'Buyers', value: analytics.leadsByType.buyer, color: '#2563eb' },
    { name: 'Sellers', value: analytics.leadsByType.seller, color: '#7c3aed' },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Analytics Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Insights and performance metrics for your lead management
        </p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="propello-card">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Users className="h-8 w-8 text-propello-blue" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total Leads</p>
              <p className="text-2xl font-semibold text-gray-900">{analytics.totalLeads}</p>
            </div>
          </div>
        </div>

        <div className="propello-card">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Target className="h-8 w-8 text-propello-hot" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Conversion Rate</p>
              <p className="text-2xl font-semibold text-gray-900">{analytics.conversionRate.toFixed(1)}%</p>
            </div>
          </div>
        </div>

        <div className="propello-card">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <TrendingUp className="h-8 w-8 text-propello-warm" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Hot Leads</p>
              <p className="text-2xl font-semibold text-gray-900">{analytics.leadsByQuality.hot}</p>
            </div>
          </div>
        </div>

        <div className="propello-card">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Clock className="h-8 w-8 text-propello-cold" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Closed Deals</p>
              <p className="text-2xl font-semibold text-gray-900">{analytics.leadsByStatus.closed}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Lead Quality Distribution */}
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Lead Quality Distribution</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={qualityData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {qualityData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Lead Type Distribution */}
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Buyer vs Seller</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={typeData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {typeData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Lead Status Breakdown */}
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Lead Status Breakdown</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={statusData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" fill="#2563eb" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Quality Trends */}
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Quality Trends (Last 7 Days)</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={analytics.qualityTrends}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="hot" stroke="#ef4444" strokeWidth={2} />
                <Line type="monotone" dataKey="warm" stroke="#f97316" strokeWidth={2} />
                <Line type="monotone" dataKey="cold" stroke="#3b82f6" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      {analytics.recentActivity && analytics.recentActivity.length > 0 && (
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
          <div className="space-y-3">
            {analytics.recentActivity.slice(0, 5).map((activity) => (
              <div key={activity.id} className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                <div className="flex-shrink-0">
                  <div className="w-2 h-2 bg-propello-blue rounded-full"></div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">{activity.description}</p>
                  <p className="text-xs text-gray-500">
                    {new Date(activity.created_at).toLocaleString()}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

export default Analytics










