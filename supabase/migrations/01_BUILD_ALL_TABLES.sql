-- =============================================
-- BUILD ALL TABLES AND POLICIES FROM SCRATCH
-- =============================================
-- 
-- This script creates a complete, production-ready Propello database
-- Run this AFTER running 00_DELETE_ALL_TABLES.sql
-- 
-- This creates:
-- - user_profiles table with correct schema
-- - leads table with user_id for isolation
-- - lead_activities table for tracking
-- - All necessary indexes
-- - All RLS policies for security
-- - Auto-assignment trigger
-- - Updated_at triggers
-- =============================================

-- =============================================
-- PART 1: CREATE TABLES
-- =============================================

-- Create user_profiles table
CREATE TABLE public.user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    agent_phone_number TEXT NOT NULL, -- The phone number for the AI agent (must be unique per user)
    agent_id TEXT, -- Retell AI agent ID (optional)
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
    is_active BOOLEAN DEFAULT true
);

COMMENT ON TABLE public.user_profiles IS 'User profile data with agent information for lead routing';
COMMENT ON COLUMN public.user_profiles.agent_phone_number IS 'AI agent phone number used to route incoming leads to this user';
COMMENT ON COLUMN public.user_profiles.user_id IS 'Foreign key to auth.users - enforces one profile per user';

-- Create leads table
CREATE TABLE public.leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Contact Information
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    
    -- Lead Classification
    type TEXT NOT NULL CHECK (type IN ('buyer', 'seller')),
    timeframe TEXT NOT NULL,
    property_details TEXT,
    lead_quality TEXT NOT NULL CHECK (lead_quality IN ('hot', 'warm', 'cold')),
    
    -- Status Management
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed', 'dead')),
    
    -- Call Information
    call_duration INTEGER, -- Duration in seconds
    call_transcript TEXT,
    call_recording_url TEXT,
    
    -- Lead Management
    notes TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Completion Tracking
    completion_status TEXT CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-User Routing (CRITICAL FIELDS)
    agent_phone_number TEXT NOT NULL, -- Routes leads to specific user accounts
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL -- User who owns this lead
);

COMMENT ON TABLE public.leads IS 'Lead data captured from AI phone agent calls';
COMMENT ON COLUMN public.leads.agent_phone_number IS 'Phone number of the AI agent that captured this lead';
COMMENT ON COLUMN public.leads.user_id IS 'User who owns this lead - used for RLS filtering';
COMMENT ON COLUMN public.leads.lead_quality IS 'hot = urgent, warm = moderate priority, cold = nurture';
COMMENT ON COLUMN public.leads.completion_status IS 'Final outcome of lead (successful close, on the fence, or unsuccessful)';

-- Create lead_activities table
CREATE TABLE public.lead_activities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Relationships
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    performed_by UUID REFERENCES auth.users(id),
    
    -- Activity Details
    activity_type TEXT NOT NULL, -- 'status_change', 'note_added', 'quality_updated', 'call_made', etc.
    description TEXT,
    metadata JSONB -- Flexible storage for activity-specific data
);

COMMENT ON TABLE public.lead_activities IS 'Activity history and audit trail for leads';
COMMENT ON COLUMN public.lead_activities.activity_type IS 'Type of activity performed on the lead';

-- =============================================
-- PART 2: CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- User profiles indexes
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_agent_phone_number ON public.user_profiles(agent_phone_number);

-- Leads indexes
CREATE INDEX idx_leads_user_id ON public.leads(user_id);
CREATE INDEX idx_leads_created_at ON public.leads(created_at DESC);
CREATE INDEX idx_leads_status ON public.leads(status);
CREATE INDEX idx_leads_quality ON public.leads(lead_quality);
CREATE INDEX idx_leads_type ON public.leads(type);
CREATE INDEX idx_leads_archived ON public.leads(is_archived);
CREATE INDEX idx_leads_completion_status ON public.leads(completion_status) WHERE completion_status IS NOT NULL;
CREATE INDEX idx_leads_agent_phone ON public.leads(agent_phone_number);

-- Activities indexes
CREATE INDEX idx_activities_lead_id ON public.lead_activities(lead_id);
CREATE INDEX idx_activities_created_at ON public.lead_activities(created_at DESC);
CREATE INDEX idx_activities_type ON public.lead_activities(activity_type);
CREATE INDEX idx_activities_performed_by ON public.lead_activities(performed_by);

-- =============================================
-- PART 3: ENABLE ROW LEVEL SECURITY
-- =============================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;

-- =============================================
-- PART 4: CREATE RLS POLICIES
-- =============================================

-- ========== USER_PROFILES POLICIES ==========

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" 
ON public.user_profiles
FOR SELECT 
USING (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" 
ON public.user_profiles
FOR UPDATE 
USING (auth.uid() = user_id);

-- Users can insert their own profile (during signup)
CREATE POLICY "Users can insert their own profile" 
ON public.user_profiles
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- ========== LEADS POLICIES ==========

-- Users can view their own leads ONLY
CREATE POLICY "Users can view their own leads" 
ON public.leads
FOR SELECT 
USING (auth.uid() = user_id);

-- Service role can insert leads (for webhook with service_role key)
CREATE POLICY "Service role can insert leads" 
ON public.leads
FOR INSERT 
WITH CHECK (true);

-- Users can insert their own leads
CREATE POLICY "Users can insert their own leads" 
ON public.leads
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Users can update their own leads
CREATE POLICY "Users can update their own leads" 
ON public.leads
FOR UPDATE 
USING (auth.uid() = user_id);

-- Users can delete their own leads
CREATE POLICY "Users can delete their own leads" 
ON public.leads
FOR DELETE 
USING (auth.uid() = user_id);

-- ========== LEAD_ACTIVITIES POLICIES ==========

-- Users can view activities for their own leads
CREATE POLICY "Users can view their own lead activities" 
ON public.lead_activities
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.leads 
        WHERE leads.id = lead_activities.lead_id 
        AND leads.user_id = auth.uid()
    )
);

