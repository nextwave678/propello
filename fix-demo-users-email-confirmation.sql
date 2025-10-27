-- Fix email confirmation for all demo users
-- Run this in Supabase SQL Editor

-- Update all demo users to have confirmed emails
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email IN (
    'sarah.test@premierrealty.com',
    'testuser@gmail.com', 
    'michael.test@luxuryhomes.com',
    'browsertest@example.com',
    'sarah@premierrealty.com',
    'michael@luxuryhomes.com',
    'carson.dickey128@icloud.com'
) 
AND email_confirmed_at IS NULL;

-- Verify the fix
SELECT 
    email,
    email_confirmed_at,
    CASE 
        WHEN email_confirmed_at IS NOT NULL THEN '✅ Confirmed'
        ELSE '❌ Not Confirmed'
    END as status
FROM auth.users 
WHERE email IN (
    'sarah.test@premierrealty.com',
    'testuser@gmail.com', 
    'michael.test@luxuryhomes.com',
    'browsertest@example.com',
    'sarah@premierrealty.com',
    'michael@luxuryhomes.com',
    'carson.dickey128@icloud.com'
)
ORDER BY email;
