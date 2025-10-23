-- Step-by-Step Supabase Schema Fix
-- Run these commands one by one to avoid errors

-- Step 1: Add missing columns to leads table
ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'manual';

ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS ai_agent_number INTEGER;

ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS completion_status VARCHAR(20) CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful'));

ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT FALSE;

ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS agent_phone_number VARCHAR(20);

-- Step 2: Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    company_name VARCHAR(255),
    agent_phone_number VARCHAR(20) UNIQUE NOT NULL,
    agent_id VARCHAR(255),
    plan VARCHAR(20) DEFAULT 'free',
    is_active BOOLEAN DEFAULT TRUE
);

-- Step 3: Create lead_outcomes table
CREATE TABLE IF NOT EXISTS public.lead_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES public.leads(id) ON DELETE CASCADE,
    outcome_type VARCHAR(50) NOT NULL,
    outcome_value DECIMAL(10,2),
    outcome_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Create analytics tables
CREATE TABLE IF NOT EXISTS public.daily_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL,
    total_leads INTEGER DEFAULT 0,
    new_leads INTEGER DEFAULT 0,
    completed_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    unsuccessful_leads INTEGER DEFAULT 0,
    on_fence_leads INTEGER DEFAULT 0,
    total_calls INTEGER DEFAULT 0,
    total_call_duration INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.weekly_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    total_leads INTEGER DEFAULT 0,
    new_leads INTEGER DEFAULT 0,
    completed_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    unsuccessful_leads INTEGER DEFAULT 0,
    on_fence_leads INTEGER DEFAULT 0,
    total_calls INTEGER DEFAULT 0,
    total_call_duration INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.monthly_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    month_start DATE NOT NULL,
    month_end DATE NOT NULL,
    total_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    unsuccessful_leads INTEGER DEFAULT 0,
    on_fence_leads INTEGER DEFAULT 0,
    total_calls INTEGER DEFAULT 0,
    total_call_duration INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 5: Create indexes
CREATE INDEX IF NOT EXISTS idx_leads_completion_status ON public.leads(completion_status);
CREATE INDEX IF NOT EXISTS idx_leads_agent_phone ON public.leads(agent_phone_number);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone ON public.user_profiles(agent_phone_number);

-- Step 6: Enable RLS
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_analytics ENABLE ROW LEVEL SECURITY;

-- Step 7: Create RLS policies
CREATE POLICY "Users can view own profile" ON public.user_profiles 
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own profile" ON public.user_profiles 
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.user_profiles 
    FOR UPDATE USING (user_id = auth.uid());

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

CREATE POLICY "Users can view analytics" ON public.daily_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.weekly_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.monthly_analytics 
    FOR SELECT USING (true);

-- Step 8: Grant permissions
GRANT ALL ON public.user_profiles TO authenticated;
GRANT ALL ON public.lead_outcomes TO authenticated;
GRANT ALL ON public.daily_analytics TO authenticated;
GRANT ALL ON public.weekly_analytics TO authenticated;
GRANT ALL ON public.monthly_analytics TO authenticated;

-- Step 9: Insert sample data
INSERT INTO public.user_profiles (user_id, email, full_name, company_name, agent_phone_number, plan) VALUES
('00000000-0000-0000-0000-000000000001', 'demo1@propello.com', 'Demo User 1', 'Demo Company', '+1-555-0001', 'free'),
('00000000-0000-0000-0000-000000000002', 'demo2@propello.com', 'Demo User 2', 'Demo Company', '+1-555-0002', 'free')
ON CONFLICT (email) DO NOTHING;
