-- Fixed Supabase Schema for Propello Lead Management System
-- This version works with your existing leads table

-- =============================================
-- USER MANAGEMENT TABLES
-- =============================================

-- Create user_profiles table to extend auth.users
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    ai_agent_number TEXT UNIQUE NOT NULL, -- Unique identifier for AI agent
    avatar_url TEXT,
    phone TEXT,
    role TEXT DEFAULT 'agent' CHECK (role IN ('admin', 'agent', 'manager')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    timezone TEXT DEFAULT 'UTC'
);

-- =============================================
-- ENHANCE EXISTING LEADS TABLE
-- =============================================

-- Add new columns to existing leads table
ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS source TEXT,
ADD COLUMN IF NOT EXISTS budget_min INTEGER,
ADD COLUMN IF NOT EXISTS budget_max INTEGER,
ADD COLUMN IF NOT EXISTS property_value INTEGER,
ADD COLUMN IF NOT EXISTS preferred_contact_method TEXT CHECK (preferred_contact_method IN ('phone', 'email', 'text', 'any')),
ADD COLUMN IF NOT EXISTS urgency_level TEXT CHECK (urgency_level IN ('low', 'medium', 'high', 'urgent'));

-- =============================================
-- NEW TABLES
-- =============================================

-- Create lead_outcomes table to track detailed completion information
CREATE TABLE IF NOT EXISTS public.lead_outcomes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    lead_id UUID NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
    completion_status TEXT NOT NULL CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
    outcome_type TEXT, -- 'sale', 'rental', 'referral', 'lost_to_competitor', 'not_ready', etc.
    deal_value DECIMAL(12,2), -- Final deal value if successful
    commission_earned DECIMAL(10,2), -- Commission earned
    closing_date DATE, -- When the deal closed
    reason TEXT, -- Why it was successful/unsuccessful
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,
    notes TEXT,
    created_by UUID REFERENCES public.user_profiles(id)
);

-- =============================================
-- ANALYTICS TABLES
-- =============================================

-- Create daily_analytics table for historical tracking
CREATE TABLE IF NOT EXISTS public.daily_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date DATE NOT NULL,
    user_id UUID REFERENCES public.user_profiles(id),
    total_leads INTEGER DEFAULT 0,
    new_leads INTEGER DEFAULT 0,
    contacted_leads INTEGER DEFAULT 0,
    qualified_leads INTEGER DEFAULT 0,
    closed_leads INTEGER DEFAULT 0,
    dead_leads INTEGER DEFAULT 0,
    hot_leads INTEGER DEFAULT 0,
    warm_leads INTEGER DEFAULT 0,
    cold_leads INTEGER DEFAULT 0,
    buyer_leads INTEGER DEFAULT 0,
    seller_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    on_fence_leads INTEGER DEFAULT 0,
    unsuccessful_leads INTEGER DEFAULT 0,
    total_call_duration INTEGER DEFAULT 0, -- Total minutes
    total_activities INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(date, user_id)
);

-- Create weekly_analytics table for weekly summaries
CREATE TABLE IF NOT EXISTS public.weekly_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    user_id UUID REFERENCES public.user_profiles(id),
    total_leads INTEGER DEFAULT 0,
    new_leads INTEGER DEFAULT 0,
    closed_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    total_deal_value DECIMAL(15,2) DEFAULT 0.00,
    total_commission DECIMAL(12,2) DEFAULT 0.00,
    conversion_rate DECIMAL(5,2) DEFAULT 0.00,
    avg_call_duration DECIMAL(8,2) DEFAULT 0.00,
    total_activities INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(week_start, user_id)
);

-- Create monthly_analytics table for monthly summaries
CREATE TABLE IF NOT EXISTS public.monthly_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    user_id UUID REFERENCES public.user_profiles(id),
    total_leads INTEGER DEFAULT 0,
    new_leads INTEGER DEFAULT 0,
    closed_leads INTEGER DEFAULT 0,
    successful_leads INTEGER DEFAULT 0,
    total_deal_value DECIMAL(15,2) DEFAULT 0.00,
    total_commission DECIMAL(12,2) DEFAULT 0.00,
    conversion_rate DECIMAL(5,2) DEFAULT 0.00,
    avg_call_duration DECIMAL(8,2) DEFAULT 0.00,
    total_activities INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(month, year, user_id)
);

-- =============================================
-- PERFORMANCE INDEXES
-- =============================================

-- User profiles indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_ai_agent_number ON public.user_profiles(ai_agent_number);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_active ON public.user_profiles(is_active);

