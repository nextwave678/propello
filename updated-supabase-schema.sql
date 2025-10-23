-- Updated Supabase Schema for Propello with Multi-User Authentication
-- This schema works with the authentication system we just built

-- First, let's add any missing columns to existing tables
ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'manual',
ADD COLUMN IF NOT EXISTS ai_agent_number INTEGER,
ADD COLUMN IF NOT EXISTS completion_status VARCHAR(20) CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS agent_phone_number VARCHAR(20);

-- Create user_profiles table (updated for auth integration)
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

-- Create lead_outcomes table
CREATE TABLE IF NOT EXISTS public.lead_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES public.leads(id) ON DELETE CASCADE,
    outcome_type VARCHAR(50) NOT NULL,
    outcome_value DECIMAL(10,2),
    outcome_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create daily_analytics table
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

-- Create weekly_analytics table
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

-- Create monthly_analytics table
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_leads_completion_status ON public.leads(completion_status);
CREATE INDEX IF NOT EXISTS idx_leads_ai_agent ON public.leads(ai_agent_number);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON public.leads(created_at);
CREATE INDEX IF NOT EXISTS idx_leads_agent_phone ON public.leads(agent_phone_number);
CREATE INDEX IF NOT EXISTS idx_lead_activities_lead_id ON public.lead_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_lead_id ON public.lead_outcomes(lead_id);
CREATE INDEX IF NOT EXISTS idx_daily_analytics_date ON public.daily_analytics(date);
CREATE INDEX IF NOT EXISTS idx_weekly_analytics_week ON public.weekly_analytics(week_start);
CREATE INDEX IF NOT EXISTS idx_monthly_analytics_month ON public.monthly_analytics(month_start);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone ON public.user_profiles(agent_phone_number);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_analytics ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view all outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can insert outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can update outcomes" ON public.lead_outcomes;
DROP POLICY IF EXISTS "Users can view all analytics" ON public.daily_analytics;
DROP POLICY IF EXISTS "Users can view all analytics" ON public.weekly_analytics;
DROP POLICY IF EXISTS "Users can view all analytics" ON public.monthly_analytics;

-- Create RLS policies for user_profiles (users can only see their own profile)
CREATE POLICY "Users can view own profile" ON public.user_profiles 
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own profile" ON public.user_profiles 
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.user_profiles 
    FOR UPDATE USING (user_id = auth.uid());

-- Create RLS policies for leads (users can only see leads for their agent phone)
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

-- Create RLS policies for lead_outcomes (users can only see outcomes for their leads)
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

-- Create RLS policies for analytics (users can view all analytics for now)
CREATE POLICY "Users can view analytics" ON public.daily_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.weekly_analytics 
    FOR SELECT USING (true);

CREATE POLICY "Users can view analytics" ON public.monthly_analytics 
    FOR SELECT USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON public.user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON public.user_profiles TO authenticated;
GRANT ALL ON public.lead_outcomes TO authenticated;
GRANT ALL ON public.daily_analytics TO authenticated;
GRANT ALL ON public.weekly_analytics TO authenticated;
GRANT ALL ON public.monthly_analytics TO authenticated;

-- Insert sample data (optional - for testing)
INSERT INTO public.user_profiles (user_id, email, full_name, company_name, agent_phone_number, plan) VALUES
('00000000-0000-0000-0000-000000000001', 'demo1@propello.com', 'Demo User 1', 'Demo Company', '+1-555-0001', 'free'),
('00000000-0000-0000-0000-000000000002', 'demo2@propello.com', 'Demo User 2', 'Demo Company', '+1-555-0002', 'free')
ON CONFLICT (email) DO NOTHING;

-- Update existing leads with sample agent phone numbers (if any exist)
-- Note: We'll update leads in batches to avoid syntax issues
UPDATE public.leads 
SET agent_phone_number = '+1-555-0001' 
WHERE agent_phone_number IS NULL 
AND id IN (
    SELECT id FROM public.leads 
    WHERE agent_phone_number IS NULL 
    ORDER BY created_at 
    LIMIT 5
);

UPDATE public.leads 
SET agent_phone_number = '+1-555-0002' 
WHERE agent_phone_number IS NULL 
AND id IN (
    SELECT id FROM public.leads 
    WHERE agent_phone_number IS NULL 
    ORDER BY created_at 
    LIMIT 5
);
