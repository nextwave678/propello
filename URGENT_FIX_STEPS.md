# 🚨 URGENT: Fix Data Isolation & Loading Issues

## Quick Start - Do These Steps NOW

### 1. Apply Database Migration (5 minutes)

Go to: https://app.supabase.com/project/yzxbjcqgokzbqkiiqnar/sql/new

Copy and paste this entire SQL script:

```sql
-- Migration: Fix user_profiles schema and improve data isolation

-- Drop old table and recreate with correct schema
DROP TABLE IF EXISTS public.user_profiles CASCADE;

CREATE TABLE public.user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    agent_phone_number TEXT NOT NULL,
    agent_id TEXT,
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
    is_active BOOLEAN DEFAULT true
);

-- Add user_id to leads table
ALTER TABLE public.leads ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_leads_user_id ON public.leads(user_id);

-- Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;

CREATE POLICY "Users can view their own profile" ON public.user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON public.user_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own profile" ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for leads
DROP POLICY IF EXISTS "Users can view their own leads" ON public.leads;
DROP POLICY IF EXISTS "Service role can insert leads" ON public.leads;
DROP POLICY IF EXISTS "Users can insert their own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can update their own leads" ON public.leads;
DROP POLICY IF EXISTS "Users can delete their own leads" ON public.leads;

CREATE POLICY "Users can view their own leads" ON public.leads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service role can insert leads" ON public.leads FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can insert their own leads" ON public.leads FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own leads" ON public.leads FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own leads" ON public.leads FOR DELETE USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_agent_phone_number ON public.user_profiles(agent_phone_number);

-- Auto-assign user_id trigger
CREATE OR REPLACE FUNCTION public.auto_assign_lead_user() RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
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

DROP TRIGGER IF EXISTS auto_assign_lead_user_trigger ON public.leads;
CREATE TRIGGER auto_assign_lead_user_trigger
    BEFORE INSERT OR UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_lead_user();
```

Click **RUN** ✅

### 2. Update Existing Leads (1 minute)

Run this SQL to assign user_id to existing leads:

```sql
UPDATE leads l
SET user_id = (
  SELECT user_id FROM user_profiles up 
  WHERE up.agent_phone_number = l.agent_phone_number 
  LIMIT 1
)
WHERE user_id IS NULL AND agent_phone_number IS NOT NULL;
```

### 3. Get Service Role Key (2 minutes)

1. Go to: https://app.supabase.com/project/yzxbjcqgokzbqkiiqnar/settings/api
2. Under "Project API keys", find **service_role** key
3. Click "Reveal" and copy it (starts with `eyJhbGc...`)

**⚠️ Keep this secret!**

### 4. Add to Vercel (2 minutes)

1. Go to your Vercel project → Settings → Environment Variables
2. Add new variable:
   - **Name**: `SUPABASE_SERVICE_ROLE_KEY`
   - **Value**: (paste the service role key)
   - **Environment**: All (Production, Preview, Development)
3. Click **Save**

### 5. Redeploy (1 minute)

Go to Vercel → Deployments → ⋯ menu on latest deployment → **Redeploy**

### 6. Recreate Demo User Profiles

Your existing demo users need new profiles. For each user, run:

```sql
-- Replace with actual values for each demo user
INSERT INTO user_profiles (user_id, email, full_name, agent_phone_number, agent_id, plan, is_active)
VALUES 
  (
    'USER-UUID-FROM-AUTH-USERS',  -- Get this from auth.users table
    'demo1@example.com',
    'Demo User 1',
    '+1234567890',  -- This should be UNIQUE for each user!
    'retell-agent-id-1',
    'free',
    true
  )
ON CONFLICT (user_id) DO UPDATE SET
  agent_phone_number = EXCLUDED.agent_phone_number,
  full_name = EXCLUDED.full_name;
```

To get user UUIDs, run:
```sql
SELECT id, email FROM auth.users;
```

### 7. Test (5 minutes)

1. Log out from all accounts
2. Log in to Demo User 1
   - Should load without hanging ✅
   - Should only see their leads ✅
3. Log in to Demo User 2
   - Should load without hanging ✅
   - Should only see their leads (different from User 1) ✅

## What Was Fixed

✅ **Schema Mismatch**: Fixed `user_profiles` table schema  
✅ **Data Isolation**: Leads now filtered by `user_id`, not `agent_phone_number`  
✅ **RLS Policies**: Proper Row Level Security implemented  
✅ **Infinite Loading**: Added timeout and error handling  
✅ **Webhook**: Now properly assigns `user_id` to new leads

## If Something Goes Wrong

### Can't log in / Infinite loading
1. Open browser console (F12)
2. Look for errors
3. Clear localStorage: `localStorage.clear()`
4. Refresh page

### Still seeing wrong leads
1. Check that migration ran successfully
2. Verify user has a profile in `user_profiles` table
3. Check that leads have `user_id` set
4. Clear browser cache

### Webhook not working
1. Check Vercel function logs
2. Verify `SUPABASE_SERVICE_ROLE_KEY` is set
3. Test webhook with curl:
```bash
curl -X POST https://your-app.vercel.app/api/webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"call_analyzed","call":{"to_number":"+1234567890"}}'
```

### Constraint violation error (e.g., "leads_type_check")
This happens when the webhook receives a value that doesn't match the database constraints.

**Fixed!** The webhook now:
- Normalizes `type` to only 'buyer' or 'seller' (lowercase)
- Normalizes `lead_quality` to only 'hot', 'warm', or 'cold' (lowercase)
- Normalizes `status` to only 'new', 'contacted', 'qualified', 'closed', or 'dead' (lowercase)
- Logs warnings when values are normalized

After redeploying, check Vercel logs to see if values are being normalized.

## Need Help?

Check the detailed guide: `docs/FIX_DATA_ISOLATION.md`

---

**Total Time: ~15 minutes**  
**Status**: All code changes are ready, just need to apply to database and Vercel

