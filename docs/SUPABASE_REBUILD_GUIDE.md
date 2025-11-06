# Supabase Rebuild vs Migration Decision Guide

## Current Situation Analysis

Your Supabase database has schema issues that need to be fixed:
- ❌ `user_profiles` table has incorrect schema
- ❌ `leads` table missing `user_id` column for proper isolation
- ❌ RLS policies need updating
- ❌ Missing triggers for auto-assignment

## Option 1: Apply Migration (Recommended for Most Cases)

### What the Migration Does
✅ Drops and recreates `user_profiles` table with correct schema  
✅ Adds `user_id` column to existing `leads` table  
✅ Updates all RLS policies  
✅ Adds triggers for automatic user_id assignment  
✅ Creates necessary indexes  

### Data Impact
- ⚠️ **LOSES**: All `user_profiles` data (user accounts)
- ✅ **PRESERVES**: All `leads` data
- ⚠️ **REQUIRES**: Users to re-signup or manual profile recreation

### When to Use
- ✅ Development/testing environment
- ✅ Small number of users (<10) that can re-signup
- ✅ You have user email/info backed up
- ✅ Leads data is valuable and must be preserved

### Steps to Apply Migration

#### Step 1: Backup Current Data (CRITICAL!)

```sql
-- In Supabase SQL Editor, export current data:

-- Backup user_profiles
SELECT * FROM user_profiles;
-- Copy results to CSV or save query results

-- Backup leads (should be fine, but safety first)
SELECT * FROM leads;
-- Save to CSV

-- Backup auth users
SELECT id, email, created_at FROM auth.users;
-- Save this mapping
```

#### Step 2: Apply the Migration

**Option A: Via Supabase Dashboard**
1. Go to https://app.supabase.com/project/yzxbjcqgokzbqkiiqnar
2. Navigate to SQL Editor
3. Click "New Query"
4. Copy entire contents of `supabase/migrations/20241104000000_fix_user_profiles_schema.sql`
5. Click **Run**
6. Verify no errors

**Option B: Via Supabase CLI** (if installed)
```bash
cd /Users/teamdickey/propelloai
supabase db push
```

#### Step 3: Recreate User Profiles

**Option A: Users Re-signup** (Easiest)
1. Have users go to signup page
2. They create new accounts with same email
3. Profiles auto-created with new schema

**Option B: Manual Recreation** (If you have backup)
```sql
-- For each user from backup:
INSERT INTO user_profiles (user_id, email, full_name, agent_phone_number, agent_id, plan, is_active)
VALUES 
  (
    'user-uuid-from-auth-users',  -- From backup
    'user@example.com',
    'User Name',
    '+1234567890',  -- Their AI agent phone number
    'retell-agent-id',
    'free',
    true
  );
```

#### Step 4: Update Existing Leads

```sql
-- Assign user_id to existing leads based on agent_phone_number
UPDATE leads l
SET user_id = (
  SELECT user_id 
  FROM user_profiles up 
  WHERE up.agent_phone_number = l.agent_phone_number 
  LIMIT 1
)
WHERE user_id IS NULL AND agent_phone_number IS NOT NULL;
```

#### Step 5: Verify Everything Works

```sql
-- Check user_profiles
SELECT * FROM user_profiles LIMIT 5;

-- Check leads have user_id
SELECT id, name, user_id, agent_phone_number FROM leads LIMIT 5;

-- Check RLS policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'leads');
```

---

## Option 2: Complete Rebuild from Scratch

### When to Consider This
- ❌ You have corrupted data
- ❌ Testing phase with no real users
- ❌ Want completely fresh start
- ❌ Have significant schema mismatches beyond what migration fixes

### Data Impact
- ❌ **LOSES**: Everything (all users, all leads, all data)
- ✅ **GAINS**: Clean slate, no legacy issues

### Steps for Complete Rebuild

#### Step 1: Export All Data (If Needed)

```bash
# Export to CSV from Supabase Dashboard
# Tables → leads → Export to CSV
# Tables → user_profiles → Export to CSV
```

#### Step 2: Delete Tables

```sql
-- In Supabase SQL Editor:
DROP TABLE IF EXISTS public.lead_activities CASCADE;
DROP TABLE IF EXISTS public.leads CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- Also clean up auth users if needed
-- (Be VERY careful with this!)
-- DELETE FROM auth.users;
```

#### Step 3: Run Fresh Schema

Create a new migration file or run this:

