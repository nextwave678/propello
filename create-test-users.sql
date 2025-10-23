-- Create Test Users for Propello
-- This creates user profiles that can be used with the signup flow

-- Insert user profiles (these will be linked when users sign up)
INSERT INTO public.user_profiles (
    user_id,
    email,
    full_name,
    company_name,
    agent_phone_number,
    agent_id,
    plan,
    is_active
) VALUES
(
    '00000000-0000-0000-0000-000000000001',
    'sarah@premierrealty.com',
    'Sarah Johnson',
    'Premier Realty Group',
    '+1-555-0101',
    'SARAH-J-2024',
    'premium',
    true
),
(
    '00000000-0000-0000-0000-000000000002',
    'michael@luxuryhomes.com',
    'Michael Chen',
    'Luxury Homes Realty',
    '+1-555-0102',
    'MICHAEL-C-2024',
    'premium',
    true
)
ON CONFLICT (email) DO NOTHING;

-- Add some sample leads for testing
INSERT INTO public.leads (
    name,
    phone,
    email,
    type,
    timeframe,
    property_details,
    lead_quality,
    status,
    call_duration,
    call_transcript,
    notes,
    tags,
    is_archived,
    completion_status,
    completed_at,
    agent_phone_number,
    source
) VALUES
-- Sarah's leads
('John Smith', '+1-555-1001', 'john.smith@email.com', 'buyer', '3-6 months', 'Looking for 3BR house in downtown area, budget $500k-$700k', 'hot', 'new', 180, 'Very interested in purchasing, has pre-approval letter ready', ARRAY['Called during business hours', 'Has pre-approval letter'], ARRAY['first-time-buyer', 'downtown'], false, NULL, NULL, '+1-555-0101', 'website'),
('Jane Doe', '+1-555-1002', 'jane.doe@email.com', 'seller', '1-3 months', 'Selling 4BR house in suburban area, recently renovated', 'warm', 'contacted', 240, 'Sent comparative market analysis, awaiting response', ARRAY['Follow-up scheduled', 'CMA sent'], ARRAY['renovated', 'suburban'], false, 'successful', '2024-01-15T10:00:00Z', '+1-555-0101', 'referral'),
('Peter Jones', '+1-555-1003', 'peter.j@email.com', 'buyer', '6-12 months', 'Interested in investment properties, multi-family units', 'cold', 'qualified', 120, 'Discussed investment strategy, needs more research', ARRAY['Sent investment guide'], ARRAY['investor', 'multi-family'], false, 'on_the_fence', '2024-01-16T14:30:00Z', '+1-555-0101', 'cold-call'),

-- Michael's leads
('Alice Brown', '+1-555-2001', 'alice.b@email.com', 'seller', '3-6 months', 'Selling condo near university, quick sale preferred', 'hot', 'new', 300, 'Ready to list, needs staging advice', ARRAY['Staging consultation booked'], ARRAY['condo', 'university'], false, NULL, NULL, '+1-555-0102', 'website'),
('Robert White', '+1-555-2002', 'robert.w@email.com', 'buyer', 'Immediate', 'Cash buyer for distressed property, any area', 'hot', 'closed', 400, 'Offer accepted on 123 Main St, closing next month', ARRAY['Offer accepted', 'Closing scheduled'], ARRAY['cash-buyer', 'distressed'], false, 'successful', '2024-01-10T10:00:00Z', '+1-555-0102', 'referral'),
('Jennifer Martinez', '+1-555-2003', 'jennifer.m@email.com', 'buyer', '1-2 months', '3BR house in family neighborhood, good schools', 'hot', 'closed', 240, 'Found perfect home, ready to make offer', ARRAY['Found dream home', 'Offer accepted', 'Closing scheduled'], ARRAY['family-home', 'good-schools'], false, 'unsuccessful', '2024-01-12T11:00:00Z', '+1-555-0102', 'open-house');
