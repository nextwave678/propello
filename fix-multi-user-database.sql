-- Fix Multi-User Lead Routing - Database Setup
-- Run this script in Supabase SQL Editor

-- =============================================
-- STEP 1: Add missing columns to user_profiles
-- =============================================

-- Add missing columns that the app expects
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'UTC';

-- =============================================
-- STEP 2: Ensure RLS is enabled
-- =============================================

ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 3: Create/Update RLS Policies
-- =============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;

DROP POLICY IF EXISTS "Users can view own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can update own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can insert own leads" ON public.leads;

DROP POLICY IF EXISTS "Users can view own lead activities" ON public.lead_activities;
DROP POLICY IF EXISTS "Users can insert own lead activities" ON public.lead_activities;
DROP POLICY IF EXISTS "Users can update own lead activities" ON public.lead_activities;

-- Create user_profiles policies
CREATE POLICY "Users can view own profile" ON public.user_profiles 
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own profile" ON public.user_profiles 
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.user_profiles 
    FOR UPDATE USING (user_id = auth.uid());

-- Create leads policies (CRITICAL for multi-user routing)
CREATE POLICY "Users can view own leads" ON public.leads 
    FOR SELECT USING (
        agent_phone_number IN (
            SELECT agent_phone_number FROM public.user_profiles 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own leads" ON public.leads 
    FOR UPDATE USING (
        agent_phone_number IN (
            SELECT agent_phone_number FROM public.user_profiles 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own leads" ON public.leads 
    FOR INSERT WITH CHECK (
        agent_phone_number IN (
            SELECT agent_phone_number FROM public.user_profiles 
            WHERE user_id = auth.uid()
        )
    );

-- Allow service role to insert leads (for webhooks)
CREATE POLICY "Service role can insert leads" ON public.leads 
    FOR INSERT TO service_role WITH CHECK (true);

-- Create lead_activities policies
CREATE POLICY "Users can view own lead activities" ON public.lead_activities 
    FOR SELECT USING (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can insert own lead activities" ON public.lead_activities 
    FOR INSERT WITH CHECK (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can update own lead activities" ON public.lead_activities 
    FOR UPDATE USING (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

-- =============================================
-- STEP 4: Create indexes for performance
-- =============================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone ON public.user_profiles(agent_phone_number);
CREATE INDEX IF NOT EXISTS idx_leads_agent_phone ON public.leads(agent_phone_number);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON public.leads(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_quality ON public.leads(lead_quality);
CREATE INDEX IF NOT EXISTS idx_lead_activities_lead_id ON public.lead_activities(lead_id);

-- =============================================
-- STEP 5: Verify setup
-- =============================================

-- Check RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('leads', 'user_profiles', 'lead_activities')
AND schemaname = 'public';

-- Check policies exist
SELECT 
    policyname,
    tablename,
    cmd,
    permissive
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('leads', 'user_profiles', 'lead_activities')
ORDER BY tablename, policyname;

-- Check indexes exist
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('leads', 'user_profiles', 'lead_activities')
ORDER BY tablename, indexname;

-- =============================================
-- STEP 6: Test data (optional - only run if you want test data)
-- =============================================

-- Uncomment the following section if you want to create test users and leads
/*
-- Create test user profiles
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
-- Note: You'll need to replace these UUIDs with actual auth.users IDs
-- You can get these by creating users through the signup flow first
(
    '00000000-0000-0000-0000-000000000001', -- Replace with actual user ID
    'test1@example.com',
    'Test User 1',
    'Test Company 1',
    '+1-555-123-4567',
    'agent-001',
    'free',
    true
),
(
    '00000000-0000-0000-0000-000000000002', -- Replace with actual user ID
    'test2@example.com',
    'Test User 2',
    'Test Company 2',
    '+1-555-987-6543',
    'agent-002',
    'free',
    true
);

-- Create test leads
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
    agent_phone_number,
    source
) VALUES 
-- Test leads for agent +1-555-123-4567
(
    'John Smith',
    '+1555123456',
    'john@example.com',
    'buyer',
    '3-6 months',
    '3BR house downtown',
    'hot',
    180,
    'Very interested in buying',
    'new',
    '+1-555-123-4567',
    'webhook'
),
-- Test leads for agent +1-555-987-6543
(
    'Jane Doe',
    '+1555987654',
    'jane@example.com',
    'seller',
    '1-3 months',
    '4BR house suburbs',
    'warm',
    240,
    'Considering selling',
    'new',
    '+1-555-987-6543',
    'webhook'
);
*/

-- =============================================
-- SUCCESS MESSAGE
-- =============================================

SELECT 'Multi-user lead routing setup complete!' as status;
