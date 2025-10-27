import { Lead, LeadFilters, AnalyticsData, LeadActivity } from '../types/lead.types'

// Mock data
const mockLeads: Lead[] = [
  {
    id: '1',
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-01-15T10:30:00Z',
    name: 'John Smith',
    phone: '+1 (555) 123-4567',
    email: 'john.smith@email.com',
    type: 'buyer',
    timeframe: '3-6 months',
    property_details: 'Looking for 3BR house in downtown area, budget $500k-$700k',
    lead_quality: 'hot',
    status: 'new',
    call_duration: 180,
    call_transcript: 'Very interested in purchasing, has pre-approval letter ready',
    notes: ['Called during business hours', 'Has pre-approval letter'],
    tags: ['first-time-buyer', 'downtown'],
    is_archived: false
  },
  {
    id: '2',
    created_at: '2024-01-14T14:20:00Z',
    updated_at: '2024-01-14T14:20:00Z',
    name: 'Sarah Johnson',
    phone: '+1 (555) 987-6543',
    email: 'sarah.j@email.com',
    type: 'seller',
    timeframe: '1-2 months',
    property_details: '3BR/2BA house in suburbs, needs to sell quickly',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 120,
    call_transcript: 'Motivated seller, needs to relocate for job',
    notes: ['Relocating for work', 'Flexible on price'],
    tags: ['relocation', 'motivated-seller'],
    is_archived: false
  },
  {
    id: '3',
    created_at: '2024-01-13T09:15:00Z',
    updated_at: '2024-01-13T09:15:00Z',
    name: 'Mike Davis',
    phone: '+1 (555) 456-7890',
    email: 'mike.davis@email.com',
    type: 'buyer',
    timeframe: '6-12 months',
    property_details: 'Investment property, looking for rental income',
    lead_quality: 'cold',
    status: 'new',
    call_duration: 90,
    call_transcript: 'Just starting to look, not in a rush',
    notes: ['Investment buyer', 'First time investor'],
    tags: ['investment', 'rental'],
    is_archived: false
  },
  {
    id: '4',
    created_at: '2024-01-12T16:45:00Z',
    updated_at: '2024-01-12T16:45:00Z',
    name: 'Lisa Chen',
    phone: '+1 (555) 321-0987',
    email: 'lisa.chen@email.com',
    type: 'seller',
    timeframe: '2-3 months',
    property_details: 'Luxury condo downtown, high-end finishes',
    lead_quality: 'hot',
    status: 'qualified',
    call_duration: 200,
    call_transcript: 'Ready to list, has all documentation',
    notes: ['Luxury market', 'All docs ready'],
    tags: ['luxury', 'downtown', 'condo'],
    is_archived: false
  },
  {
    id: '5',
    created_at: '2024-01-11T11:30:00Z',
    updated_at: '2024-01-11T11:30:00Z',
    name: 'Robert Wilson',
    phone: '+1 (555) 654-3210',
    email: 'robert.w@email.com',
    type: 'buyer',
    timeframe: '1-3 months',
    property_details: 'First home, looking for starter house',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 150,
    call_transcript: 'First-time buyer, needs guidance',
    notes: ['First-time buyer', 'Needs pre-approval'],
    tags: ['first-time-buyer', 'starter-home'],
    is_archived: false
  },
  // Completed leads - Successful
  {
    id: '6',
    created_at: '2024-01-10T09:00:00Z',
    updated_at: '2024-01-16T14:30:00Z',
    name: 'Jennifer Martinez',
    phone: '+1 (555) 789-0123',
    email: 'jennifer.m@email.com',
    type: 'buyer',
    timeframe: '1-2 months',
    property_details: '3BR house in family neighborhood, good schools',
    lead_quality: 'hot',
    status: 'closed',
    call_duration: 240,
    call_transcript: 'Found perfect home, ready to make offer',
    notes: ['Found dream home', 'Offer accepted', 'Closing scheduled'],
    tags: ['family-home', 'good-schools'],
    is_archived: false,
    completion_status: 'successful',
    completed_at: '2024-01-16T14:30:00Z'
  },
  {
    id: '7',
    created_at: '2024-01-09T13:15:00Z',
    updated_at: '2024-01-15T10:45:00Z',
    name: 'David Thompson',
    phone: '+1 (555) 234-5678',
    email: 'david.t@email.com',
    type: 'seller',
    timeframe: '2-3 months',
    property_details: 'Luxury townhouse, recently renovated',
    lead_quality: 'hot',
    status: 'closed',
    call_duration: 180,
    call_transcript: 'Sold above asking price, very satisfied',
    notes: ['Sold above asking', 'Happy with service', 'Referred friend'],
    tags: ['luxury', 'renovated', 'referral'],
    is_archived: false,
    completion_status: 'successful',
    completed_at: '2024-01-15T10:45:00Z'
  },
  // Completed leads - Unsuccessful
  {
    id: '8',
    created_at: '2024-01-08T16:20:00Z',
    updated_at: '2024-01-14T11:20:00Z',
    name: 'Amanda Foster',
    phone: '+1 (555) 345-6789',
    email: 'amanda.f@email.com',
    type: 'buyer',
    timeframe: '3-6 months',
    property_details: 'Looking for investment property',
    lead_quality: 'cold',
    status: 'dead',
    call_duration: 90,
    call_transcript: 'Decided to work with different agent',
    notes: ['Went with competitor', 'Price was main factor'],
    tags: ['investment', 'price-sensitive'],
    is_archived: false,
    completion_status: 'unsuccessful',
    completed_at: '2024-01-14T11:20:00Z'
  },
  // On the fence leads
  {
    id: '9',
    created_at: '2024-01-07T10:45:00Z',
    updated_at: '2024-01-13T15:30:00Z',
    name: 'Michael Rodriguez',
    phone: '+1 (555) 456-7890',
    email: 'michael.r@email.com',
    type: 'buyer',
    timeframe: '2-4 months',
    property_details: 'Looking for condo downtown, budget flexible',
    lead_quality: 'warm',
    status: 'qualified',
    call_duration: 200,
    call_transcript: 'Interested but still comparing options',
    notes: ['Comparing with other agents', 'Budget flexible', 'Needs more time'],
    tags: ['downtown', 'condo', 'flexible-budget'],
    is_archived: false,
    completion_status: 'on_the_fence',
    completed_at: '2024-01-13T15:30:00Z'
  },
  {
    id: '10',
    created_at: '2024-01-06T14:30:00Z',
    updated_at: '2024-01-12T09:15:00Z',
    name: 'Sarah Kim',
    phone: '+1 (555) 567-8901',
    email: 'sarah.k@email.com',
    type: 'seller',
    timeframe: '1-3 months',
    property_details: 'Family home, needs to sell for relocation',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 160,
    call_transcript: 'Considering timing, waiting for job confirmation',
    notes: ['Job relocation pending', 'Timing uncertain', 'Follow up in 2 weeks'],
    tags: ['relocation', 'timing-sensitive'],
    is_archived: false,
    completion_status: 'on_the_fence',
    completed_at: '2024-01-12T09:15:00Z'
  }
]

