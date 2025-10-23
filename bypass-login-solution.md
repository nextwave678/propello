# Bypass Login Issue - Use Signup Flow

## Problem
The login is failing with 500 errors, likely due to Supabase project configuration issues.

## Solution
Use the signup flow instead of login for testing.

## Steps

### 1. Run the SQL Script
Execute `simple-signup-test.sql` in your Supabase SQL Editor to create user profiles and sample leads.

### 2. Test Signup Flow
1. Go to your app's signup page
2. Create accounts with these emails:
   - `sarah@premierrealty.com`
   - `michael@luxuryhomes.com`
3. Use any password you want
4. The app will create auth users and link them to profiles

### 3. Verify in Supabase Dashboard
1. Go to Authentication > Users
2. Check if users were created
3. Verify they have the correct email addresses

## Alternative: Check Supabase Project
1. Go to Settings > API
2. Copy the full "anon public" key (should be much longer than what was provided)
3. Update the key in your code if needed

## Expected Result
- Users can sign up successfully
- User profiles are created and linked
- Sample leads are available for testing
- Authentication works for the session
