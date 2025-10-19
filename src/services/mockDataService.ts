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
  },
  // More uncompleted leads
  {
    id: '11',
    created_at: '2024-01-05T11:20:00Z',
    updated_at: '2024-01-05T11:20:00Z',
    name: 'Chris Anderson',
    phone: '+1 (555) 678-9012',
    email: 'chris.a@email.com',
    type: 'buyer',
    timeframe: '6-12 months',
    property_details: 'First-time buyer, looking for starter home',
    lead_quality: 'cold',
    status: 'new',
    call_duration: 75,
    call_transcript: 'Just starting to look, very early stage',
    notes: ['Early stage buyer', 'Needs education'],
    tags: ['first-time-buyer', 'early-stage'],
    is_archived: false
  },
  {
    id: '12',
    created_at: '2024-01-04T15:45:00Z',
    updated_at: '2024-01-04T15:45:00Z',
    name: 'Maria Garcia',
    phone: '+1 (555) 789-0123',
    email: 'maria.g@email.com',
    type: 'seller',
    timeframe: '3-6 months',
    property_details: 'Investment property, looking to sell for profit',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 120,
    call_transcript: 'Interested in selling, wants market analysis',
    notes: ['Investment property', 'Wants market analysis'],
    tags: ['investment', 'market-analysis'],
    is_archived: false
  },
  // More uncompleted leads for better UI
  {
    id: '13',
    created_at: '2024-01-03T08:30:00Z',
    updated_at: '2024-01-03T08:30:00Z',
    name: 'James Wilson',
    phone: '+1 (555) 890-1234',
    email: 'james.w@email.com',
    type: 'buyer',
    timeframe: '2-4 months',
    property_details: 'Looking for waterfront property, budget $800k-$1.2M',
    lead_quality: 'hot',
    status: 'qualified',
    call_duration: 220,
    call_transcript: 'High-end buyer, very motivated, cash offer ready',
    notes: ['Cash buyer', 'Waterfront preferred', 'Quick decision maker'],
    tags: ['waterfront', 'luxury', 'cash-buyer'],
    is_archived: false
  },
  {
    id: '14',
    created_at: '2024-01-02T14:15:00Z',
    updated_at: '2024-01-02T14:15:00Z',
    name: 'Emily Brown',
    phone: '+1 (555) 901-2345',
    email: 'emily.b@email.com',
    type: 'seller',
    timeframe: '1-2 months',
    property_details: 'Historic home downtown, needs renovation',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 140,
    call_transcript: 'Inherited property, wants to sell quickly',
    notes: ['Inherited property', 'Needs quick sale', 'Historic home'],
    tags: ['historic', 'inherited', 'quick-sale'],
    is_archived: false
  },
  {
    id: '15',
    created_at: '2024-01-01T11:00:00Z',
    updated_at: '2024-01-01T11:00:00Z',
    name: 'Alex Johnson',
    phone: '+1 (555) 012-3456',
    email: 'alex.j@email.com',
    type: 'buyer',
    timeframe: '6-12 months',
    property_details: 'First-time buyer, looking for starter home',
    lead_quality: 'cold',
    status: 'new',
    call_duration: 60,
    call_transcript: 'Just starting to look, very early stage',
    notes: ['First-time buyer', 'Early stage', 'Needs education'],
    tags: ['first-time-buyer', 'starter-home', 'early-stage'],
    is_archived: false
  },
  // More completed leads - Successful
  {
    id: '16',
    created_at: '2023-12-28T09:30:00Z',
    updated_at: '2024-01-10T16:45:00Z',
    name: 'Patricia Lee',
    phone: '+1 (555) 123-4567',
    email: 'patricia.l@email.com',
    type: 'seller',
    timeframe: '1-2 months',
    property_details: 'Luxury penthouse downtown, recently renovated',
    lead_quality: 'hot',
    status: 'closed',
    call_duration: 280,
    call_transcript: 'Sold for $2.1M, 15% above asking price',
    notes: ['Sold above asking', 'Luxury market', 'Very satisfied'],
    tags: ['luxury', 'penthouse', 'above-asking'],
    is_archived: false,
    completion_status: 'successful',
    completed_at: '2024-01-10T16:45:00Z'
  },
  {
    id: '17',
    created_at: '2023-12-25T13:20:00Z',
    updated_at: '2024-01-08T12:30:00Z',
    name: 'Thomas Anderson',
    phone: '+1 (555) 234-5678',
    email: 'thomas.a@email.com',
    type: 'buyer',
    timeframe: '2-3 months',
    property_details: 'Family home in suburbs, good school district',
    lead_quality: 'hot',
    status: 'closed',
    call_duration: 200,
    call_transcript: 'Found perfect family home, closed in 30 days',
    notes: ['Family home', 'Good schools', 'Quick closing'],
    tags: ['family-home', 'suburbs', 'good-schools'],
    is_archived: false,
    completion_status: 'successful',
    completed_at: '2024-01-08T12:30:00Z'
  },
  // More completed leads - Unsuccessful
  {
    id: '18',
    created_at: '2023-12-22T16:45:00Z',
    updated_at: '2024-01-05T14:20:00Z',
    name: 'Rachel Green',
    phone: '+1 (555) 345-6789',
    email: 'rachel.g@email.com',
    type: 'buyer',
    timeframe: '3-6 months',
    property_details: 'Looking for investment property',
    lead_quality: 'cold',
    status: 'dead',
    call_duration: 80,
    call_transcript: 'Decided to work with family friend instead',
    notes: ['Went with family friend', 'Price was factor'],
    tags: ['investment', 'family-friend'],
    is_archived: false,
    completion_status: 'unsuccessful',
    completed_at: '2024-01-05T14:20:00Z'
  },
  // More on the fence leads
  {
    id: '19',
    created_at: '2023-12-20T10:15:00Z',
    updated_at: '2024-01-03T11:30:00Z',
    name: 'Kevin Park',
    phone: '+1 (555) 456-7890',
    email: 'kevin.p@email.com',
    type: 'buyer',
    timeframe: '3-6 months',
    property_details: 'Looking for modern condo, budget $400k-$600k',
    lead_quality: 'warm',
    status: 'qualified',
    call_duration: 180,
    call_transcript: 'Interested but comparing with other agents',
    notes: ['Comparing agents', 'Modern condo preferred', 'Budget conscious'],
    tags: ['modern', 'condo', 'budget-conscious'],
    is_archived: false,
    completion_status: 'on_the_fence',
    completed_at: '2024-01-03T11:30:00Z'
  },
  {
    id: '20',
    created_at: '2023-12-18T15:30:00Z',
    updated_at: '2024-01-01T09:45:00Z',
    name: 'Lisa Wang',
    phone: '+1 (555) 567-8901',
    email: 'lisa.w@email.com',
    type: 'seller',
    timeframe: '2-4 months',
    property_details: 'Townhouse in gated community, needs staging',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 160,
    call_transcript: 'Considering timing, waiting for market conditions',
    notes: ['Market timing', 'Needs staging', 'Gated community'],
    tags: ['townhouse', 'gated-community', 'staging'],
    is_archived: false,
    completion_status: 'on_the_fence',
    completed_at: '2024-01-01T09:45:00Z'
  },
  // Additional uncompleted leads
  {
    id: '21',
    created_at: '2023-12-15T12:00:00Z',
    updated_at: '2023-12-15T12:00:00Z',
    name: 'Mark Taylor',
    phone: '+1 (555) 678-9012',
    email: 'mark.t@email.com',
    type: 'buyer',
    timeframe: '4-8 months',
    property_details: 'Looking for fixer-upper investment property',
    lead_quality: 'cold',
    status: 'new',
    call_duration: 70,
    call_transcript: 'Just starting to research investment properties',
    notes: ['Investment buyer', 'Fixer-upper interested', 'Early research'],
    tags: ['investment', 'fixer-upper', 'early-research'],
    is_archived: false
  },
  {
    id: '22',
    created_at: '2023-12-12T09:45:00Z',
    updated_at: '2023-12-12T09:45:00Z',
    name: 'Jennifer Davis',
    phone: '+1 (555) 789-0123',
    email: 'jennifer.d@email.com',
    type: 'seller',
    timeframe: '2-3 months',
    property_details: 'Single family home, recently updated kitchen',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 130,
    call_transcript: 'Interested in selling, wants market analysis',
    notes: ['Updated kitchen', 'Wants market analysis', 'Flexible timing'],
    tags: ['updated-kitchen', 'market-analysis', 'flexible'],
    is_archived: false
  },
  {
    id: '23',
    created_at: '2023-12-10T14:20:00Z',
    updated_at: '2023-12-10T14:20:00Z',
    name: 'Robert Martinez',
    phone: '+1 (555) 890-1234',
    email: 'robert.m@email.com',
    type: 'buyer',
    timeframe: '1-3 months',
    property_details: 'Looking for retirement home, single story',
    lead_quality: 'warm',
    status: 'contacted',
    call_duration: 150,
    call_transcript: 'Retiring soon, needs single story home',
    notes: ['Retirement buyer', 'Single story required', 'Timing flexible'],
    tags: ['retirement', 'single-story', 'accessible'],
    is_archived: false
  },
  {
    id: '24',
    created_at: '2023-12-08T11:30:00Z',
    updated_at: '2023-12-08T11:30:00Z',
    name: 'Amanda White',
    phone: '+1 (555) 901-2345',
    email: 'amanda.w@email.com',
    type: 'seller',
    timeframe: '3-6 months',
    property_details: 'Condo downtown, high floor, city views',
    lead_quality: 'hot',
    status: 'qualified',
    call_duration: 190,
    call_transcript: 'Ready to list, has all documentation',
    notes: ['High floor', 'City views', 'All docs ready'],
    tags: ['downtown', 'high-floor', 'city-views'],
    is_archived: false
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
