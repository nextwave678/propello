import React, { useState, useEffect, useMemo } from 'react'
import { Search, AlertTriangle } from 'lucide-react'
import { useLeads } from '../context/LeadsContext'
import LeadCard from '../components/leads/LeadCard'
import CompletionModal from '../components/leads/CompletionModal'
import { Lead } from '../types/lead.types'

const OnTheFence: React.FC = () => {
  const { leads, loading, refreshLeads, markLeadComplete } = useLeads()
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  // Filter on the fence leads
  const onTheFenceLeads = useMemo(() => {
    return leads.filter(lead => lead.completion_status === 'on_the_fence')
  }, [leads])

  // Apply search filter
  const filteredLeads = useMemo(() => {
    return onTheFenceLeads.filter(lead => {
      const matchesSearch = searchTerm === '' || 
        lead.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        lead.phone.includes(searchTerm) ||
        (lead.email && lead.email.toLowerCase().includes(searchTerm.toLowerCase()))
      
      return matchesSearch
    })
  }, [onTheFenceLeads, searchTerm])

  useEffect(() => {
    refreshLeads()
  }, [refreshLeads])

  const handleLeadClick = (lead: Lead) => {
    setSelectedLead(lead)
    setIsModalOpen(true)
  }

  const handleComplete = async (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => {
    try {
      await markLeadComplete(leadId, completionStatus)
      setIsModalOpen(false)
      setSelectedLead(null)
    } catch (error) {
      console.error('Failed to update lead status:', error)
    }
  }

  const getStatusCounts = () => {
    const counts = {
      on_the_fence: onTheFenceLeads.length,
      total: leads.length
    }
    
    return counts
  }

  const statusCounts = getStatusCounts()

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-propello-blue"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">On the Fence Leads</h1>
            <p className="text-gray-600">Leads that need follow-up or are still considering</p>
          </div>
          <div className="flex items-center space-x-4 text-sm text-gray-600">
            <div className="flex items-center space-x-1">
              <AlertTriangle className="h-4 w-4 text-yellow-600" />
              <span>{statusCounts.on_the_fence} On the Fence</span>
            </div>
            <div className="text-gray-400">•</div>
            <div className="text-gray-500">
              {statusCounts.total} Total Leads
            </div>
          </div>
        </div>

        {/* Search */}
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search leads by name, phone, or email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-propello-blue focus:border-propello-blue"
            />
          </div>
        </div>
      </div>

      {/* Results Summary */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <p className="text-sm text-gray-600">
          Showing {filteredLeads.length} of {onTheFenceLeads.length} on the fence leads
          {searchTerm && ` matching "${searchTerm}"`}
        </p>
      </div>

      {/* Leads Grid */}
      {filteredLeads.length === 0 ? (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
          <AlertTriangle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No on the fence leads found</h3>
          <p className="text-gray-600">
            {onTheFenceLeads.length === 0 
              ? "You don't have any leads marked as 'on the fence' yet. Mark leads as 'on the fence' from the All Leads page."
              : "Try adjusting your search criteria."
            }
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredLeads.map((lead) => (
            <LeadCard
              key={lead.id}
              lead={lead}
              onClick={handleLeadClick}
            />
          ))}
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
        onComplete={handleComplete}
      />
    </div>
  )
}

export default OnTheFence
