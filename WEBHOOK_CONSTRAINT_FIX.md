# 🔧 Webhook Constraint Violation Fix

## The Error You're Seeing

```
Supabase error: {
  code: '23514',
  details: null,
  hint: null,
  message: 'new row for relation "leads" violates check constraint "leads_type_check"'
}
```

## What's Happening

The database has strict constraints on certain fields:
- **type**: Must be exactly `'buyer'` or `'seller'` (lowercase)
- **lead_quality**: Must be exactly `'hot'`, `'warm'`, or `'cold'` (lowercase)
- **status**: Must be exactly `'new'`, `'contacted'`, `'qualified'`, `'closed'`, or `'dead'` (lowercase)

Your Retell AI webhook is probably sending values like:
- ❌ `"Buyer"` (capitalized)
- ❌ `"SELLER"` (uppercase)
- ❌ `"Hot"` (capitalized)
- ❌ Some other variant

## The Fix (Already Applied!)

I've updated the webhook (`api/webhook.js`) to automatically normalize these values:

### What It Does Now:

```javascript
// Before inserting into database, the webhook:
1. Converts to lowercase
2. Trims whitespace
3. Validates against allowed values
4. Falls back to safe defaults if invalid
5. Logs warnings when normalization happens
```

### Example:
- Input: `"Buyer"` or `"BUYER"` → Output: `"buyer"` ✅
- Input: `"Seller"` → Output: `"seller"` ✅
- Input: `"Hot Lead"` → Output: `"cold"` (invalid, uses default) ⚠️
- Input: anything invalid → Output: safe default ✅

## How to Apply the Fix

### Option 1: Git Commit & Push (Automatic Deploy)

If you have auto-deploy enabled on Vercel:

```bash
cd /Users/teamdickey/propelloai
git add api/webhook.js
git commit -m "Fix webhook constraint violations with value normalization"
git push
```

Vercel will automatically redeploy with the fix.

### Option 2: Manual Deploy

1. Go to Vercel Dashboard
2. Select your project
3. Click **"Redeploy"** on the latest deployment
4. The new webhook code will be deployed

### Option 3: Direct File Update

If you manually manage your Vercel deployment:
1. The file `api/webhook.js` is already updated in your local workspace
2. Push/deploy however you normally do

## Testing the Fix

### 1. Make a Test Call

Call your AI agent's phone number and complete a test conversation.

### 2. Check Vercel Logs

Go to Vercel → Your Project → Functions → webhook

Look for these log messages:
```
✅ "Lead saved successfully"
```

Or normalization warnings (these are OK):
```
⚠️ "Type normalized from 'Buyer' to 'buyer'"
⚠️ "Lead quality normalized from 'Hot' to 'hot'"
```

### 3. Verify in Supabase

Go to Supabase → Table Editor → leads

Check that the new lead was inserted with:
- `type` = `"buyer"` or `"seller"` (lowercase)
- `lead_quality` = `"hot"`, `"warm"`, or `"cold"` (lowercase)
- `status` = `"new"` (lowercase)

## What Values Are Allowed

### type (REQUIRED)
- ✅ `"buyer"`
- ✅ `"seller"`
- ❌ Anything else defaults to `"buyer"`

### lead_quality (REQUIRED)
- ✅ `"hot"`
- ✅ `"warm"`
- ✅ `"cold"`
- ❌ Anything else defaults to `"cold"`

### status (REQUIRED)
- ✅ `"new"`
- ✅ `"contacted"`
- ✅ `"qualified"`
- ✅ `"closed"`
- ✅ `"dead"`
- ❌ Anything else defaults to `"new"`

## Configuring Retell AI (Optional)

To avoid normalization and ensure clean data, configure your Retell AI agent to send the correct values:

### In Retell Dashboard:

1. Go to your Agent configuration
2. Under **Custom Analysis Data** or **LLM Variables**, set:

```json
{
  "type": "buyer",           // lowercase
  "lead_quality": "warm",    // lowercase
  "status": "new"            // lowercase
}
```

3. Train your LLM to output these exact values

## Files Changed

- ✅ `api/webhook.js` - Added value normalization
- ✅ `supabase/migrations/20241104000000_fix_user_profiles_schema.sql` - Added service role policy
- ✅ `URGENT_FIX_STEPS.md` - Updated with constraint fix info

## Still Getting Errors?

### Check Vercel Logs
1. Go to Vercel → Your Project → Functions
2. Click on the `webhook` function
3. Look for the full error message and payload

### Check What Retell Is Sending
Add this to your webhook temporarily to see the raw data:
```javascript
console.log('Raw webhook data:', JSON.stringify(req.body, null, 2))
```

### Common Issues

**Error: "null value in column 'type'"**
- Your webhook isn't receiving type data from Retell
- The normalization will set it to 'buyer' by default
- Check your Retell configuration

**Error: "invalid input syntax for type json"**
- The `notes` or `tags` field might be malformed
- The fix sets these to empty arrays `[]`

**Error: still getting constraint violations**
- Make sure you've redeployed after the fix
- Check Vercel environment to ensure it's using the latest code
- Clear Vercel's function cache by redeploying

## Next Steps

1. **Redeploy** your webhook (automatic or manual)
2. **Test** with a call
3. **Verify** in logs and database
4. **Configure** Retell to send clean data (optional)
5. **Monitor** for any other constraint violations

---

**Status**: Fix applied, ready to redeploy ✅

