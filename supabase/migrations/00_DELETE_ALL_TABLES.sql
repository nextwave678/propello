-- =============================================
-- DANGER: This script DELETES ALL TABLES and DATA
-- =============================================
-- 
-- Use this to completely reset your Supabase database
-- WARNING: This is IRREVERSIBLE!
-- 
-- Before running:
-- 1. Backup any data you want to keep
-- 2. Export leads to CSV if needed
-- 3. Save user information
-- 
-- This script will:
-- - Drop all custom tables
-- - Remove all RLS policies
-- - Delete all functions/triggers
-- - Clean up auth.users (optional - commented out by default)
-- =============================================

-- Drop triggers first
DROP TRIGGER IF EXISTS auto_assign_lead_user_trigger ON public.leads;
DROP TRIGGER IF EXISTS update_leads_updated_at ON public.leads;
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;

-- Drop functions
DROP FUNCTION IF EXISTS public.auto_assign_lead_user();
DROP FUNCTION IF EXISTS public.assign_lead_to_user(UUID, TEXT);
DROP FUNCTION IF EXISTS public.update_updated_at_column();

-- Drop tables (CASCADE will remove all dependent objects)
DROP TABLE IF EXISTS public.lead_activities CASCADE;
DROP TABLE IF EXISTS public.leads CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- Optional: Delete all auth users (BE VERY CAREFUL!)
-- Uncomment the line below ONLY if you want to delete all user accounts
-- DELETE FROM auth.users;

-- Verify everything is gone
DO $$ 
BEGIN
    RAISE NOTICE 'All tables, triggers, and functions have been dropped.';
    RAISE NOTICE 'You can now run the BUILD script to recreate everything.';
END $$;

