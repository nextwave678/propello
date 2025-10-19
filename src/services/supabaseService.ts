import { supabase } from '../lib/supabase'
import { Lead, LeadFilters, AnalyticsData } from '../types/lead.types'

export class SupabaseService {
  static async getLeads(filters?: LeadFilters): Promise<Lead[]> {
    try {
      let query = supabase
        .from('leads')
        .select('*')
        .order('created_at', { ascending: false })

      if (filters) {
        if (filters.quality) {
          query = query.eq('lead_quality', filters.quality)
        }
        if (filters.type) {
          query = query.eq('type', filters.type)
        }
        if (filters.status) {
          query = query.eq('status', filters.status)
        }
        if (filters.completion_status) {
          query = query.eq('completion_status', filters.completion_status)
        }
        if (filters.is_completed !== undefined) {
          if (filters.is_completed) {
            query = query.not('completion_status', 'is', null)
          } else {
            query = query.is('completion_status', null)
          }
        }
        if (filters.is_archived !== undefined) {
          query = query.eq('is_archived', filters.is_archived)
        }
        if (filters.search) {
          query = query.or(`name.ilike.%${filters.search}%,phone.ilike.%${filters.search}%,email.ilike.%${filters.search}%`)
        }
      }

      const { data, error } = await query

      if (error) {
        console.error('Error fetching leads:', error)
        throw new Error(`Failed to fetch leads: ${error.message}`)
      }

      return data || []
    } catch (error) {
      console.error('SupabaseService.getLeads error:', error)
      throw error
    }
  }

  static async updateLead(id: string, updates: Partial<Lead>): Promise<Lead> {
    try {
      const { data, error } = await supabase
        .from('leads')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single()

      if (error) {
        console.error('Error updating lead:', error)
        throw new Error(`Failed to update lead: ${error.message}`)
      }

      return data
    } catch (error) {
      console.error('SupabaseService.updateLead error:', error)
      throw error
    }
  }

  static async addNote(leadId: string, note: string): Promise<Lead> {
    try {
      // First get the current lead to append the note
      const { data: lead, error: fetchError } = await supabase
        .from('leads')
        .select('notes')
        .eq('id', leadId)
        .single()

      if (fetchError) {
        throw new Error(`Failed to fetch lead: ${fetchError.message}`)
      }

      const updatedNotes = [...(lead.notes || []), note]

      const { data, error } = await supabase
        .from('leads')
        .update({
          notes: updatedNotes,
          updated_at: new Date().toISOString()
        })
        .eq('id', leadId)
        .select()
        .single()

      if (error) {
        console.error('Error adding note:', error)
        throw new Error(`Failed to add note: ${error.message}`)
      }

      return data
    } catch (error) {
      console.error('SupabaseService.addNote error:', error)
      throw error
    }
  }

  static async getAnalytics(): Promise<AnalyticsData> {
    try {
      // Get all leads for analytics
      const { data: leads, error: leadsError } = await supabase
        .from('leads')
        .select('*')

      if (leadsError) {
        throw new Error(`Failed to fetch leads for analytics: ${leadsError.message}`)
      }

      // Get recent activities
      const { data: activities, error: activitiesError } = await supabase
        .from('lead_activities')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10)

      if (activitiesError) {
        console.warn('Failed to fetch activities:', activitiesError)
      }

      const totalLeads = leads?.length || 0
      
      const leadsByQuality = leads?.reduce((acc, lead) => {
        acc[lead.lead_quality]++
        return acc
      }, { hot: 0, warm: 0, cold: 0 }) || { hot: 0, warm: 0, cold: 0 }
      
      const leadsByStatus = leads?.reduce((acc, lead) => {
        acc[lead.status]++
        return acc
      }, { new: 0, contacted: 0, qualified: 0, closed: 0, dead: 0 }) || { new: 0, contacted: 0, qualified: 0, closed: 0, dead: 0 }
      
      const leadsByType = leads?.reduce((acc, lead) => {
        acc[lead.type]++
        return acc
      }, { buyer: 0, seller: 0 }) || { buyer: 0, seller: 0 }
      
      const conversionRate = leadsByStatus.qualified / totalLeads * 100

      return {
        totalLeads,
        leadsByQuality,
        leadsByStatus,
        leadsByType,
        conversionRate,
        recentActivity: activities || [],
        qualityTrends: [] // TODO: Implement quality trends
      }
    } catch (error) {
      console.error('SupabaseService.getAnalytics error:', error)
      throw error
    }
  }

  static subscribeToLeads(callback: (payload: any) => void) {
    const subscription = supabase
      .channel('leads_changes')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'leads' },
        callback
      )
      .subscribe()

    return {
      unsubscribe: () => {
        supabase.removeChannel(subscription)
      }
    }
  }

  static subscribeToActivities(callback: (payload: any) => void) {
    const subscription = supabase
      .channel('activities_changes')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'lead_activities' },
        callback
      )
      .subscribe()

    return {
      unsubscribe: () => {
        supabase.removeChannel(subscription)
      }
    }
  }
}