-- Complete Mock Data Setup for Propello
-- This script includes everything needed for mock realtor accounts and data

-- Step 1: Fix analytics constraints
ALTER TABLE public.daily_analytics 
ADD CONSTRAINT IF NOT EXISTS unique_daily_analytics_date UNIQUE (date);

ALTER TABLE public.weekly_analytics 
ADD CONSTRAINT IF NOT EXISTS unique_weekly_analytics_week UNIQUE (week_start);

ALTER TABLE public.monthly_analytics 
ADD CONSTRAINT IF NOT EXISTS unique_monthly_analytics_month UNIQUE (month_start);

-- Step 2: Create mock auth users
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
) VALUES 
-- Sarah Johnson
(
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
),
-- Michael Chen
(
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
)
ON CONFLICT (id) DO NOTHING;

-- Step 3: Create user profiles
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

-- Step 4: Insert sample leads for Sarah Johnson
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
('Lisa Anderson', '+1-555-1004', 'lisa.a@email.com', 'seller', '2-4 months', 'Selling luxury condo with city views, high-end finishes', 'hot', 'new', 320, 'Ready to list, needs professional photography', ARRAY['Photography scheduled'], ARRAY['luxury', 'condo', 'city-views'], false, NULL, NULL, '+1-555-0101', 'website'),
('David Wilson', '+1-555-1005', 'david.w@email.com', 'buyer', '1-2 months', 'First-time buyer, looking for starter home under $300k', 'warm', 'contacted', 200, 'Pre-approved for $280k, exploring neighborhoods', ARRAY['Sent neighborhood guide'], ARRAY['first-time-buyer', 'starter-home'], false, 'unsuccessful', '2024-01-14T09:00:00Z', '+1-555-0101', 'open-house'),

-- Michael's leads
('Alice Brown', '+1-555-2001', 'alice.b@email.com', 'seller', '3-6 months', 'Selling condo near university, quick sale preferred', 'hot', 'new', 300, 'Ready to list, needs staging advice', ARRAY['Staging consultation booked'], ARRAY['condo', 'university'], false, NULL, NULL, '+1-555-0102', 'website'),
('Robert White', '+1-555-2002', 'robert.w@email.com', 'buyer', 'Immediate', 'Cash buyer for distressed property, any area', 'hot', 'closed', 400, 'Offer accepted on 123 Main St, closing next month', ARRAY['Offer accepted', 'Closing scheduled'], ARRAY['cash-buyer', 'distressed'], false, 'successful', '2024-01-10T10:00:00Z', '+1-555-0102', 'referral'),
('Jennifer Martinez', '+1-555-2003', 'jennifer.m@email.com', 'buyer', '1-2 months', '3BR house in family neighborhood, good schools', 'hot', 'closed', 240, 'Found perfect home, ready to make offer', ARRAY['Found dream home', 'Offer accepted', 'Closing scheduled'], ARRAY['family-home', 'good-schools'], false, 'unsuccessful', '2024-01-12T11:00:00Z', '+1-555-0102', 'open-house'),
('Mark Thompson', '+1-555-2004', 'mark.t@email.com', 'seller', '4-6 months', 'Selling family home, needs to find new place first', 'warm', 'contacted', 180, 'Discussed timeline, waiting for market conditions', ARRAY['Market analysis sent'], ARRAY['family-home', 'timeline-sensitive'], false, 'on_the_fence', '2024-01-18T16:00:00Z', '+1-555-0102', 'referral'),
('Sarah Davis', '+1-555-2005', 'sarah.d@email.com', 'buyer', '6-12 months', 'Looking for investment property, multi-family preferred', 'cold', 'qualified', 150, 'Discussed investment strategy, needs more research', ARRAY['Sent investment guide'], ARRAY['investor', 'multi-family'], false, NULL, NULL, '+1-555-0102', 'cold-call');

-- Step 5: Insert lead outcomes for successful leads
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
);

-- Step 6: Insert sample analytics data
INSERT INTO public.daily_analytics (date, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-15', 8, 3, 2, 1, 1, 0, 5, 1200),
('2024-01-16', 10, 2, 1, 0, 0, 1, 4, 900),
('2024-01-17', 12, 2, 0, 0, 0, 0, 3, 750),
('2024-01-18', 15, 3, 1, 0, 0, 1, 6, 1500)
ON CONFLICT (date) DO UPDATE SET
    total_leads = EXCLUDED.total_leads,
    new_leads = EXCLUDED.new_leads,
    completed_leads = EXCLUDED.completed_leads,
    successful_leads = EXCLUDED.successful_leads,
    unsuccessful_leads = EXCLUDED.unsuccessful_leads,
    on_fence_leads = EXCLUDED.on_fence_leads,
    total_calls = EXCLUDED.total_calls,
    total_call_duration = EXCLUDED.total_call_duration;

INSERT INTO public.weekly_analytics (week_start, week_end, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-15', '2024-01-21', 25, 8, 4, 2, 1, 1, 18, 4350),
('2024-01-22', '2024-01-28', 30, 10, 6, 3, 2, 1, 22, 5200)
ON CONFLICT (week_start) DO UPDATE SET
    total_leads = EXCLUDED.total_leads,
    new_leads = EXCLUDED.new_leads,
    completed_leads = EXCLUDED.completed_leads,
    successful_leads = EXCLUDED.successful_leads,
    unsuccessful_leads = EXCLUDED.unsuccessful_leads,
    on_fence_leads = EXCLUDED.on_fence_leads,
    total_calls = EXCLUDED.total_calls,
    total_call_duration = EXCLUDED.total_call_duration;

INSERT INTO public.monthly_analytics (month_start, month_end, total_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-01', '2024-01-31', 120, 15, 8, 3, 85, 18000),
('2024-02-01', '2024-02-29', 135, 18, 10, 4, 95, 21000)
ON CONFLICT (month_start) DO UPDATE SET
    total_leads = EXCLUDED.total_leads,
    successful_leads = EXCLUDED.successful_leads,
    unsuccessful_leads = EXCLUDED.unsuccessful_leads,
    on_fence_leads = EXCLUDED.on_fence_leads,
    total_calls = EXCLUDED.total_calls,
    total_call_duration = EXCLUDED.total_call_duration;

-- Step 7: Update trigger function to handle constraints properly
CREATE OR REPLACE FUNCTION update_daily_analytics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update daily analytics when leads are modified
    INSERT INTO public.daily_analytics (date, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads)
    VALUES (
        CURRENT_DATE,
        (SELECT COUNT(*) FROM public.leads WHERE DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status IS NOT NULL AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'successful' AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'unsuccessful' AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'on_the_fence' AND DATE(created_at) = CURRENT_DATE)
    )
    ON CONFLICT (date) DO UPDATE SET
        total_leads = EXCLUDED.total_leads,
        new_leads = EXCLUDED.new_leads,
        completed_leads = EXCLUDED.completed_leads,
        successful_leads = EXCLUDED.successful_leads,
        unsuccessful_leads = EXCLUDED.unsuccessful_leads,
        on_fence_leads = EXCLUDED.on_fence_leads;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Step 8: Recreate the trigger
DROP TRIGGER IF EXISTS update_daily_analytics_trigger ON public.leads;
CREATE TRIGGER update_daily_analytics_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.leads
    FOR EACH ROW EXECUTE FUNCTION update_daily_analytics();
