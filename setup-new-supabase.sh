#!/bin/bash

# =============================================
# Propello AI - New Supabase Setup Script
# =============================================
# This script helps you set up Propello with a new Supabase project
# 
# Prerequisites:
# - You've created a new Supabase project
# - You have your Supabase URL and anon key ready
# =============================================

set -e  # Exit on error

echo ""
echo "🚀 Propello AI - New Supabase Setup"
echo "===================================="
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  Warning: .env file already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Get Supabase credentials
echo "📝 Please enter your Supabase credentials:"
echo "(Find these in your Supabase project → Settings → API)"
echo ""

read -p "Supabase Project URL (e.g., https://xxxxx.supabase.co): " SUPABASE_URL
read -p "Supabase Anon Key: " SUPABASE_ANON_KEY

# Validate inputs
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: URL and Anon Key are required"
    exit 1
fi

# Create .env file
echo ""
echo "📄 Creating .env file..."
cat > .env << EOF
# Supabase Configuration
VITE_SUPABASE_URL=$SUPABASE_URL
VITE_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Optional: For Retell AI webhook (server-side only)
# SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
EOF

echo "✅ .env file created!"
echo ""

# Ask if they want to install dependencies
read -p "Install npm dependencies? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "📦 Installing dependencies..."
    npm install
    echo "✅ Dependencies installed!"
else
    echo "⏭️  Skipping npm install"
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo ""
echo "1. Run database migrations in Supabase:"
echo "   → Go to your Supabase project → SQL Editor"
echo "   → Run: supabase/migrations/01_BUILD_ALL_TABLES.sql"
echo "   → Run: supabase/migrations/02_FIX_AUTH_AND_PROFILE_CREATION.sql"
echo ""
echo "2. Test locally:"
echo "   $ npm run dev"
echo ""
echo "3. Deploy to Vercel:"
echo "   → See VERCEL_DEPLOYMENT_GUIDE.md for instructions"
echo "   → Remember to add environment variables in Vercel!"
echo ""
echo "📚 For detailed instructions, see:"
echo "   - COMPLETE_SETUP_GUIDE.md (Quick start guide)"
echo "   - VERCEL_DEPLOYMENT_GUIDE.md (Deployment guide)"
echo ""
echo "✨ Setup complete! Happy coding!"
echo ""

