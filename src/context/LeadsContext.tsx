import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { Lead, LeadFilters, AnalyticsData } from '../types/lead.types'
import { MockDataService } from '../services/mockDataService'
import toast from 'react-hot-toast'

interface LeadsContextType {
  leads: Lead[]
  loading: boolean
  error: string | null
  analytics: AnalyticsData | null
  refreshLeads: (filters?: LeadFilters) => Promise<void>
  updateLead: (id: string, updates: Partial<Lead>) => Promise<void>
  addNote: (leadId: string, note: string) => Promise<void>
  getAnalytics: () => Promise<void>
}

const LeadsContext = createContext<LeadsContextType | undefined>(undefined)

export const useLeads = () => {
  const context = useContext(LeadsContext)
  if (context === undefined) {
    throw new Error('useLeads must be used within a LeadsProvider')
  }
  return context
}

interface LeadsProviderProps {
  children: ReactNode
}

export const LeadsProvider: React.FC<LeadsProviderProps> = ({ children }) => {
  const [leads, setLeads] = useState<Lead[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null)

  const refreshLeads = async (filters?: LeadFilters) => {
    try {
      setLoading(true)
      setError(null)
      const data = await MockDataService.getLeads(filters)
      setLeads(data)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch leads'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const updateLead = async (id: string, updates: Partial<Lead>) => {
    try {
      const updatedLead = await MockDataService.updateLead(id, updates)
      setLeads(prev => prev.map(lead => lead.id === id ? updatedLead : lead))
      toast.success('Lead updated successfully')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to update lead'
      toast.error(errorMessage)
      throw err
    }
  }

  const addNote = async (leadId: string, note: string) => {
    try {
      const updatedLead = await MockDataService.addNote(leadId, note)
      setLeads(prev => prev.map(lead => lead.id === leadId ? updatedLead : lead))
      toast.success('Note added successfully')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to add note'
      toast.error(errorMessage)
      throw err
    }
  }

  const getAnalytics = async () => {
    try {
      const data = await MockDataService.getAnalytics()
      setAnalytics(data)
    } catch (err) {
      console.error('Failed to fetch analytics:', err)
    }
  }

  useEffect(() => {
    refreshLeads()
    getAnalytics()

    // Set up mock subscriptions (no real-time for demo)
    const leadsSubscription = MockDataService.subscribeToLeads((payload) => {
      console.log('Mock real-time update:', payload)
      refreshLeads()
      getAnalytics()
    })

    const activitiesSubscription = MockDataService.subscribeToActivities((payload) => {
      console.log('Mock activity update:', payload)
      getAnalytics()
    })

    return () => {
      leadsSubscription.unsubscribe()
      activitiesSubscription.unsubscribe()
    }
  }, [])

  const value: LeadsContextType = {
    leads,
    loading,
    error,
    analytics,
    refreshLeads,
    updateLead,
    addNote,
    getAnalytics
  }

  return (
    <LeadsContext.Provider value={value}>
      {children}
    </LeadsContext.Provider>
  )
}

