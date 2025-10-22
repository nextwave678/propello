import React, { useState, useEffect, useMemo } from 'react'
import { Search, Clock } from 'lucide-react'
import { useLeads } from '../context/LeadsContext'
import LeadCard from '../components/leads/LeadCard'
import CompletionModal from '../components/leads/CompletionModal'
import { Lead } from '../types/lead.types'

const UncompletedLeads: React.FC = () => {
  const { leads, loading, refreshLeads, markLeadComplete } = useLeads()
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  // Filter uncompleted leads (leads without completion_status)
  const uncompletedLeads = useMemo(() => {
    return leads.filter(lead => !lead.completion_status)
  }, [leads])

  // Apply search filter
  const filteredLeads = useMemo(() => {
    return uncompletedLeads.filter(lead => {
      const matchesSearch = searchTerm === '' || 
        lead.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        lead.phone.includes(searchTerm) ||
        (lead.email && lead.email.toLowerCase().includes(searchTerm.toLowerCase()))
      
      return matchesSearch
    })
  }, [uncompletedLeads, searchTerm])

  // Remove this useEffect - leads are already loaded by the context
  // useEffect(() => {
  //   refreshLeads()
  // }, [refreshLeads])

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
      uncompleted: uncompletedLeads.length,
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
            <h1 className="text-2xl font-bold text-gray-900">Uncompleted Leads</h1>
            <p className="text-gray-600">Active leads that haven't been marked as complete yet</p>
          </div>
          <div className="flex items-center space-x-4 text-sm text-gray-600">
            <div className="flex items-center space-x-1">
              <Clock className="h-4 w-4 text-blue-600" />
              <span>{statusCounts.uncompleted} Uncompleted</span>
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
          Showing {filteredLeads.length} of {uncompletedLeads.length} uncompleted leads
          {searchTerm && ` matching "${searchTerm}"`}
        </p>
      </div>

      {/* Leads Grid */}
      {filteredLeads.length === 0 ? (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
          <Clock className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No uncompleted leads found</h3>
          <p className="text-gray-600">
            {uncompletedLeads.length === 0 
              ? "All leads have been completed. Great job! 🎉"
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
              onComplete={handleLeadClick}
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

export default UncompletedLeads