-- Users can insert activities for their own leads
CREATE POLICY "Users can insert activities for their own leads" 
ON public.lead_activities
FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.leads 
        WHERE leads.id = lead_activities.lead_id 
        AND leads.user_id = auth.uid()
    )
);

-- Service role can insert activities (for system events)
CREATE POLICY "Service role can insert activities" 
ON public.lead_activities
FOR INSERT 
WITH CHECK (true);

-- =============================================
-- PART 5: CREATE FUNCTIONS
-- =============================================

-- Function to update updated_at column automatically
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.update_updated_at_column IS 'Automatically updates updated_at timestamp on row updates';

-- Function to auto-assign user_id to leads based on agent_phone_number
CREATE OR REPLACE FUNCTION public.auto_assign_lead_user()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- If user_id is not set, try to find it from agent_phone_number
    IF NEW.user_id IS NULL AND NEW.agent_phone_number IS NOT NULL THEN
        SELECT user_id INTO v_user_id
        FROM public.user_profiles
        WHERE agent_phone_number = NEW.agent_phone_number
        LIMIT 1;
        
        IF v_user_id IS NOT NULL THEN
            NEW.user_id := v_user_id;
        ELSE
            -- Log warning if no user found (webhook should handle this)
            RAISE WARNING 'No user found for agent_phone_number: %', NEW.agent_phone_number;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.auto_assign_lead_user IS 'Automatically assigns user_id to leads based on agent_phone_number lookup';

-- Helper function for manual lead assignment (optional, for admin use)
CREATE OR REPLACE FUNCTION public.assign_lead_to_user(
    p_lead_id UUID,
    p_agent_phone_number TEXT
)
RETURNS VOID AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Find user_id by agent_phone_number
    SELECT user_id INTO v_user_id
    FROM public.user_profiles
    WHERE agent_phone_number = p_agent_phone_number
    LIMIT 1;
    
    -- Update the lead with the user_id
    IF v_user_id IS NOT NULL THEN
        UPDATE public.leads
        SET user_id = v_user_id
        WHERE id = p_lead_id;
    ELSE
        RAISE EXCEPTION 'No user found with agent_phone_number: %', p_agent_phone_number;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.assign_lead_to_user IS 'Helper function to manually assign a lead to a user by agent phone number';

-- =============================================
-- PART 6: CREATE TRIGGERS
-- =============================================

-- Trigger to auto-update updated_at on leads
CREATE TRIGGER update_leads_updated_at
    BEFORE UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger to auto-update updated_at on user_profiles
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger to auto-assign user_id to leads
CREATE TRIGGER auto_assign_lead_user_trigger
    BEFORE INSERT OR UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_lead_user();

-- =============================================
-- PART 7: GRANT PERMISSIONS
-- =============================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Grant permissions on tables
GRANT ALL ON public.user_profiles TO service_role;
GRANT ALL ON public.leads TO service_role;
GRANT ALL ON public.lead_activities TO service_role;

GRANT SELECT ON public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.leads TO authenticated;
GRANT SELECT, INSERT ON public.lead_activities TO authenticated;

-- =============================================
-- VERIFICATION AND COMPLETION
-- =============================================

DO $$ 
DECLARE
    table_count INTEGER;
    policy_count INTEGER;
    trigger_count INTEGER;
    index_count INTEGER;
BEGIN
    -- Count created objects
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('user_profiles', 'leads', 'lead_activities');
    
    SELECT COUNT(*) INTO policy_count 
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('user_profiles', 'leads', 'lead_activities');
    
    SELECT COUNT(*) INTO trigger_count 
    FROM pg_trigger 
    WHERE tgrelid IN (
        'public.leads'::regclass,
        'public.user_profiles'::regclass
    );
    
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND tablename IN ('user_profiles', 'leads', 'lead_activities');
    
    -- Report results
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'DATABASE BUILD COMPLETE!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Tables created: %', table_count;
    RAISE NOTICE 'RLS policies created: %', policy_count;
    RAISE NOTICE 'Triggers created: %', trigger_count;
    RAISE NOTICE 'Indexes created: %', index_count;
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Create test user accounts via signup';
    RAISE NOTICE '2. Test webhook with Retell AI';
    RAISE NOTICE '3. Verify data isolation between users';
    RAISE NOTICE '4. Check analytics and real-time updates';
    RAISE NOTICE '=============================================';
    
    -- Verify critical setup
    IF table_count < 3 THEN
        RAISE WARNING 'Expected 3 tables but found %', table_count;
    END IF;
    
    IF policy_count < 10 THEN
        RAISE WARNING 'Expected at least 10 RLS policies but found %', policy_count;
    END IF;
END $$;

