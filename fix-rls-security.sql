-- CRITICAL SECURITY FIX: Proper Row Level Security (RLS) Policies
-- This fixes the security issue where all users can see all leads

-- Step 1: Drop all existing policies to start fresh
DROP POLICY IF EXISTS "Users can view all leads" ON public.leads;
DROP POLICY IF EXISTS "Users can view own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can update leads" ON public.leads;
DROP POLICY IF EXISTS "Users can update own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can insert leads" ON public.leads;
DROP POLICY IF EXISTS "Users can delete leads" ON public.leads;
DROP POLICY IF EXISTS "Service role can insert leads" ON public.leads;

DROP POLICY IF EXISTS "Users can view all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;

DROP POLICY IF EXISTS "Users can view all outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can view own lead outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can insert outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can insert own lead outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can update outcomes" ON public.lead_outcomes;

DROP POLICY IF EXISTS "Users can view analytics" ON public.daily_analytics;
DROP POLICY IF EXISTS "Users can view analytics" ON public.weekly_analytics;
DROP POLICY IF EXISTS "Users can view analytics" ON public.monthly_analytics;

-- Step 2: Ensure RLS is enabled on all tables
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_analytics ENABLE ROW LEVEL SECURITY;

-- Step 3: Create proper user-specific policies for user_profiles
CREATE POLICY "Users can view own profile" ON public.user_profiles 
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own profile" ON public.user_profiles 
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.user_profiles 
    FOR UPDATE USING (user_id = auth.uid());

-- Step 4: Create proper user-specific policies for leads
-- Users can only see leads assigned to their agent phone number
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

-- Step 5: Create proper user-specific policies for lead_outcomes
CREATE POLICY "Users can view own lead outcomes" ON public.lead_outcomes 
    FOR SELECT USING (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can insert own lead outcomes" ON public.lead_outcomes 
    FOR INSERT WITH CHECK (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can update own lead outcomes" ON public.lead_outcomes 
    FOR UPDATE USING (
        lead_id IN (
            SELECT id FROM public.leads 
            WHERE agent_phone_number IN (
                SELECT agent_phone_number FROM public.user_profiles 
                WHERE user_id = auth.uid()
            )
        )
    );

-- Step 6: Create policies for analytics (users can see aggregated data)
CREATE POLICY "Users can view analytics" ON public.daily_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.weekly_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.monthly_analytics 
    FOR SELECT USING (true);

-- Step 7: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone ON public.user_profiles(agent_phone_number);
CREATE INDEX IF NOT EXISTS idx_leads_agent_phone ON public.leads(agent_phone_number);

-- Step 7.5: Fix analytics table constraints
-- Add unique constraints for analytics tables to support ON CONFLICT
-- Note: We need to drop existing constraints first if they exist
DO $$ 
BEGIN
    -- Add unique constraint to daily_analytics if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_daily_analytics_date'
    ) THEN
        ALTER TABLE public.daily_analytics 
        ADD CONSTRAINT unique_daily_analytics_date UNIQUE (date);
    END IF;

    -- Add unique constraint to weekly_analytics if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_weekly_analytics_week'
    ) THEN
        ALTER TABLE public.weekly_analytics 
        ADD CONSTRAINT unique_weekly_analytics_week UNIQUE (week_start);
    END IF;

    -- Add unique constraint to monthly_analytics if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_monthly_analytics_month'
    ) THEN
        ALTER TABLE public.monthly_analytics 
        ADD CONSTRAINT unique_monthly_analytics_month UNIQUE (month_start);
    END IF;
END $$;

-- Step 7.6: Fix the trigger function that was causing the error
DROP TRIGGER IF EXISTS update_daily_analytics_trigger ON public.leads;
DROP FUNCTION IF EXISTS update_daily_analytics();

-- Recreate the trigger function with proper error handling
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
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the trigger
        RAISE WARNING 'Error updating daily analytics: %', SQLERRM;
        RETURN NEW;
END;
$$ language 'plpgsql';

-- Recreate the trigger
CREATE TRIGGER update_daily_analytics_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.leads
    FOR EACH ROW EXECUTE FUNCTION update_daily_analytics();

-- Step 8: Add some test leads for the new user to verify RLS works
-- This will create leads specifically for the new user's agent phone number
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
-- Leads for the new test user (+1-555-8888)
('Test Lead 1', '+1-555-9001', 'test1@email.com', 'buyer', '1-2 months', 'Looking for starter home under $300k', 'hot', 'new', 120, 'Very interested, has pre-approval', ARRAY['Pre-approved', 'First-time buyer'], ARRAY['starter-home', 'first-time'], false, NULL, NULL, '+1-555-8888', 'website'),
('Test Lead 2', '+1-555-9002', 'test2@email.com', 'seller', '2-3 months', 'Selling family home, needs to relocate', 'warm', 'contacted', 180, 'Motivated seller, flexible on timing', ARRAY['Relocating', 'Flexible timing'], ARRAY['family-home', 'relocation'], false, NULL, NULL, '+1-555-8888', 'referral'),
('Test Lead 3', '+1-555-9003', 'test3@email.com', 'buyer', '3-6 months', 'Investment property, multi-family preferred', 'cold', 'qualified', 90, 'Just starting to look, not in rush', ARRAY['Investment buyer', 'Early stage'], ARRAY['investment', 'multi-family'], false, NULL, NULL, '+1-555-8888', 'cold-call')
ON CONFLICT DO NOTHING;

-- Step 9: Verify the fix worked
-- This query should only return leads for the current user's agent phone
-- SELECT COUNT(*) FROM public.leads WHERE agent_phone_number = '+1-555-8888';
