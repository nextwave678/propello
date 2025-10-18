import { supabase } from '../lib/supabase'
import { Lead, LeadActivity, LeadFilters, AnalyticsData, LeadFormData } from '../types/lead.types'

export class SupabaseService {
  // Lead operations
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
        if (filters.timeframe) {
          query = query.eq('timeframe', filters.timeframe)
        }
        if (filters.assigned_to) {
          query = query.eq('assigned_to', filters.assigned_to)
        }
        if (filters.is_archived !== undefined) {
          query = query.eq('is_archived', filters.is_archived)
        }
        if (filters.dateFrom) {
          query = query.gte('created_at', filters.dateFrom)
        }
        if (filters.dateTo) {
          query = query.lte('created_at', filters.dateTo)
        }
        if (filters.search) {
          query = query.or(`name.ilike.%${filters.search}%,phone.ilike.%${filters.search}%,email.ilike.%${filters.search}%`)
        }
      }

      const { data, error } = await query

      if (error) {
        console.error('Error fetching leads:', error)
        throw error
      }

      return data || []
    } catch (error) {
      console.error('Error in getLeads:', error)
      throw error
    }
  }

  static async getLead(id: string): Promise<Lead | null> {
    try {
      const { data, error } = await supabase
        .from('leads')
        .select('*')
        .eq('id', id)
        .single()

      if (error) {
        console.error('Error fetching lead:', error)
        throw error
      }

      return data
    } catch (error) {
      console.error('Error in getLead:', error)
      throw error
    }
  }

  static async updateLead(id: string, updates: Partial<Lead>): Promise<Lead> {
    try {
      const { data, error } = await supabase
        .from('leads')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (error) {
        console.error('Error updating lead:', error)
        throw error
      }

      return data
    } catch (error) {
      console.error('Error in updateLead:', error)
      throw error
    }
  }

  static async insertLead(leadData: LeadFormData): Promise<Lead> {
    try {
      const { data, error } = await supabase
        .from('leads')
        .insert([{
          ...leadData,
          status: 'new',
          notes: leadData.notes || [],
          tags: leadData.tags || [],
          is_archived: false
        }])
        .select()
        .single()

      if (error) {
        console.error('Error inserting lead:', error)
        throw error
      }

      return data
    } catch (error) {
      console.error('Error in insertLead:', error)
      throw error
    }
  }

  static async addNote(leadId: string, note: string): Promise<Lead> {
    try {
      // Get current lead
      const lead = await this.getLead(leadId)
      if (!lead) {
        throw new Error('Lead not found')
      }

      // Add note to array
      const updatedNotes = [...lead.notes, note]

      // Update lead
      const updatedLead = await this.updateLead(leadId, { notes: updatedNotes })

      // Log activity
      await this.logActivity(leadId, 'note_added', `Note added: ${note}`)

      return updatedLead
    } catch (error) {
      console.error('Error in addNote:', error)
      throw error
    }
  }

  static async logActivity(leadId: string, activityType: string, description?: string, metadata?: Record<string, any>): Promise<LeadActivity> {
    try {
      const { data, error } = await supabase
        .from('lead_activities')
        .insert([{
          lead_id: leadId,
          activity_type: activityType,
          description,
          metadata
        }])
        .select()
        .single()

      if (error) {
        console.error('Error logging activity:', error)
        throw error
      }

      return data
    } catch (error) {
      console.error('Error in logActivity:', error)
      throw error
    }
  }

  static async getActivities(leadId: string): Promise<LeadActivity[]> {
    try {
      const { data, error } = await supabase
        .from('lead_activities')
        .select('*')
        .eq('lead_id', leadId)
        .order('created_at', { ascending: false })

      if (error) {
        console.error('Error fetching activities:', error)
        throw error
      }

      return data || []
    } catch (error) {
      console.error('Error in getActivities:', error)
      throw error
    }
  }

  static async getAnalytics(): Promise<AnalyticsData> {
    try {
      // Get total leads
      const { count: totalLeads } = await supabase
        .from('leads')
        .select('*', { count: 'exact', head: true })
        .eq('is_archived', false)

      // Get leads by quality
      const { data: qualityData } = await supabase
        .from('leads')
        .select('lead_quality')
        .eq('is_archived', false)

      const leadsByQuality = {
        hot: qualityData?.filter(l => l.lead_quality === 'hot').length || 0,
        warm: qualityData?.filter(l => l.lead_quality === 'warm').length || 0,
        cold: qualityData?.filter(l => l.lead_quality === 'cold').length || 0,
      }

      // Get leads by status
      const { data: statusData } = await supabase
        .from('leads')
        .select('status')
        .eq('is_archived', false)

      const leadsByStatus = {
        new: statusData?.filter(l => l.status === 'new').length || 0,
        contacted: statusData?.filter(l => l.status === 'contacted').length || 0,
        qualified: statusData?.filter(l => l.status === 'qualified').length || 0,
        closed: statusData?.filter(l => l.status === 'closed').length || 0,
        dead: statusData?.filter(l => l.status === 'dead').length || 0,
      }

      // Get leads by type
      const { data: typeData } = await supabase
        .from('leads')
        .select('type')
        .eq('is_archived', false)

      const leadsByType = {
        buyer: typeData?.filter(l => l.type === 'buyer').length || 0,
        seller: typeData?.filter(l => l.type === 'seller').length || 0,
      }

      // Calculate conversion rate
      const conversionRate = totalLeads ? (leadsByStatus.closed / totalLeads) * 100 : 0

      // Get recent activity
      const { data: recentActivity } = await supabase
        .from('lead_activities')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10)

      // Get quality trends (last 7 days)
      const sevenDaysAgo = new Date()
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

      const { data: trendData } = await supabase
        .from('leads')
        .select('created_at, lead_quality')
        .gte('created_at', sevenDaysAgo.toISOString())
        .eq('is_archived', false)

      // Process trend data
      const qualityTrends = this.processQualityTrends(trendData || [])

      return {
        totalLeads: totalLeads || 0,
        leadsByQuality,
        leadsByStatus,
        leadsByType,
        conversionRate,
        recentActivity: recentActivity || [],
        qualityTrends
      }
    } catch (error) {
      console.error('Error in getAnalytics:', error)
      throw error
    }
  }

  private static processQualityTrends(data: any[]): any[] {
    const trends: { [key: string]: { hot: number; warm: number; cold: number } } = {}

    data.forEach(lead => {
      const date = new Date(lead.created_at).toISOString().split('T')[0]
      if (!trends[date]) {
        trends[date] = { hot: 0, warm: 0, cold: 0 }
      }
      trends[date][lead.lead_quality as keyof typeof trends[typeof date]]++
    })

    return Object.entries(trends).map(([date, counts]) => ({
      date,
      ...counts
    }))
  }

  // Real-time subscriptions
  static subscribeToLeads(callback: (payload: any) => void) {
    return supabase
      .channel('leads_changes')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'leads' },
        callback
      )
      .subscribe()
  }

  static subscribeToActivities(callback: (payload: any) => void) {
    return supabase
      .channel('activities_changes')
      .on('postgres_changes',
        { event: '*', schema: 'public', table: 'lead_activities' },
        callback
      )
      .subscribe()
  }
}
