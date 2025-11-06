-- =============================================
-- FIX AUTHENTICATION AND PROFILE CREATION
-- =============================================
-- This migration fixes the "chicken and egg" problem where users
-- need to be authenticated before creating their profile.
-- 
-- Solution: Use a database trigger to automatically create
-- user profiles when a new auth user is created.
-- =============================================

-- Drop existing insert policy that causes the chicken-and-egg problem
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;

-- Create a more permissive insert policy for authenticated users
-- This allows newly signed-up users to create their profile
CREATE POLICY "Authenticated users can insert their profile" 
ON public.user_profiles
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Create a function to auto-create user profile on signup
-- This runs with elevated privileges (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new user profile with default values
  -- The user can update these later via the app
  INSERT INTO public.user_profiles (
    user_id,
    email,
    full_name,
    agent_phone_number,
    plan,
    is_active
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'agent_phone_number', ''),
    'free',
    true
  )
  ON CONFLICT (user_id) DO NOTHING; -- Prevent duplicate profile creation
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.handle_new_user IS 'Automatically creates user profile when new auth user signs up';

-- Create trigger on auth.users table
-- This fires AFTER a new user is created in the auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.user_profiles TO postgres, service_role;
GRANT SELECT, UPDATE ON public.user_profiles TO authenticated;

-- Add policy to allow users to update their profile after creation
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile" 
ON public.user_profiles
FOR UPDATE 
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Verification
DO $$ 
BEGIN
  RAISE NOTICE '=============================================';
  RAISE NOTICE 'AUTH FIX COMPLETE!';
  RAISE NOTICE '=============================================';
  RAISE NOTICE 'Changes made:';
  RAISE NOTICE '1. Created handle_new_user() trigger function';
  RAISE NOTICE '2. Updated RLS policies for better auth flow';
  RAISE NOTICE '3. Auto-profile creation enabled on signup';
  RAISE NOTICE '';
  RAISE NOTICE 'Users can now:';
  RAISE NOTICE '- Sign up without pre-existing profile';
  RAISE NOTICE '- Have profile auto-created on signup';
  RAISE NOTICE '- Update their profile after creation';
  RAISE NOTICE '=============================================';
END $$;

