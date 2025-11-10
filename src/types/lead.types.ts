export interface Lead {
  id: string
  created_at: string
  updated_at: string
  name: string
  phone: string
  email?: string
  type: 'buyer' | 'seller'
  timeframe: string
  property_details?: string
  lead_quality: 'hot' | 'warm' | 'cold'
  status: 'new' | 'contacted' | 'qualified' | 'closed' | 'dead'
  call_duration?: number
  call_transcript?: string
  call_recording_url?: string
  notes: string[]
  tags: string[]
  assigned_to?: string
  is_archived: boolean
  completion_status?: 'incomplete' | 'successful' | 'on_the_fence' | 'unsuccessful'
  completed_at?: string
}

export interface LeadActivity {
  id: string
  created_at: string
  lead_id: string
  performed_by?: string
  activity_type: string
  description?: string
  metadata?: Record<string, any>
}

export interface LeadFilters {
  quality?: 'hot' | 'warm' | 'cold'
  type?: 'buyer' | 'seller'
  status?: 'new' | 'contacted' | 'qualified' | 'closed' | 'dead'
  timeframe?: string
  search?: string
  dateFrom?: string
  dateTo?: string
  assigned_to?: string
  is_archived?: boolean
  completion_status?: 'incomplete' | 'successful' | 'on_the_fence' | 'unsuccessful'
  is_completed?: boolean
  // Pagination
  page?: number
  pageSize?: number
}

export interface PaginatedLeadsResponse {
  data: Lead[]
  count: number
  page: number
  pageSize: number
  totalPages: number
}

export interface AnalyticsData {
  totalLeads: number
  leadsByQuality: {
    hot: number
    warm: number
    cold: number
  }
  leadsByStatus: {
    new: number
    contacted: number
    qualified: number
    closed: number
    dead: number
  }
  leadsByType: {
    buyer: number
    seller: number
  }
  conversionRate: number
  recentActivity: LeadActivity[]
  qualityTrends: {
    date: string
    hot: number
    warm: number
    cold: number
  }[]
}

export interface LeadFormData {
  name: string
  phone: string
  email?: string
  type: 'buyer' | 'seller'
  timeframe: string
  property_details?: string
  lead_quality: 'hot' | 'warm' | 'cold'
  call_duration?: number
  call_transcript?: string
  call_recording_url?: string
  notes?: string[]
  tags?: string[]
}


