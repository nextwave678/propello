# Fix Data Isolation and Loading Issues

## Problems Identified

1. **Schema Mismatch**: Old migration used `ai_agent_number` but code expects `agent_phone_number`
2. **Wrong Data Filtering**: Leads were filtered by `agent_phone_number` instead of `user_id`, causing multiple users to see the same leads
3. **Missing RLS Policies**: Leads table didn't have proper Row Level Security to isolate data by user
4. **Infinite Loading**: Auth flow didn't handle profile loading errors properly

## Solutions Applied

### 1. Database Migration
Created a new migration file that:
- Drops and recreates `user_profiles` table with correct schema
- Adds `user_id` column to `leads` table
- Implements proper RLS policies for data isolation
- Adds a trigger to auto-assign `user_id` based on `agent_phone_number`

### 2. Updated SupabaseService
- Changed lead filtering from `agent_phone_number` to `user_id`
- Added user_id-based queries for proper data isolation
- Each user now only sees their own leads

### 3. Updated Webhook
- Webhook now looks up `user_id` from `agent_phone_number` before inserting leads
- Uses service role key for admin access (bypasses RLS)
- Properly assigns leads to users

### 4. Improved Auth Error Handling
- Added timeout protection (10 seconds) for profile loading
- Auto-logout if profile fails to load
- Prevents infinite loading states
- Better error logging

## Deployment Steps

### Step 1: Apply the Database Migration

You need to apply the new migration to your Supabase database:

#### Option A: Using Supabase CLI (Recommended)

```bash
# If you have Supabase CLI installed
cd /Users/teamdickey/propelloai
supabase db push
```

#### Option B: Using Supabase Dashboard

1. Go to your Supabase project: https://app.supabase.com/project/yzxbjcqgokzbqkiiqnar
2. Navigate to **SQL Editor**
3. Open the migration file: `supabase/migrations/20241104000000_fix_user_profiles_schema.sql`
4. Copy the entire contents
5. Paste into SQL Editor and click **Run**

### Step 2: Update Existing Data

After running the migration, you need to:

1. **Recreate User Profiles**: Existing users need to have their profiles recreated with the new schema
2. **Assign user_id to existing leads**: Run this SQL to assign user_id to any existing leads:

```sql
-- Update existing leads to have user_id based on agent_phone_number
UPDATE leads l
SET user_id = (
  SELECT user_id 
  FROM user_profiles up 
  WHERE up.agent_phone_number = l.agent_phone_number 
  LIMIT 1
)
WHERE user_id IS NULL AND agent_phone_number IS NOT NULL;
```

### Step 3: Set Up Service Role Key for Webhook

The webhook needs a service role key (not anon key) to bypass RLS:

1. Go to Supabase Dashboard > Settings > API
2. Copy the **service_role** key (not the anon key!)
3. Add it to your Vercel environment variables:
   - Go to your Vercel project settings
   - Navigate to **Environment Variables**
   - Add: `SUPABASE_SERVICE_ROLE_KEY` = `your-service-role-key`
4. Redeploy your Vercel project for the changes to take effect

**⚠️ IMPORTANT**: Never expose the service role key in client-side code! It should only be used in the webhook (server-side).

### Step 4: Test with Demo Accounts

1. Create two fresh demo accounts with different phone numbers
2. Use different `agent_phone_number` values for each account
3. Trigger test calls to each agent phone number
4. Verify that:
   - Each user only sees their own leads
   - Login completes successfully (no infinite loading)
   - Leads are properly assigned to the correct user

### Step 5: Fix Existing User Profiles

If you have existing users in the old schema, you'll need to migrate them:

```sql
-- Example: Manually create user profiles for existing auth users
-- Replace the values with actual data from your users

INSERT INTO user_profiles (user_id, email, full_name, agent_phone_number, agent_id, plan, is_active)
VALUES 
  ('user-uuid-1', 'demo1@example.com', 'Demo User 1', '+1234567890', 'agent-id-1', 'free', true),
  ('user-uuid-2', 'demo2@example.com', 'Demo User 2', '+1987654321', 'agent-id-2', 'free', true)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  agent_phone_number = EXCLUDED.agent_phone_number,
  agent_id = EXCLUDED.agent_id,
  plan = EXCLUDED.plan,
  is_active = EXCLUDED.is_active;
```

## Verification Checklist

- [ ] Migration applied successfully
- [ ] Existing leads have `user_id` assigned
- [ ] User profiles recreated with new schema
- [ ] Service role key added to Vercel env vars
- [ ] Webhook redeployed
- [ ] Two demo accounts created with different phone numbers
- [ ] Each user only sees their own leads
- [ ] Login works without infinite loading
- [ ] New leads are properly assigned to users via webhook

## Troubleshooting

### "No user profile found" error
- Check that user_profiles table has the correct schema
- Verify that the user has a profile in the database
- Check the `user_id` matches between auth.users and user_profiles

### Users still seeing the same leads
- Verify RLS policies are enabled on the leads table
- Check that leads have `user_id` assigned
- Make sure you're using the latest code (not cached)
- Clear browser cache and localStorage

### Infinite loading on login
- Check browser console for errors
- Verify Supabase connection is working
- Check that user profile exists and can be loaded
- The timeout is set to 10 seconds - if it takes longer, there may be a network issue

### Webhook not assigning user_id
- Verify service role key is set in Vercel
- Check Vercel function logs for errors
- Verify `agent_phone_number` in webhook payload matches user profile
- Check that user profile exists before testing webhook

## Database Schema Changes

### user_profiles (Before)
```sql
- id UUID (references auth.users)
- ai_agent_number TEXT  ❌ Wrong!
```

### user_profiles (After)
```sql
- id UUID (primary key)
- user_id UUID (references auth.users) ✅
- agent_phone_number TEXT ✅
- email TEXT
- full_name TEXT
- company_name TEXT
- agent_id TEXT
- plan TEXT (free/pro/enterprise)
- is_active BOOLEAN
```

### leads (Added)
```sql
- user_id UUID (references auth.users) ✅ NEW!
```

## Code Changes Summary

1. **supabaseService.ts**: Filter by `user_id` instead of `agent_phone_number`
2. **webhook.js**: Lookup and assign `user_id` when creating leads
3. **AuthContext.tsx**: Better error handling with timeouts
4. **Migration**: New schema, RLS policies, and trigger

All changes have been committed. Follow the deployment steps above to apply them to your production environment.

