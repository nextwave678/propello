-- COMPREHENSIVE MOCK DATA FOR RLS TESTING
-- This creates multiple users with different agent phone numbers and their respective leads
-- This will help verify that RLS is working properly with data isolation

-- Step 1: Add test leads for the existing user (sarah.test@premierrealty.com with +1-555-888-8)
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
-- Sarah Test User's leads (+1-555-888-8)
('Alice Johnson', '+1-555-9001', 'alice.j@email.com', 'buyer', '1-2 months', 'Looking for starter home under $300k', 'hot', 'new', 120, 'Very interested, has pre-approval', ARRAY['Pre-approved', 'First-time buyer'], ARRAY['starter-home', 'first-time'], false, NULL, NULL, '+1-555-888-8', 'website'),
('Bob Smith', '+1-555-9002', 'bob.smith@email.com', 'seller', '2-3 months', 'Selling family home, needs to relocate', 'warm', 'contacted', 180, 'Motivated seller, flexible on timing', ARRAY['Relocating', 'Flexible timing'], ARRAY['family-home', 'relocation'], false, NULL, NULL, '+1-555-888-8', 'referral'),
('Carol Davis', '+1-555-9003', 'carol.davis@email.com', 'buyer', '3-6 months', 'Investment property, multi-family preferred', 'cold', 'qualified', 90, 'Just starting to look, not in rush', ARRAY['Investment buyer', 'Early stage'], ARRAY['investment', 'multi-family'], false, NULL, NULL, '+1-555-888-8', 'cold-call'),
('David Wilson', '+1-555-9004', 'david.wilson@email.com', 'seller', '1-3 months', 'Luxury condo downtown, recently renovated', 'hot', 'new', 150, 'All documents ready, motivated to sell', ARRAY['Luxury market', 'Renovated'], ARRAY['luxury', 'downtown', 'condo'], false, NULL, NULL, '+1-555-888-8', 'website'),
('Emma Brown', '+1-555-9005', 'emma.brown@email.com', 'buyer', '2-4 months', 'Looking for family home with good schools', 'warm', 'contacted', 200, 'Has two kids, needs good school district', ARRAY['Family buyer', 'School district important'], ARRAY['family-home', 'good-schools'], false, NULL, NULL, '+1-555-888-8', 'referral')
ON CONFLICT DO NOTHING;

-- Step 2: Create a second test user profile (this will be linked when they sign up)
-- Note: We'll create the user profile without user_id first, then link it when the user signs up
INSERT INTO public.user_profiles (
    email,
    full_name,
    company_name,
    agent_phone_number,
    agent_id,
    plan,
    is_active
) VALUES
(
    'michael.test@luxuryhomes.com',
    'Michael Test Chen',
    'Luxury Homes Test Realty',
    '+1-555-999-9',
    'MICHAEL-T-2024',
    'premium',
    true
)
ON CONFLICT (email) DO NOTHING;

-- Step 3: Add leads for the second test user (+1-555-999-9)
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
-- Michael Test User's leads (+1-555-999-9)
('Frank Miller', '+1-555-8001', 'frank.miller@email.com', 'buyer', '1-2 months', 'Looking for luxury penthouse downtown', 'hot', 'new', 180, 'High net worth individual, cash buyer', ARRAY['Luxury buyer', 'Cash buyer'], ARRAY['luxury', 'penthouse', 'downtown'], false, NULL, NULL, '+1-555-999-9', 'referral'),
('Grace Lee', '+1-555-8002', 'grace.lee@email.com', 'seller', '2-3 months', 'Selling waterfront mansion, estate planning', 'hot', 'contacted', 240, 'Estate sale, needs quick closing', ARRAY['Estate sale', 'Waterfront'], ARRAY['mansion', 'waterfront', 'estate'], false, NULL, NULL, '+1-555-999-9', 'website'),
('Henry Taylor', '+1-555-8003', 'henry.taylor@email.com', 'buyer', '3-6 months', 'Investment portfolio expansion, commercial properties', 'warm', 'qualified', 120, 'Experienced investor, looking for ROI', ARRAY['Commercial investor', 'Portfolio expansion'], ARRAY['commercial', 'investment', 'portfolio'], false, NULL, NULL, '+1-555-999-9', 'cold-call'),
('Ivy Rodriguez', '+1-555-8004', 'ivy.rodriguez@email.com', 'seller', '1-3 months', 'Historic home in prestigious neighborhood', 'warm', 'new', 160, 'Historic property, needs special buyer', ARRAY['Historic property', 'Prestigious area'], ARRAY['historic', 'prestigious', 'unique'], false, NULL, NULL, '+1-555-999-9', 'referral'),
('Jack Anderson', '+1-555-8005', 'jack.anderson@email.com', 'buyer', '2-4 months', 'Looking for vacation home in mountains', 'cold', 'contacted', 100, 'Secondary residence, not urgent', ARRAY['Vacation home', 'Secondary residence'], ARRAY['vacation', 'mountains', 'secondary'], false, NULL, NULL, '+1-555-999-9', 'website')
ON CONFLICT DO NOTHING;

