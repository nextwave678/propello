import React, { useState, useEffect, useMemo } from 'react'
import { Search, Filter, CheckCircle, AlertCircle, XCircle } from 'lucide-react'
import { useLeads } from '../context/LeadsContext'
import LeadCard from '../components/leads/LeadCard'
import CompletionModal from '../components/leads/CompletionModal'
import { Lead } from '../types/lead.types'

const CompletedLeads: React.FC = () => {
  const { leads, loading, refreshLeads } = useLeads()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<'all' | 'successful' | 'on_the_fence' | 'unsuccessful'>('all')
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  // Filter completed leads
  const completedLeads = useMemo(() => {
    return leads.filter(lead => lead.completion_status)
  }, [leads])

  // Apply search and status filters
  const filteredLeads = useMemo(() => {
    return completedLeads.filter(lead => {
      const matchesSearch = searchTerm === '' || 
        lead.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        lead.phone.includes(searchTerm) ||
        (lead.email && lead.email.toLowerCase().includes(searchTerm.toLowerCase()))
      
      const matchesStatus = statusFilter === 'all' || lead.completion_status === statusFilter
      
      return matchesSearch && matchesStatus
    })
  }, [completedLeads, searchTerm, statusFilter])

  useEffect(() => {
    refreshLeads({ is_completed: true })
  }, [refreshLeads])

  const handleLeadClick = (lead: Lead) => {
    setSelectedLead(lead)
    setIsModalOpen(true)
  }

  const handleComplete = (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => {
    // This would typically update the lead, but for now we'll just close the modal
    setIsModalOpen(false)
    setSelectedLead(null)
  }

  const getStatusCounts = () => {
    const counts = {
      successful: 0,
      on_the_fence: 0,
      unsuccessful: 0,
      total: completedLeads.length
    }
    
    completedLeads.forEach(lead => {
      if (lead.completion_status) {
        counts[lead.completion_status]++
      }
    })
    
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
            <h1 className="text-2xl font-bold text-gray-900">Completed Leads</h1>
            <p className="text-gray-600">View and manage all completed leads</p>
          </div>
          <div className="flex items-center space-x-4 text-sm text-gray-600">
            <div className="flex items-center space-x-1">
              <CheckCircle className="h-4 w-4 text-green-600" />
              <span>{statusCounts.successful} Successful</span>
            </div>
            <div className="flex items-center space-x-1">
              <AlertCircle className="h-4 w-4 text-yellow-600" />
              <span>{statusCounts.on_the_fence} On the Fence</span>
            </div>
            <div className="flex items-center space-x-1">
              <XCircle className="h-4 w-4 text-red-600" />
              <span>{statusCounts.unsuccessful} Unsuccessful</span>
            </div>
          </div>
        </div>

        {/* Search and Filters */}
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

          {/* Status Filter */}
          <div className="flex items-center space-x-2">
            <Filter className="h-4 w-4 text-gray-400" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as any)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-propello-blue focus:border-propello-blue"
            >
              <option value="all">All Status</option>
              <option value="successful">Successful</option>
              <option value="on_the_fence">On the Fence</option>
              <option value="unsuccessful">Unsuccessful</option>
            </select>
          </div>
        </div>
      </div>

      {/* Results Summary */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <p className="text-sm text-gray-600">
          Showing {filteredLeads.length} of {completedLeads.length} completed leads
          {searchTerm && ` matching "${searchTerm}"`}
          {statusFilter !== 'all' && ` with status "${statusFilter.replace('_', ' ')}"`}
        </p>
      </div>

      {/* Leads Grid */}
      {filteredLeads.length === 0 ? (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
          <CheckCircle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No completed leads found</h3>
          <p className="text-gray-600">
            {completedLeads.length === 0 
              ? "You haven't completed any leads yet. Mark leads as complete from the All Leads page."
              : "Try adjusting your search or filter criteria."
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

export default CompletedLeads
