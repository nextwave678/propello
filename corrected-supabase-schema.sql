-- Corrected Supabase Schema for Propello Lead Management System
-- This version works with Supabase's built-in auth system

-- First, let's add any missing columns to existing tables
ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'manual',
ADD COLUMN IF NOT EXISTS ai_agent_number INTEGER,
ADD COLUMN IF NOT EXISTS completion_status VARCHAR(20) CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT FALSE;

-- Create user_profiles table (simplified, no foreign key to users table)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    ai_agent_number INTEGER UNIQUE,
    role VARCHAR(50) DEFAULT 'agent',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
    new_leads INTEGER DEFAULT 0,
    completed_leads INTEGER DEFAULT 0,
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
CREATE INDEX IF NOT EXISTS idx_lead_activities_lead_id ON public.lead_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_lead_id ON public.lead_outcomes(lead_id);
CREATE INDEX IF NOT EXISTS idx_daily_analytics_date ON public.daily_analytics(date);
CREATE INDEX IF NOT EXISTS idx_weekly_analytics_week ON public.weekly_analytics(week_start);
CREATE INDEX IF NOT EXISTS idx_monthly_analytics_month ON public.monthly_analytics(month_start);

-- Insert sample user profiles (without foreign key constraints)
INSERT INTO public.user_profiles (email, full_name, ai_agent_number, role) VALUES
('agent1@propello.com', 'Sarah Johnson', 1001, 'agent'),
('agent2@propello.com', 'Mike Chen', 1002, 'agent'),
('agent3@propello.com', 'Emily Rodriguez', 1003, 'agent'),
('manager@propello.com', 'David Wilson', 2001, 'manager')
ON CONFLICT (email) DO NOTHING;

-- Insert sample lead outcomes (only if leads exist)
INSERT INTO public.lead_outcomes (lead_id, outcome_type, outcome_value, outcome_date, notes)
SELECT 
    id as lead_id,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 1 THEN 'sale'
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 2 THEN 'rental'
        ELSE 'consultation'
    END as outcome_type,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 1 THEN 450000.00
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 2 THEN 2500.00
        ELSE 0.00
    END as outcome_value,
    NOW() as outcome_date,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 1 THEN 'Property sold at asking price'
        WHEN ROW_NUMBER() OVER (ORDER BY created_at) = 2 THEN 'Monthly rental agreement signed'
        ELSE 'Free consultation provided'
    END as notes
FROM public.leads 
WHERE completion_status = 'successful'
LIMIT 3
ON CONFLICT DO NOTHING;

-- Insert sample daily analytics
INSERT INTO public.daily_analytics (date, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-15', 25, 8, 12, 8, 3, 1, 15, 3600),
('2024-01-16', 28, 6, 10, 7, 2, 1, 18, 4200),
('2024-01-17', 30, 5, 8, 5, 2, 1, 12, 2800)
ON CONFLICT DO NOTHING;

-- Insert sample weekly analytics
INSERT INTO public.weekly_analytics (week_start, week_end, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-15', '2024-01-21', 150, 35, 60, 40, 15, 5, 85, 18000),
('2024-01-22', '2024-01-28', 165, 40, 65, 45, 15, 5, 90, 19500)
ON CONFLICT DO NOTHING;

-- Insert sample monthly analytics
INSERT INTO public.monthly_analytics (month_start, month_end, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads, total_calls, total_call_duration) VALUES
('2024-01-01', '2024-01-31', 650, 180, 280, 190, 70, 20, 350, 75000),
('2024-02-01', '2024-02-29', 720, 200, 320, 220, 80, 20, 380, 82000)
ON CONFLICT DO NOTHING;

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_analytics ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_profiles
CREATE POLICY "Users can view all profiles" ON public.user_profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.user_profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own profile" ON public.user_profiles FOR UPDATE USING (true);

-- Create RLS policies for lead_outcomes
CREATE POLICY "Users can view all outcomes" ON public.lead_outcomes FOR SELECT USING (true);
CREATE POLICY "Users can insert outcomes" ON public.lead_outcomes FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update outcomes" ON public.lead_outcomes FOR UPDATE USING (true);

-- Create RLS policies for analytics tables
CREATE POLICY "Users can view all analytics" ON public.daily_analytics FOR SELECT USING (true);
CREATE POLICY "Users can view all analytics" ON public.weekly_analytics FOR SELECT USING (true);
CREATE POLICY "Users can view all analytics" ON public.monthly_analytics FOR SELECT USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to automatically update analytics
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

-- Create trigger for daily analytics
CREATE TRIGGER update_daily_analytics_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.leads
    FOR EACH ROW EXECUTE FUNCTION update_daily_analytics();

-- Grant necessary permissions
GRANT ALL ON public.user_profiles TO authenticated;
GRANT ALL ON public.lead_outcomes TO authenticated;
GRANT ALL ON public.daily_analytics TO authenticated;
GRANT ALL ON public.weekly_analytics TO authenticated;
GRANT ALL ON public.monthly_analytics TO authenticated;
