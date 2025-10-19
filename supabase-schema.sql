-- Create the leads table
CREATE TABLE IF NOT EXISTS public.leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    type TEXT NOT NULL CHECK (type IN ('buyer', 'seller')),
    timeframe TEXT NOT NULL,
    property_details TEXT,
    lead_quality TEXT NOT NULL CHECK (lead_quality IN ('hot', 'warm', 'cold')),
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed', 'dead')),
    call_duration INTEGER,
    call_transcript TEXT,
    call_recording_url TEXT,
    notes TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    assigned_to UUID REFERENCES auth.users(id),
    is_archived BOOLEAN DEFAULT false,
    completion_status TEXT CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create the lead_activities table
CREATE TABLE IF NOT EXISTS public.lead_activities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    lead_id UUID NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
    performed_by UUID REFERENCES auth.users(id),
    activity_type TEXT NOT NULL,
    description TEXT,
    metadata JSONB
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_leads_completion_status ON public.leads(completion_status);
CREATE INDEX IF NOT EXISTS idx_leads_lead_quality ON public.leads(lead_quality);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_type ON public.leads(type);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON public.leads(created_at);
CREATE INDEX IF NOT EXISTS idx_lead_activities_lead_id ON public.lead_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_activities_created_at ON public.lead_activities(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for leads table
CREATE POLICY "Users can view all leads" ON public.leads
    FOR SELECT USING (true);

CREATE POLICY "Users can insert leads" ON public.leads
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update leads" ON public.leads
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete leads" ON public.leads
    FOR DELETE USING (true);

-- Create RLS policies for lead_activities table
CREATE POLICY "Users can view all lead activities" ON public.lead_activities
    FOR SELECT USING (true);

CREATE POLICY "Users can insert lead activities" ON public.lead_activities
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update lead activities" ON public.lead_activities
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete lead activities" ON public.lead_activities
    FOR DELETE USING (true);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER handle_leads_updated_at
    BEFORE UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert some sample data
INSERT INTO public.leads (
    name, phone, email, type, timeframe, property_details, lead_quality, status, 
    call_duration, call_transcript, notes, tags, completion_status, completed_at
) VALUES 
-- Successful completed leads
('Jennifer Martinez', '+1 (555) 789-0123', 'jennifer.m@email.com', 'buyer', '1-2 months', '3BR house in family neighborhood, good schools', 'hot', 'closed', 240, 'Found perfect home, ready to make offer', ARRAY['Found dream home', 'Offer accepted', 'Closing scheduled'], ARRAY['family-home', 'good-schools'], 'successful', '2024-01-16T14:30:00Z'),
('David Thompson', '+1 (555) 234-5678', 'david.t@email.com', 'seller', '2-3 months', 'Luxury townhouse, recently renovated', 'hot', 'closed', 180, 'Sold above asking price, very satisfied', ARRAY['Sold above asking', 'Happy with service', 'Referred friend'], ARRAY['luxury', 'renovated', 'referral'], 'successful', '2024-01-15T10:45:00Z'),
('Patricia Lee', '+1 (555) 123-4567', 'patricia.l@email.com', 'seller', '1-2 months', 'Luxury penthouse downtown, recently renovated', 'hot', 'closed', 280, 'Sold for $2.1M, 15% above asking price', ARRAY['Sold above asking', 'Luxury market', 'Very satisfied'], ARRAY['luxury', 'penthouse', 'above-asking'], 'successful', '2024-01-10T16:45:00Z'),
('Thomas Anderson', '+1 (555) 234-5678', 'thomas.a@email.com', 'buyer', '2-3 months', 'Family home in suburbs, good school district', 'hot', 'closed', 200, 'Found perfect family home, closed in 30 days', ARRAY['Family home', 'Good schools', 'Quick closing'], ARRAY['family-home', 'suburbs', 'good-schools'], 'successful', '2024-01-08T12:30:00Z'),

-- Unsuccessful completed leads
('Amanda Foster', '+1 (555) 345-6789', 'amanda.f@email.com', 'buyer', '3-6 months', 'Looking for investment property', 'cold', 'dead', 90, 'Decided to work with different agent', ARRAY['Went with competitor', 'Price was main factor'], ARRAY['investment', 'price-sensitive'], 'unsuccessful', '2024-01-14T11:20:00Z'),
('Rachel Green', '+1 (555) 345-6789', 'rachel.g@email.com', 'buyer', '3-6 months', 'Looking for investment property', 'cold', 'dead', 80, 'Decided to work with family friend instead', ARRAY['Went with family friend', 'Price was factor'], ARRAY['investment', 'family-friend'], 'unsuccessful', '2024-01-05T14:20:00Z'),

-- On the fence leads
('Michael Rodriguez', '+1 (555) 456-7890', 'michael.r@email.com', 'buyer', '2-4 months', 'Looking for condo downtown, budget flexible', 'warm', 'qualified', 200, 'Interested but still comparing options', ARRAY['Comparing with other agents', 'Budget flexible', 'Needs more time'], ARRAY['downtown', 'condo', 'flexible-budget'], 'on_the_fence', '2024-01-13T15:30:00Z'),
('Sarah Kim', '+1 (555) 567-8901', 'sarah.k@email.com', 'seller', '1-3 months', 'Family home, needs to sell for relocation', 'warm', 'contacted', 160, 'Considering timing, waiting for job confirmation', ARRAY['Job relocation pending', 'Timing uncertain', 'Follow up in 2 weeks'], ARRAY['relocation', 'timing-sensitive'], 'on_the_fence', '2024-01-12T09:15:00Z'),
('Kevin Park', '+1 (555) 456-7890', 'kevin.p@email.com', 'buyer', '3-6 months', 'Looking for modern condo, budget $400k-$600k', 'warm', 'qualified', 180, 'Interested but comparing with other agents', ARRAY['Comparing agents', 'Modern condo preferred', 'Budget conscious'], ARRAY['modern', 'condo', 'budget-conscious'], 'on_the_fence', '2024-01-03T11:30:00Z'),
('Lisa Wang', '+1 (555) 567-8901', 'lisa.w@email.com', 'seller', '2-4 months', 'Townhouse in gated community, needs staging', 'warm', 'contacted', 160, 'Considering timing, waiting for market conditions', ARRAY['Market timing', 'Needs staging', 'Gated community'], ARRAY['townhouse', 'gated-community', 'staging'], 'on_the_fence', '2024-01-01T09:45:00Z'),

-- Uncompleted leads
('John Smith', '+1 (555) 123-4567', 'john.smith@email.com', 'buyer', '3-6 months', 'Looking for 3BR house in downtown area, budget $500k-$700k', 'hot', 'new', 180, 'Very interested in purchasing, has pre-approval letter ready', ARRAY['Called during business hours', 'Has pre-approval letter'], ARRAY['first-time-buyer', 'downtown'], false),
('Sarah Johnson', '+1 (555) 987-6543', 'sarah.j@email.com', 'seller', '1-2 months', '3BR/2BA house in suburbs, needs to sell quickly', 'warm', 'contacted', 120, 'Motivated seller, needs to relocate for job', ARRAY['Relocating for work', 'Flexible on price'], ARRAY['relocation', 'motivated-seller'], false),
('Mike Davis', '+1 (555) 456-7890', 'mike.davis@email.com', 'buyer', '6-12 months', 'Investment property, looking for rental income', 'cold', 'new', 90, 'Just starting to look, not in a rush', ARRAY['Investment buyer', 'First time investor'], ARRAY['investment', 'rental'], false),
('Lisa Chen', '+1 (555) 321-0987', 'lisa.chen@email.com', 'seller', '2-3 months', 'Luxury condo downtown, high-end finishes', 'hot', 'qualified', 200, 'Ready to list, has all documentation', ARRAY['Luxury market', 'All docs ready'], ARRAY['luxury', 'downtown', 'condo'], false),
('Robert Wilson', '+1 (555) 654-3210', 'robert.w@email.com', 'buyer', '1-3 months', 'First home, looking for starter house', 'warm', 'contacted', 150, 'First-time buyer, needs guidance', ARRAY['First-time buyer', 'Needs pre-approval'], ARRAY['first-time-buyer', 'starter-home'], false),
('Maria Garcia', '+1 (555) 789-0123', 'maria.g@email.com', 'seller', '3-6 months', 'Investment property, looking to sell for profit', 'warm', 'contacted', 120, 'Interested in selling, wants market analysis', ARRAY['Investment property', 'Wants market analysis'], ARRAY['investment', 'market-analysis'], false),
('James Wilson', '+1 (555) 890-1234', 'james.w@email.com', 'buyer', '2-4 months', 'Looking for waterfront property, budget $800k-$1.2M', 'hot', 'qualified', 220, 'High-end buyer, very motivated, cash offer ready', ARRAY['Cash buyer', 'Waterfront preferred', 'Quick decision maker'], ARRAY['waterfront', 'luxury', 'cash-buyer'], false),
('Emily Brown', '+1 (555) 901-2345', 'emily.b@email.com', 'seller', '1-2 months', 'Historic home downtown, needs renovation', 'warm', 'contacted', 140, 'Inherited property, wants to sell quickly', ARRAY['Inherited property', 'Needs quick sale', 'Historic home'], ARRAY['historic', 'inherited', 'quick-sale'], false),
('Alex Johnson', '+1 (555) 012-3456', 'alex.j@email.com', 'buyer', '6-12 months', 'First-time buyer, looking for starter home', 'cold', 'new', 60, 'Just starting to look, very early stage', ARRAY['First-time buyer', 'Early stage', 'Needs education'], ARRAY['first-time-buyer', 'starter-home', 'early-stage'], false),
('Mark Taylor', '+1 (555) 678-9012', 'mark.t@email.com', 'buyer', '4-8 months', 'Looking for fixer-upper investment property', 'cold', 'new', 70, 'Just starting to research investment properties', ARRAY['Investment buyer', 'Fixer-upper interested', 'Early research'], ARRAY['investment', 'fixer-upper', 'early-research'], false),
('Jennifer Davis', '+1 (555) 789-0123', 'jennifer.d@email.com', 'seller', '2-3 months', 'Single family home, recently updated kitchen', 'warm', 'contacted', 130, 'Interested in selling, wants market analysis', ARRAY['Updated kitchen', 'Wants market analysis', 'Flexible timing'], ARRAY['updated-kitchen', 'market-analysis', 'flexible'], false),
('Robert Martinez', '+1 (555) 890-1234', 'robert.m@email.com', 'buyer', '1-3 months', 'Looking for retirement home, single story', 'warm', 'contacted', 150, 'Retiring soon, needs single story home', ARRAY['Retirement buyer', 'Single story required', 'Timing flexible'], ARRAY['retirement', 'single-story', 'accessible'], false),
('Amanda White', '+1 (555) 901-2345', 'amanda.w@email.com', 'seller', '3-6 months', 'Condo downtown, high floor, city views', 'hot', 'qualified', 190, 'Ready to list, has all documentation', ARRAY['High floor', 'City views', 'All docs ready'], ARRAY['downtown', 'high-floor', 'city-views'], false);

-- Insert some sample activities
INSERT INTO public.lead_activities (lead_id, activity_type, description, metadata) VALUES 
((SELECT id FROM public.leads WHERE name = 'John Smith' LIMIT 1), 'call', 'Initial contact call', '{"duration": 180}'),
((SELECT id FROM public.leads WHERE name = 'Sarah Johnson' LIMIT 1), 'email', 'Sent property information', '{"email_type": "info"}'),
((SELECT id FROM public.leads WHERE name = 'Mike Davis' LIMIT 1), 'call', 'Qualification call', '{"duration": 90}'),
((SELECT id FROM public.leads WHERE name = 'Jennifer Martinez' LIMIT 1), 'call', 'Property showing', '{"duration": 240}'),
((SELECT id FROM public.leads WHERE name = 'David Thompson' LIMIT 1), 'call', 'Closing call', '{"duration": 180}');
