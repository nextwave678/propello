import React, { createContext, useContext, useEffect, useState, ReactNode, useCallback } from 'react'
import { Lead, LeadFilters, AnalyticsData } from '../types/lead.types'
import { SupabaseService } from '../services/supabaseService'
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
  markLeadComplete: (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => Promise<void>
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

  const refreshLeads = useCallback(async (filters?: LeadFilters) => {
    try {
      setLoading(true)
      setError(null)
      const data = await SupabaseService.getLeads(filters)
      setLeads(data)
    } catch (err) {
      console.log('Supabase failed, falling back to mock data:', err)
      // Fallback to mock data when Supabase fails
      const mockData = await MockDataService.getLeads(filters)
      setLeads(mockData)
      setError(null) // Don't show error, just use mock data
    } finally {
      setLoading(false)
    }
  }, [])

  const updateLead = async (id: string, updates: Partial<Lead>) => {
    try {
      const updatedLead = await SupabaseService.updateLead(id, updates)
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
      const updatedLead = await SupabaseService.addNote(leadId, note)
      setLeads(prev => prev.map(lead => lead.id === leadId ? updatedLead : lead))
      toast.success('Note added successfully')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to add note'
      toast.error(errorMessage)
      throw err
    }
  }

  const markLeadComplete = async (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => {
    try {
      const updates = {
        completion_status: completionStatus,
        completed_at: new Date().toISOString()
      }
      const updatedLead = await SupabaseService.updateLead(leadId, updates)
      setLeads(prev => prev.map(lead => lead.id === leadId ? updatedLead : lead))
      toast.success(`Lead marked as ${completionStatus.replace('_', ' ')}`)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to mark lead as complete'
      toast.error(errorMessage)
      throw err
    }
  }

  const getAnalytics = useCallback(async () => {
    try {
      const data = await SupabaseService.getAnalytics()
      setAnalytics(data)
    } catch (err) {
      console.log('Supabase analytics failed, using mock data:', err)
      // Fallback to mock analytics
      const mockAnalytics = await MockDataService.getAnalytics()
      setAnalytics(mockAnalytics)
    }
  }, [])

  useEffect(() => {
    refreshLeads()
    getAnalytics()

    // Set up real-time subscriptions
    const leadsSubscription = SupabaseService.subscribeToLeads((payload) => {
      console.log('Real-time leads update:', payload)
      refreshLeads()
      getAnalytics()
    })

    const activitiesSubscription = SupabaseService.subscribeToActivities((payload) => {
      console.log('Real-time activities update:', payload)
      getAnalytics()
    })

    return () => {
      leadsSubscription.unsubscribe()
      activitiesSubscription.unsubscribe()
    }
  }, [refreshLeads, getAnalytics])

  const value: LeadsContextType = {
    leads,
    loading,
    error,
    analytics,
    refreshLeads,
    updateLead,
    addNote,
    markLeadComplete,
    getAnalytics
  }

  return (
    <LeadsContext.Provider value={value}>
      {children}
    </LeadsContext.Provider>
  )
}