-- Step 4: Create a third test user profile
INSERT INTO public.user_profiles (
    email,
    full_name,
    company_name,
    agent_phone_number,
    agent_id,
    plan,
    is_active
) VALUES
(
    'jessica.test@eliterealty.com',
    'Jessica Test Martinez',
    'Elite Realty Test Group',
    '+1-555-777-7',
    'JESSICA-T-2024',
    'premium',
    true
)
ON CONFLICT (email) DO NOTHING;

-- Step 5: Add leads for the third test user (+1-555-777-7)
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
-- Jessica Test User's leads (+1-555-777-7)
('Kevin White', '+1-555-7001', 'kevin.white@email.com', 'buyer', '1-2 months', 'First-time buyer, starter home', 'hot', 'new', 140, 'Young professional, pre-approved', ARRAY['First-time buyer', 'Young professional'], ARRAY['starter-home', 'first-time'], false, NULL, NULL, '+1-555-777-7', 'website'),
('Linda Garcia', '+1-555-7002', 'linda.garcia@email.com', 'seller', '2-3 months', 'Downsizing after kids moved out', 'warm', 'contacted', 190, 'Empty nesters, looking to simplify', ARRAY['Downsizing', 'Empty nesters'], ARRAY['downsizing', 'simplify'], false, NULL, NULL, '+1-555-777-7', 'referral'),
('Mark Thompson', '+1-555-7003', 'mark.thompson@email.com', 'buyer', '3-6 months', 'Relocating for new job, needs temporary housing', 'cold', 'qualified', 80, 'Job transfer, exploring options', ARRAY['Job relocation', 'Temporary housing'], ARRAY['relocation', 'job-transfer'], false, NULL, NULL, '+1-555-777-7', 'cold-call'),
('Nancy Clark', '+1-555-7004', 'nancy.clark@email.com', 'seller', '1-3 months', 'Divorce settlement, needs quick sale', 'hot', 'new', 220, 'Sensitive situation, needs discretion', ARRAY['Divorce settlement', 'Quick sale needed'], ARRAY['divorce', 'quick-sale'], false, NULL, NULL, '+1-555-777-7', 'referral'),
('Oliver Lewis', '+1-555-7005', 'oliver.lewis@email.com', 'buyer', '2-4 months', 'Retirement home, looking for single story', 'warm', 'contacted', 170, 'Retiring soon, accessibility important', ARRAY['Retirement', 'Accessibility needs'], ARRAY['retirement', 'single-story', 'accessible'], false, NULL, NULL, '+1-555-777-7', 'website')
ON CONFLICT DO NOTHING;

