-- Test Webhook Routing Verification
-- This script verifies that lead routing works correctly with agent_phone_number

-- =============================================
-- STEP 1: Verify User Profiles with Agent Phone Numbers
-- =============================================

-- Check all user profiles and their agent phone numbers
SELECT 
    user_id,
    email,
    full_name,
    agent_phone_number,
    is_active,
    created_at
FROM public.user_profiles 
ORDER BY created_at DESC;

-- Count users by agent phone number
SELECT 
    agent_phone_number,
    COUNT(*) as user_count,
    STRING_AGG(email, ', ') as user_emails
FROM public.user_profiles 
GROUP BY agent_phone_number
ORDER BY agent_phone_number;

-- =============================================
-- STEP 2: Check Existing Leads by Agent Phone Number
-- =============================================

-- View all leads with their agent phone numbers
SELECT 
    id,
    name,
    phone,
    email,
    lead_quality,
    status,
    agent_phone_number,
    created_at
FROM public.leads 
ORDER BY created_at DESC
LIMIT 20;

-- Count leads by agent phone number
SELECT 
    agent_phone_number,
    COUNT(*) as lead_count,
    COUNT(CASE WHEN lead_quality = 'hot' THEN 1 END) as hot_leads,
    COUNT(CASE WHEN lead_quality = 'warm' THEN 1 END) as warm_leads,
    COUNT(CASE WHEN lead_quality = 'cold' THEN 1 END) as cold_leads,
    COUNT(CASE WHEN status = 'new' THEN 1 END) as new_leads,
    COUNT(CASE WHEN status = 'contacted' THEN 1 END) as contacted_leads
FROM public.leads 
GROUP BY agent_phone_number
ORDER BY agent_phone_number;

-- =============================================
-- STEP 3: Test Lead Routing Logic
-- =============================================

-- Simulate what happens when a user logs in and requests their leads
-- Replace 'USER_EMAIL_HERE' with an actual user email for testing

-- Example: Test for user with agent_phone_number = '+1-555-123-4567'
WITH user_profile AS (
    SELECT agent_phone_number 
    FROM public.user_profiles 
    WHERE agent_phone_number = '+1-555-123-4567'
    LIMIT 1
)
SELECT 
    l.id,
    l.name,
    l.phone,
    l.email,
    l.lead_quality,
    l.status,
    l.agent_phone_number,
    l.created_at
FROM public.leads l
CROSS JOIN user_profile up
WHERE l.agent_phone_number = up.agent_phone_number
ORDER BY l.created_at DESC;

-- =============================================
-- STEP 4: Verify RLS Policies Are Working
-- =============================================

-- Check if RLS is enabled on leads table
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'leads';

-- Check RLS policies on leads table
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'leads' 
AND schemaname = 'public';

-- =============================================
-- STEP 5: Test Data Isolation
-- =============================================

-- Verify that users can only see leads with their agent_phone_number
-- This query should return the same results as the user-specific query above

-- Test for multiple agent phone numbers
SELECT 
    agent_phone_number,
    COUNT(*) as visible_leads,
    STRING_AGG(name, ', ') as lead_names
FROM public.leads 
WHERE agent_phone_number IN ('+1-555-123-4567', '+1-555-987-6543', '+1-555-456-7890')
GROUP BY agent_phone_number
ORDER BY agent_phone_number;

-- =============================================
-- STEP 6: Check for Missing Agent Phone Numbers
-- =============================================

-- Find leads without agent_phone_number (these won't be routed to any user)
SELECT 
    id,
    name,
    phone,
    email,
    lead_quality,
    status,
    agent_phone_number,
    created_at
FROM public.leads 
WHERE agent_phone_number IS NULL 
   OR agent_phone_number = '';

-- Find users without agent_phone_number (these can't receive leads)
SELECT 
    user_id,
    email,
    full_name,
    agent_phone_number,
    created_at
FROM public.user_profiles 
WHERE agent_phone_number IS NULL 
   OR agent_phone_number = '';

-- =============================================
-- STEP 7: Performance Check
-- =============================================

-- Check if indexes exist for agent_phone_number
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'leads' 
AND indexdef LIKE '%agent_phone_number%';

-- Check query performance for lead filtering
EXPLAIN ANALYZE
SELECT * FROM public.leads 
WHERE agent_phone_number = '+1-555-123-4567'
ORDER BY created_at DESC;

-- =============================================
-- STEP 8: Webhook Test Data Validation
-- =============================================

-- Insert test webhook data to verify routing works
-- NOTE: Only run this if you want to add test data

/*
INSERT INTO public.leads (
    name,
    phone,
    email,
    type,
    timeframe,
    property_details,
    lead_quality,
    call_duration,
    call_transcript,
    status,
    agent_phone_number
) VALUES 
-- Test lead for agent +1-555-123-4567
(
    'Test Lead Agent 1',
    '+1555123456',
    'test1@example.com',
    'buyer',
    '3-6 months',
    '3BR house in downtown',
    'hot',
    180,
    'Test call transcript for agent 1',
    'new',
    '+1-555-123-4567'
),
-- Test lead for agent +1-555-987-6543
(
    'Test Lead Agent 2',
    '+1555987654',
    'test2@example.com',
    'seller',
    '1-3 months',
    '4BR house in suburbs',
    'warm',
    240,
    'Test call transcript for agent 2',
    'new',
    '+1-555-987-6543'
),
-- Test lead for agent +1-555-456-7890
(
    'Test Lead Agent 3',
    '+1555456789',
    'test3@example.com',
    'buyer',
    'immediately',
    '2BR condo downtown',
    'cold',
    120,
    'Test call transcript for agent 3',
    'new',
    '+1-555-456-7890'
);
*/

-- =============================================
-- STEP 9: Cleanup Test Data (Optional)
-- =============================================

-- Remove test leads if needed
-- NOTE: Only run this if you want to clean up test data

/*
DELETE FROM public.leads 
WHERE name LIKE 'Test Lead Agent%' 
AND created_at > NOW() - INTERVAL '1 hour';
*/

-- =============================================
-- SUMMARY QUERIES
-- =============================================

-- Overall system health check
SELECT 
    'User Profiles' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN agent_phone_number IS NOT NULL AND agent_phone_number != '' THEN 1 END) as with_agent_phone,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_users
FROM public.user_profiles

UNION ALL

SELECT 
    'Leads' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN agent_phone_number IS NOT NULL AND agent_phone_number != '' THEN 1 END) as with_agent_phone,
    COUNT(CASE WHEN status = 'new' THEN 1 END) as new_leads
FROM public.leads;

-- Final verification: Check that each user can see their leads
SELECT 
    up.email as user_email,
    up.agent_phone_number,
    COUNT(l.id) as lead_count,
    COUNT(CASE WHEN l.lead_quality = 'hot' THEN 1 END) as hot_leads
FROM public.user_profiles up
LEFT JOIN public.leads l ON up.agent_phone_number = l.agent_phone_number
GROUP BY up.email, up.agent_phone_number
ORDER BY up.agent_phone_number;