const mockActivities: LeadActivity[] = [
  {
    id: '1',
    created_at: '2024-01-15T10:30:00Z',
    lead_id: '1',
    activity_type: 'call',
    description: 'Initial contact call',
    metadata: { duration: 180 }
  },
  {
    id: '2',
    created_at: '2024-01-14T14:20:00Z',
    lead_id: '2',
    activity_type: 'email',
    description: 'Sent property information',
    metadata: { email_type: 'info' }
  },
  {
    id: '3',
    created_at: '2024-01-13T09:15:00Z',
    lead_id: '3',
    activity_type: 'call',
    description: 'Qualification call',
    metadata: { duration: 90 }
  }
]

export class MockDataService {
  static async getLeads(filters?: LeadFilters): Promise<Lead[]> {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500))
    
    let filteredLeads = [...mockLeads]
    
    if (filters) {
      if (filters.quality) {
        filteredLeads = filteredLeads.filter(lead => lead.lead_quality === filters.quality)
      }
      if (filters.type) {
        filteredLeads = filteredLeads.filter(lead => lead.type === filters.type)
      }
      if (filters.status) {
        filteredLeads = filteredLeads.filter(lead => lead.status === filters.status)
      }
      if (filters.search) {
        const searchLower = filters.search.toLowerCase()
        filteredLeads = filteredLeads.filter(lead => 
          lead.name.toLowerCase().includes(searchLower) ||
          lead.phone.includes(searchLower) ||
          lead.email?.toLowerCase().includes(searchLower) ||
          lead.property_details?.toLowerCase().includes(searchLower)
        )
      }
      if (filters.is_archived !== undefined) {
        filteredLeads = filteredLeads.filter(lead => lead.is_archived === filters.is_archived)
      }
      if (filters.completion_status) {
        filteredLeads = filteredLeads.filter(lead => lead.completion_status === filters.completion_status)
      }
      if (filters.is_completed !== undefined) {
        if (filters.is_completed) {
          filteredLeads = filteredLeads.filter(lead => lead.completion_status !== undefined)
        } else {
          filteredLeads = filteredLeads.filter(lead => lead.completion_status === undefined)
        }
      }
    }
    
    return filteredLeads
  }

  static async updateLead(id: string, updates: Partial<Lead>): Promise<Lead> {
    await new Promise(resolve => setTimeout(resolve, 300))
    
    const leadIndex = mockLeads.findIndex(lead => lead.id === id)
    if (leadIndex === -1) {
      throw new Error('Lead not found')
    }
    
    const updatedLead = {
      ...mockLeads[leadIndex],
      ...updates,
      updated_at: new Date().toISOString()
    }
    
    mockLeads[leadIndex] = updatedLead
    return updatedLead
  }

  static async addNote(leadId: string, note: string): Promise<Lead> {
    await new Promise(resolve => setTimeout(resolve, 300))
    
    const leadIndex = mockLeads.findIndex(lead => lead.id === leadId)
    if (leadIndex === -1) {
      throw new Error('Lead not found')
    }
    
    const updatedLead = {
      ...mockLeads[leadIndex],
      notes: [...mockLeads[leadIndex].notes, note],
      updated_at: new Date().toISOString()
    }
    
    mockLeads[leadIndex] = updatedLead
    return updatedLead
  }

  static async getAnalytics(): Promise<AnalyticsData> {
    await new Promise(resolve => setTimeout(resolve, 400))
    
    const totalLeads = mockLeads.length
    const leadsByQuality = mockLeads.reduce((acc, lead) => {
      acc[lead.lead_quality]++
      return acc
    }, { hot: 0, warm: 0, cold: 0 })
    
    const leadsByStatus = mockLeads.reduce((acc, lead) => {
      acc[lead.status]++
      return acc
    }, { new: 0, contacted: 0, qualified: 0, closed: 0, dead: 0 })
    
    const leadsByType = mockLeads.reduce((acc, lead) => {
      acc[lead.type]++
      return acc
    }, { buyer: 0, seller: 0 })
    
    const conversionRate = leadsByStatus.qualified / totalLeads * 100
    
    return {
      totalLeads,
      leadsByQuality,
      leadsByStatus,
      leadsByType,
      conversionRate,
      recentActivity: mockActivities,
      qualityTrends: [
        { date: '2024-01-10', hot: 2, warm: 1, cold: 1 },
        { date: '2024-01-11', hot: 2, warm: 2, cold: 1 },
        { date: '2024-01-12', hot: 3, warm: 2, cold: 1 },
        { date: '2024-01-13', hot: 3, warm: 2, cold: 2 },
        { date: '2024-01-14', hot: 2, warm: 3, cold: 2 },
        { date: '2024-01-15', hot: 2, warm: 2, cold: 1 }
      ]
    }
  }

  static subscribeToLeads(_callback: (payload: any) => void) {
    // Mock subscription - in real app this would connect to Supabase real-time
    return {
      unsubscribe: () => {}
    }
  }

  static subscribeToActivities(_callback: (payload: any) => void) {
    // Mock subscription - in real app this would connect to Supabase real-time
    return {
      unsubscribe: () => {}
    }
  }
}
