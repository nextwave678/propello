-- Insert 2 Mock Realtor Accounts (Fixed Version)
-- This version avoids the generated column issues

-- Mock Realtor 1: Sarah Johnson
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
) VALUES (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'sarah.johnson@premierrealty.com',
    '$2a$10$example_hashed_password_here',
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Sarah Johnson"}',
    false,
    NOW(),
    NOW(),
    '+1-555-0101',
    NOW(),
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false,
    NULL
) ON CONFLICT (id) DO NOTHING;

-- Mock Realtor 2: Michael Chen
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'michael.chen@luxuryhomes.com',
    '$2a$10$example_hashed_password_here',
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Michael Chen"}',
    false,
    NOW(),
    NOW(),
    '+1-555-0102',
    NOW(),
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false,
    NULL
) ON CONFLICT (id) DO NOTHING;

-- Now create their user profiles
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
    '11111111-1111-1111-1111-111111111111',
    'sarah.johnson@premierrealty.com',
    'Sarah Johnson',
    'Premier Realty Group',
    '+1-555-0101',
    'SARAH-J-2024',
    'premium',
    true
),
(
    '22222222-2222-2222-2222-222222222222',
    'michael.chen@luxuryhomes.com',
    'Michael Chen',
    'Luxury Homes Realty',
    '+1-555-0102',
    'MICHAEL-C-2024',
    'premium',
    true
)
ON CONFLICT (email) DO NOTHING;

-- Add some sample leads for each realtor
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
-- Sarah Johnson's leads
('John Smith', '+1-555-1001', 'john.smith@email.com', 'buyer', '3-6 months', 'Looking for 3BR house in downtown area, budget $500k-$700k', 'hot', 'new', 180, 'Very interested in purchasing, has pre-approval letter ready', ARRAY['Called during business hours', 'Has pre-approval letter'], ARRAY['first-time-buyer', 'downtown'], false, NULL, NULL, '+1-555-0101', 'website'),
('Jane Doe', '+1-555-1002', 'jane.doe@email.com', 'seller', '1-3 months', 'Selling 4BR house in suburban area, recently renovated', 'warm', 'contacted', 240, 'Sent comparative market analysis, awaiting response', ARRAY['Follow-up scheduled', 'CMA sent'], ARRAY['renovated', 'suburban'], false, 'successful', '2024-01-15T10:00:00Z', '+1-555-0101', 'referral'),
('Peter Jones', '+1-555-1003', 'peter.j@email.com', 'buyer', '6-12 months', 'Interested in investment properties, multi-family units', 'cold', 'qualified', 120, 'Discussed investment strategy, needs more research', ARRAY['Sent investment guide'], ARRAY['investor', 'multi-family'], false, 'on_the_fence', '2024-01-16T14:30:00Z', '+1-555-0101', 'cold-call'),

-- Michael Chen's leads
('Alice Brown', '+1-555-2001', 'alice.b@email.com', 'seller', '3-6 months', 'Selling condo near university, quick sale preferred', 'hot', 'new', 300, 'Ready to list, needs staging advice', ARRAY['Staging consultation booked'], ARRAY['condo', 'university'], false, NULL, NULL, '+1-555-0102', 'website'),
('Robert White', '+1-555-2002', 'robert.w@email.com', 'buyer', 'Immediate', 'Cash buyer for distressed property, any area', 'hot', 'closed', 400, 'Offer accepted on 123 Main St, closing next month', ARRAY['Offer accepted', 'Closing scheduled'], ARRAY['cash-buyer', 'distressed'], false, 'successful', '2024-01-10T10:00:00Z', '+1-555-0102', 'referral'),
('Jennifer Martinez', '+1-555-2003', 'jennifer.m@email.com', 'buyer', '1-2 months', '3BR house in family neighborhood, good schools', 'hot', 'closed', 240, 'Found perfect home, ready to make offer', ARRAY['Found dream home', 'Offer accepted', 'Closing scheduled'], ARRAY['family-home', 'good-schools'], false, 'unsuccessful', '2024-01-12T11:00:00Z', '+1-555-0102', 'open-house');

-- Add some lead outcomes for successful leads
INSERT INTO public.lead_outcomes (
    lead_id,
    outcome_type,
    outcome_value,
    outcome_date,
    notes
) VALUES
(
    (SELECT id FROM public.leads WHERE name = 'Jane Doe' AND agent_phone_number = '+1-555-0101'),
    'sale',
    650000.00,
    '2024-01-15T10:00:00Z',
    'Property sold at asking price - 4BR suburban home'
),
(
    (SELECT id FROM public.leads WHERE name = 'Robert White' AND agent_phone_number = '+1-555-0102'),
    'sale',
    425000.00,
    '2024-01-10T10:00:00Z',
    'Distressed property sold to cash buyer'
)
ON CONFLICT DO NOTHING;
