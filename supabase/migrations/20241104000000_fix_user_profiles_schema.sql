-- Migration: Fix user_profiles schema and improve data isolation
-- This fixes the mismatch between database schema and application code

-- =============================================
-- DROP OLD USER_PROFILES TABLE AND RECREATE
-- =============================================

-- First, drop the old table if it exists (careful with existing data!)
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- Recreate user_profiles table with correct schema matching the application
CREATE TABLE public.user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    agent_phone_number TEXT NOT NULL, -- The phone number for the AI agent
    agent_id TEXT, -- Retell AI agent ID
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
    is_active BOOLEAN DEFAULT true
);

-- =============================================
-- ADD USER_ID TO LEADS TABLE FOR PROPER ISOLATION
-- =============================================

-- Add user_id column to leads table if it doesn't exist
ALTER TABLE public.leads 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_leads_user_id ON public.leads(user_id);

-- =============================================
-- UPDATE ROW LEVEL SECURITY POLICIES
-- =============================================

-- Enable RLS on user_profiles if not already enabled
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;

-- Recreate policies for user_profiles
CREATE POLICY "Users can view their own profile" 
ON public.user_profiles
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" 
ON public.user_profiles
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" 
ON public.user_profiles
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Enable RLS on leads table if not already enabled
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Users can view their own leads" ON public.leads;
DROP POLICY IF EXISTS "Service role can insert leads" ON public.leads;
DROP POLICY IF EXISTS "Users can insert their own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can update their own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can delete their own leads" ON public.leads;

-- Create RLS policies for leads table
CREATE POLICY "Users can view their own leads" 
ON public.leads
FOR SELECT 
USING (auth.uid() = user_id);

-- Allow service role to insert leads (for webhook)
-- Service role bypasses RLS anyway, but this makes it explicit
CREATE POLICY "Service role can insert leads" 
ON public.leads
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Users can insert their own leads" 
ON public.leads
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own leads" 
ON public.leads
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own leads" 
ON public.leads
FOR DELETE 
USING (auth.uid() = user_id);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- User profiles indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone_number ON public.user_profiles(agent_phone_number);

-- =============================================
-- FUNCTION TO UPDATE user_id ON EXISTING LEADS
-- =============================================

-- This function will be called by webhook to assign leads to users
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
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- TRIGGER TO AUTO-ASSIGN LEADS
-- =============================================

-- Create a trigger function to automatically assign user_id based on agent_phone_number
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
        
        NEW.user_id := v_user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS auto_assign_lead_user_trigger ON public.leads;
CREATE TRIGGER auto_assign_lead_user_trigger
    BEFORE INSERT OR UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_lead_user();

