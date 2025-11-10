import React, { useState } from 'react'
import { useLeads } from '../context/LeadsContext'
import LeadCard from '../components/leads/LeadCard'
import CompletionModal from '../components/leads/CompletionModal'
import { Lead } from '../types/lead.types'
import { TrendingUp, Users, Clock, AlertCircle } from 'lucide-react'

const Dashboard: React.FC = () => {
  const { leads, loading, error, analytics, markLeadComplete } = useLeads()
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleLeadComplete = (lead: Lead) => {
    setSelectedLead(lead)
    setIsModalOpen(true)
  }

  const handleModalComplete = async (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => {
    try {
      await markLeadComplete(leadId, completionStatus)
      setIsModalOpen(false)
      setSelectedLead(null)
    } catch (error) {
      console.error('Failed to mark lead as complete:', error)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="spinner"></div>
        <span className="ml-2 text-gray-600">Loading leads...</span>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Error Loading Leads</h3>
          <p className="text-gray-600">{error}</p>
        </div>
      </div>
    )
  }

  // Get recent leads (last 10)
  const recentLeads = leads.slice(0, 10)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Propello Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Manage your AI-generated real estate leads in real-time
        </p>
      </div>

      {/* Stats Cards */}
      {analytics && (
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
                <TrendingUp className="h-8 w-8 text-propello-hot" />
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
                <Clock className="h-8 w-8 text-propello-warm" />
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
                <AlertCircle className="h-8 w-8 text-propello-cold" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">New Today</p>
                <p className="text-2xl font-semibold text-gray-900">
                  {leads.filter(lead => {
                    const today = new Date()
                    const leadDate = new Date(lead.created_at)
                    return leadDate.toDateString() === today.toDateString()
                  }).length}
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Recent Leads */}
      <div>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Recent Leads</h2>
          <a 
            href="/leads" 
            className="text-propello-blue hover:text-propello-blue-700 font-medium"
          >
            View all leads →
          </a>
        </div>

        {recentLeads.length === 0 ? (
          <div className="text-center py-12">
            <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No leads yet</h3>
            <p className="text-gray-600">
              Waiting for your first AI agent call. Leads will appear here in real-time.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {recentLeads.map((lead) => (
              <LeadCard
                key={lead.id}
                lead={lead}
                onComplete={handleLeadComplete}
              />
            ))}
          </div>
        )}
      </div>

      {/* Lead Quality Distribution */}
      {analytics && (
        <div className="propello-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Lead Quality Distribution</h3>
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-propello-hot mb-1">
                {analytics.leadsByQuality.hot}
              </div>
              <div className="text-sm text-gray-600">Hot Leads</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-propello-warm mb-1">
                {analytics.leadsByQuality.warm}
              </div>
              <div className="text-sm text-gray-600">Warm Leads</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-propello-cold mb-1">
                {analytics.leadsByQuality.cold}
              </div>
              <div className="text-sm text-gray-600">Cold Leads</div>
            </div>
          </div>
        </div>
      )}

      {/* Completion Modal */}
      <CompletionModal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false)
          setSelectedLead(null)
        }}
        lead={selectedLead}
        onComplete={handleModalComplete}
      />
    </div>
  )
}

export default Dashboard
