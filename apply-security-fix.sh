#!/bin/bash

# CRITICAL SECURITY FIX SCRIPT
# This script applies the RLS security fix to your Supabase database

echo "🔒 APPLYING CRITICAL SECURITY FIX..."
echo "This will fix the issue where all users can see all leads"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please make sure your .env file exists with Supabase credentials"
    exit 1
fi

# Extract Supabase URL from .env
SUPABASE_URL=$(grep VITE_SUPABASE_URL .env | cut -d '=' -f2)
SUPABASE_ANON_KEY=$(grep VITE_SUPABASE_ANON_KEY .env | cut -d '=' -f2)

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: Could not find Supabase credentials in .env file"
    echo "Make sure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are set"
    exit 1
fi

echo "✅ Found Supabase credentials"
echo "📡 Supabase URL: $SUPABASE_URL"
echo ""

echo "🚀 Applying RLS security fix..."
echo "This will:"
echo "  - Drop existing insecure policies"
echo "  - Create proper user-specific policies"
echo "  - Add test leads for the new user"
echo "  - Ensure each user only sees their own leads"
echo ""

# Note: This would typically be run through Supabase CLI or dashboard
echo "⚠️  IMPORTANT: You need to run the SQL fix manually:"
echo ""
echo "1. Go to your Supabase dashboard: https://supabase.com/dashboard"
echo "2. Navigate to your project"
echo "3. Go to SQL Editor"
echo "4. Copy and paste the contents of 'fix-rls-security.sql'"
echo "5. Click 'Run' to execute the SQL"
echo ""
echo "📄 The SQL file is located at: fix-rls-security.sql"
echo ""
echo "After running the SQL, restart your development server:"
echo "  npm run dev"
echo ""
echo "Then test the application - each user should only see their own leads!"