-- New indexes for leads table (only after columns are added)
CREATE INDEX IF NOT EXISTS idx_leads_source ON public.leads(source);
CREATE INDEX IF NOT EXISTS idx_leads_urgency_level ON public.leads(urgency_level);
CREATE INDEX IF NOT EXISTS idx_leads_budget_min ON public.leads(budget_min);
CREATE INDEX IF NOT EXISTS idx_leads_budget_max ON public.leads(budget_max);

-- Lead outcomes indexes
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_lead_id ON public.lead_outcomes(lead_id);
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_completion_status ON public.lead_outcomes(completion_status);
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_created_at ON public.lead_outcomes(created_at);
CREATE INDEX IF NOT EXISTS idx_lead_outcomes_closing_date ON public.lead_outcomes(closing_date);

-- Analytics indexes
CREATE INDEX IF NOT EXISTS idx_daily_analytics_date ON public.daily_analytics(date);
CREATE INDEX IF NOT EXISTS idx_daily_analytics_user_id ON public.daily_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_analytics_week_start ON public.weekly_analytics(week_start);
CREATE INDEX IF NOT EXISTS idx_weekly_analytics_user_id ON public.weekly_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_monthly_analytics_month_year ON public.monthly_analytics(month, year);
CREATE INDEX IF NOT EXISTS idx_monthly_analytics_user_id ON public.monthly_analytics(user_id);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on new tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_analytics ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view their own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Lead outcomes policies
CREATE POLICY "Users can view all lead outcomes" ON public.lead_outcomes
    FOR SELECT USING (true);

CREATE POLICY "Users can insert lead outcomes" ON public.lead_outcomes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update lead outcomes" ON public.lead_outcomes
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete lead outcomes" ON public.lead_outcomes
    FOR DELETE USING (true);

-- Analytics policies
CREATE POLICY "Users can view all analytics" ON public.daily_analytics
    FOR SELECT USING (true);

CREATE POLICY "Users can insert analytics" ON public.daily_analytics
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view all weekly analytics" ON public.weekly_analytics
    FOR SELECT USING (true);

CREATE POLICY "Users can insert weekly analytics" ON public.weekly_analytics
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view all monthly analytics" ON public.monthly_analytics
    FOR SELECT USING (true);

CREATE POLICY "Users can insert monthly analytics" ON public.monthly_analytics
    FOR INSERT WITH CHECK (true);

-- =============================================
-- TRIGGERS AND FUNCTIONS
-- =============================================

-- Function to create user profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, ai_agent_number)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        'AGENT-' || LPAD(EXTRACT(EPOCH FROM NOW())::TEXT, 10, '0')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS handle_new_user_trigger ON auth.users;
CREATE TRIGGER handle_new_user_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- SAMPLE DATA (Optional - can be removed in production)
-- =============================================

-- Insert sample user profiles (only if they don't exist)
INSERT INTO public.user_profiles (id, email, full_name, ai_agent_number, role)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'admin@propello.com', 'Admin User', 'AGENT-001', 'admin'),
    ('00000000-0000-0000-0000-000000000002', 'agent1@propello.com', 'Agent One', 'AGENT-002', 'agent'),
    ('00000000-0000-0000-0000-000000000003', 'agent2@propello.com', 'Agent Two', 'AGENT-003', 'agent')
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- View for lead summary with user info
CREATE OR REPLACE VIEW public.lead_summary AS
SELECT 
    l.*,
    up.full_name as assigned_agent_name,
    up.ai_agent_number as assigned_agent_number
FROM public.leads l
LEFT JOIN public.user_profiles up ON l.assigned_to = up.id;

-- View for recent activities with lead info
CREATE OR REPLACE VIEW public.recent_activities AS
SELECT 
    la.*,
    l.name as lead_name,
    l.phone as lead_phone,
    up.full_name as performed_by_name
FROM public.lead_activities la
LEFT JOIN public.leads l ON la.lead_id = l.id
LEFT JOIN public.user_profiles up ON la.performed_by = up.id
ORDER BY la.created_at DESC;

-- View for analytics summary
CREATE OR REPLACE VIEW public.analytics_summary AS
SELECT 
    da.date,
    da.user_id,
    up.full_name as agent_name,
    up.ai_agent_number,
    da.total_leads,
    da.successful_leads,
    da.on_fence_leads,
    da.unsuccessful_leads,
    CASE 
        WHEN da.total_leads > 0 THEN ROUND((da.successful_leads::DECIMAL / da.total_leads) * 100, 2)
        ELSE 0 
    END as conversion_rate
FROM public.daily_analytics da
LEFT JOIN public.user_profiles up ON da.user_id = up.id
ORDER BY da.date DESC;
