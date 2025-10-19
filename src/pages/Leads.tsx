import React, { useState } from 'react'
import { useLeads } from '../context/LeadsContext'
import LeadCard from '../components/leads/LeadCard'
import CompletionModal from '../components/leads/CompletionModal'
import { LeadFilters, Lead } from '../types/lead.types'
import { Search, Filter, X } from 'lucide-react'

const Leads: React.FC = () => {
  const { leads, loading, error, refreshLeads, markLeadComplete } = useLeads()
  const [filters, setFilters] = useState<LeadFilters>({})
  const [showFilters, setShowFilters] = useState(false)
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleFilterChange = (newFilters: LeadFilters) => {
    setFilters(newFilters)
    refreshLeads(newFilters)
  }

  const clearFilters = () => {
    setFilters({})
    refreshLeads()
  }

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
          <X className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Error Loading Leads</h3>
          <p className="text-gray-600">{error}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">All Leads</h1>
          <p className="mt-2 text-gray-600">
            {leads.length} total leads
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="btn-secondary flex items-center"
          >
            <Filter className="h-4 w-4 mr-2" />
            Filters
          </button>
        </div>
      </div>

      {/* Filters */}
      {showFilters && (
        <div className="propello-card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Filter Leads</h3>
            <button
              onClick={clearFilters}
              className="text-sm text-propello-blue hover:text-propello-blue-700"
            >
              Clear all
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Quality
              </label>
              <select
                value={filters.quality || ''}
                onChange={(e) => handleFilterChange({ ...filters, quality: e.target.value as any || undefined })}
                className="propello-select"
              >
                <option value="">All Qualities</option>
                <option value="hot">Hot</option>
                <option value="warm">Warm</option>
                <option value="cold">Cold</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Type
              </label>
              <select
                value={filters.type || ''}
                onChange={(e) => handleFilterChange({ ...filters, type: e.target.value as any || undefined })}
                className="propello-select"
              >
                <option value="">All Types</option>
                <option value="buyer">Buyer</option>
                <option value="seller">Seller</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                value={filters.status || ''}
                onChange={(e) => handleFilterChange({ ...filters, status: e.target.value as any || undefined })}
                className="propello-select"
              >
                <option value="">All Statuses</option>
                <option value="new">New</option>
                <option value="contacted">Contacted</option>
                <option value="qualified">Qualified</option>
                <option value="closed">Closed</option>
                <option value="dead">Dead</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Search
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search leads..."
                  value={filters.search || ''}
                  onChange={(e) => handleFilterChange({ ...filters, search: e.target.value || undefined })}
                  className="propello-input pl-10"
                />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Leads Grid */}
      {leads.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <Search className="h-12 w-12 mx-auto" />
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No leads found</h3>
          <p className="text-gray-600">
            {Object.keys(filters).length > 0 
              ? "Try adjusting your filters to see more leads."
              : "Waiting for your first AI agent call. Leads will appear here in real-time."
            }
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {leads.map((lead) => (
            <LeadCard
              key={lead.id}
              lead={lead}
              onComplete={handleLeadComplete}
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
        onComplete={handleModalComplete}
      />
    </div>
  )
}

export default Leads