-- Step 6: Add some completed leads for testing analytics
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
-- Completed leads for Sarah Test User (+1-555-888-8)
('Patricia Moore', '+1-555-9006', 'patricia.moore@email.com', 'buyer', '1-2 months', 'Starter home purchase', 'hot', 'closed', 200, 'Successfully closed on starter home', ARRAY['Successfully closed'], ARRAY['starter-home', 'closed'], false, 'successful', NOW() - INTERVAL '5 days', '+1-555-888-8', 'website'),
('Quentin Young', '+1-555-9007', 'quentin.young@email.com', 'seller', '2-3 months', 'Family home sale', 'warm', 'closed', 180, 'Sold family home above asking price', ARRAY['Sold above asking'], ARRAY['family-home', 'closed'], false, 'successful', NOW() - INTERVAL '10 days', '+1-555-888-8', 'referral'),
('Rachel Hall', '+1-555-9008', 'rachel.hall@email.com', 'buyer', '3-6 months', 'Investment property', 'cold', 'closed', 120, 'Decided not to proceed with investment', ARRAY['Decided not to proceed'], ARRAY['investment', 'closed'], false, 'unsuccessful', NOW() - INTERVAL '15 days', '+1-555-888-8', 'cold-call'),

-- Completed leads for Michael Test User (+1-555-999-9)
('Samuel King', '+1-555-8006', 'samuel.king@email.com', 'buyer', '1-2 months', 'Luxury penthouse purchase', 'hot', 'closed', 300, 'Closed on luxury penthouse', ARRAY['Luxury sale completed'], ARRAY['luxury', 'penthouse', 'closed'], false, 'successful', NOW() - INTERVAL '7 days', '+1-555-999-9', 'referral'),
('Tina Wright', '+1-555-8007', 'tina.wright@email.com', 'seller', '2-3 months', 'Waterfront mansion sale', 'hot', 'closed', 280, 'Sold waterfront mansion', ARRAY['Waterfront sale completed'], ARRAY['mansion', 'waterfront', 'closed'], false, 'successful', NOW() - INTERVAL '12 days', '+1-555-999-9', 'website'),
('Ulysses Scott', '+1-555-8008', 'ulysses.scott@email.com', 'buyer', '3-6 months', 'Commercial investment', 'warm', 'closed', 150, 'Still considering options', ARRAY['Still considering'], ARRAY['commercial', 'investment', 'closed'], false, 'on_the_fence', NOW() - INTERVAL '20 days', '+1-555-999-9', 'cold-call'),

-- Completed leads for Jessica Test User (+1-555-777-7)
('Victoria Green', '+1-555-7006', 'victoria.green@email.com', 'buyer', '1-2 months', 'Starter home purchase', 'hot', 'closed', 160, 'Successfully purchased starter home', ARRAY['Starter home purchased'], ARRAY['starter-home', 'closed'], false, 'successful', NOW() - INTERVAL '8 days', '+1-555-777-7', 'website'),
('William Adams', '+1-555-7007', 'william.adams@email.com', 'seller', '2-3 months', 'Downsizing sale', 'warm', 'closed', 200, 'Successfully downsized', ARRAY['Downsizing completed'], ARRAY['downsizing', 'closed'], false, 'successful', NOW() - INTERVAL '14 days', '+1-555-777-7', 'referral'),
('Xavier Baker', '+1-555-7008', 'xavier.baker@email.com', 'buyer', '3-6 months', 'Relocation purchase', 'cold', 'closed', 90, 'Found other options', ARRAY['Found other options'], ARRAY['relocation', 'closed'], false, 'unsuccessful', NOW() - INTERVAL '18 days', '+1-555-777-7', 'cold-call')
ON CONFLICT DO NOTHING;

-- Step 7: Verify the data was inserted correctly
-- This query will show the count of leads per agent phone number
SELECT 
    agent_phone_number,
    COUNT(*) as lead_count,
    COUNT(CASE WHEN completion_status IS NOT NULL THEN 1 END) as completed_leads,
    COUNT(CASE WHEN lead_quality = 'hot' THEN 1 END) as hot_leads,
    COUNT(CASE WHEN lead_quality = 'warm' THEN 1 END) as warm_leads,
    COUNT(CASE WHEN lead_quality = 'cold' THEN 1 END) as cold_leads
FROM public.leads 
WHERE agent_phone_number IN ('+1-555-888-8', '+1-555-999-9', '+1-555-777-7')
GROUP BY agent_phone_number
ORDER BY agent_phone_number;
