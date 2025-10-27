-- Fix email confirmation issues in Supabase
-- This script helps ensure email confirmation is properly disabled

-- Check current auth settings
SELECT 
    key,
    value
FROM auth.config
WHERE key IN ('DISABLE_SIGNUP', 'SITE_URL', 'SMTP_ADMIN_EMAIL');

-- Update auth settings to disable email confirmation
-- Note: These settings need to be updated in the Supabase Dashboard under Authentication > Settings
-- This is just for reference - the actual changes need to be made in the Supabase Dashboard

-- Recommended Supabase Dashboard settings:
-- 1. Go to Authentication > Settings
-- 2. Under "User Signups", set "Enable email confirmations" to OFF
-- 3. Under "User Signups", set "Enable phone confirmations" to OFF
-- 4. Under "User Signups", set "Enable email change confirmations" to OFF

-- Alternative: If you need to manually confirm users, you can run this:
-- UPDATE auth.users 
-- SET email_confirmed_at = NOW() 
-- WHERE email_confirmed_at IS NULL 
-- AND email IN ('sarah.test@premierrealty.com', 'testuser@gmail.com', 'michael.test@luxuryhomes.com');

-- Check users with unconfirmed emails
SELECT 
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users 
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- If needed, manually confirm specific users
-- UPDATE auth.users 
-- SET email_confirmed_at = NOW() 
-- WHERE email = 'sarah.test@premierrealty.com';

-- UPDATE auth.users 
-- SET email_confirmed_at = NOW() 
-- WHERE email = 'testuser@gmail.com';

-- UPDATE auth.users 
-- SET email_confirmed_at = NOW() 
-- WHERE email = 'michael.test@luxuryhomes.com';

-- Verify the fix
SELECT 
    id,
    email,
    email_confirmed_at,
    CASE 
        WHEN email_confirmed_at IS NOT NULL THEN 'Confirmed'
        ELSE 'Not Confirmed'
    END as status
FROM auth.users 
WHERE email IN ('sarah.test@premierrealty.com', 'testuser@gmail.com', 'michael.test@luxuryhomes.com')
ORDER BY email;