```sql
-- Create user_profiles table
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

-- Create leads table
CREATE TABLE public.leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    type TEXT NOT NULL CHECK (type IN ('buyer', 'seller')),
    timeframe TEXT NOT NULL,
    property_details TEXT,
    lead_quality TEXT NOT NULL CHECK (lead_quality IN ('hot', 'warm', 'cold')),
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed', 'dead')),
    call_duration INTEGER,
    call_transcript TEXT,
    call_recording_url TEXT,
    notes TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    is_archived BOOLEAN DEFAULT FALSE,
    completion_status TEXT CHECK (completion_status IN ('successful', 'on_the_fence', 'unsuccessful')),
    completed_at TIMESTAMP WITH TIME ZONE,
    agent_phone_number TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create lead_activities table
CREATE TABLE public.lead_activities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    performed_by UUID REFERENCES auth.users(id),
    activity_type TEXT NOT NULL,
    description TEXT,
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_agent_phone_number ON user_profiles(agent_phone_number);
CREATE INDEX idx_leads_user_id ON leads(user_id);
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_quality ON leads(lead_quality);
CREATE INDEX idx_activities_lead_id ON lead_activities(lead_id);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_activities ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Users can view their own profile" 
ON user_profiles FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" 
ON user_profiles FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" 
ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for leads
CREATE POLICY "Users can view their own leads" 
ON leads FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert leads" 
ON leads FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can insert their own leads" 
ON leads FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own leads" 
ON leads FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own leads" 
ON leads FOR DELETE USING (auth.uid() = user_id);

-- Auto-assign trigger
CREATE OR REPLACE FUNCTION auto_assign_lead_user()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
    IF NEW.user_id IS NULL AND NEW.agent_phone_number IS NOT NULL THEN
        SELECT user_id INTO v_user_id
        FROM user_profiles
        WHERE agent_phone_number = NEW.agent_phone_number
        LIMIT 1;
        NEW.user_id := v_user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_assign_lead_user_trigger
    BEFORE INSERT OR UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION auto_assign_lead_user();
```

#### Step 4: Re-import Data (If Applicable)

```sql
-- Import leads from CSV (if you exported)
-- Use Supabase Dashboard → Table Editor → Import CSV

-- Or manually:
INSERT INTO leads (...) VALUES (...);
```

---

## 📊 Decision Matrix

| Factor | Apply Migration | Complete Rebuild |
|--------|----------------|------------------|
| **Time Required** | 15-30 minutes | 1-2 hours |
| **Data Preserved** | Leads ✅ | Nothing ❌ |
| **Risk Level** | Medium | High |
| **Complexity** | Low | Medium |
| **Best For** | Production with valuable leads | Fresh start, testing |
| **Downtime** | ~5 minutes | 30+ minutes |

---

## 🎯 My Recommendation

### If you have ANY production leads → **Apply Migration (Option 1)**

**Reasons:**
1. Your leads are valuable data - don't lose them
2. Migration is designed to fix all issues
3. Users can re-signup quickly
4. Lower risk, faster execution
5. Can always rebuild later if needed

### Steps:
1. ✅ Backup current data (5 min)
2. ✅ Apply migration (5 min)
3. ✅ Have users re-signup OR manually recreate profiles (10-15 min)
4. ✅ Verify everything works (5 min)
5. ✅ Test with one webhook to confirm lead routing (5 min)

**Total time: ~30 minutes**

---

## 🚨 Important Notes

### Before Either Option:

1. **Test in development first** if possible
2. **Schedule during low-traffic time**
3. **Notify users** of brief maintenance
4. **Have backup of all data**
5. **Keep old Supabase project URL handy** (just in case)

### After Either Option:

1. ✅ Test user signup
2. ✅ Test user login
3. ✅ Send test webhook
4. ✅ Verify lead appears for correct user
5. ✅ Verify other users can't see the lead
6. ✅ Test real-time updates
7. ✅ Test analytics page

---

## ❓ Still Unsure? Answer These Questions:

1. **How many users do you currently have?**
   - 0-5 → Either option fine
   - 5-20 → Migration recommended
   - 20+ → Definitely migration

2. **Do you have production leads you want to keep?**
   - Yes → Migration only
   - No → Either option

3. **Are you in development/testing phase?**
   - Yes → Rebuild might be cleaner
   - No → Migration safer

4. **Do you have time to manually recreate user profiles?**
   - Yes → Migration
   - No → Consider rebuild if very few users

---

## 🆘 Need Help?

If you're unsure which option to choose, I can:
1. Check your current Supabase state
2. Count existing users/leads
3. Create a custom migration plan
4. Help execute whichever option you choose

Just let me know your situation and I'll guide you through it!

