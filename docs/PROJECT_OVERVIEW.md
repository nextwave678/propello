# Propello - AI Realtor Lead Management Dashboard

## App Overview

**Propello** is a real-time lead management dashboard designed specifically for real estate professionals who use AI phone agents to capture and qualify leads. The application provides instant visibility into lead quality, automated data capture, and powerful analytics to maximize conversion rates.

## Core Value Proposition

- **Real-time Lead Tracking**: Instant visibility when AI agents capture new leads
- **Intelligent Filtering**: Smart categorization by lead quality (Hot/Warm/Cold), type (Buyer/Seller), and timeframe
- **Actionable Analytics**: Data-driven insights to optimize lead conversion
- **Professional Interface**: Clean, modern design built for real estate professionals

## User Flow

1. **AI Agent Call**: AI phone agent calls potential client
2. **Data Capture**: Agent collects name, contact info, buying/selling intent, timeframe, property details, and lead quality assessment
3. **Webhook Integration**: Make.com webhook sends structured data to Supabase
4. **Real-time Dashboard**: Propello dashboard displays new lead instantly
5. **Lead Management**: Realtor views, filters, and manages leads with full activity tracking
6. **Analytics**: Comprehensive reporting on lead conversion and performance

## Technology Stack

### Frontend
- **React 18** with TypeScript for type safety
- **Vite** for fast development and optimized builds
- **Tailwind CSS** for responsive, utility-first styling
- **React Router** for client-side navigation
- **Lucide React** for consistent iconography
- **Recharts** for interactive data visualizations
- **React Hot Toast** for user notifications

### Backend & Database
- **Supabase** for PostgreSQL database and real-time subscriptions
- **Row Level Security (RLS)** for data protection
- **REST API** for webhook integration
- **Real-time subscriptions** for live updates

### Deployment & Infrastructure
- **Vercel** for hosting and automatic deployments
- **GitHub** for version control and CI/CD
- **Environment variables** for secure configuration

## Development Environment

- **Platform**: macOS (Darwin 22.6.0)
- **Shell**: /bin/bash
- **Node.js**: v18+ (managed via Homebrew or nvm)
- **Package Manager**: npm
- **IDE**: VS Code with TypeScript support

## Key Features

### Stage 1: Foundation
- Real-time lead display from AI agent calls
- Basic lead cards with quality indicators
- Responsive design for all devices
- Live deployment on Vercel

### Stage 2: Core Management
- Advanced filtering and search
- Detailed lead views with activity history
- Status management and quality updates
- Notes system for lead tracking
- Real-time updates without page refresh

### Stage 3: Analytics & Polish
- Comprehensive analytics dashboard
- Lead conversion tracking
- Performance metrics and insights
- Bulk operations and data export
- Production-ready polish and optimization

## Branding & Design

- **App Name**: Propello
- **Primary Color**: Blue (#2563eb) - Professional, trustworthy
- **Quality Colors**: 
  - Hot: Red (#ef4444) - Urgent, high priority
  - Warm: Orange (#f97316) - Moderate priority
  - Cold: Blue (#3b82f6) - Low priority, nurture
- **Typography**: Clean, modern sans-serif
- **Layout**: Card-based design with clear hierarchy

## Target Users

- **Primary**: Real estate agents and brokers
- **Secondary**: Real estate teams and agencies
- **Use Case**: Managing leads from AI phone agents
- **Platform**: Web-based (works on all devices)

## Success Metrics

- **Performance**: <2 second load time, <100ms interactions
- **Reliability**: 99.9% uptime, real-time updates working
- **Usability**: Intuitive navigation, mobile-responsive
- **Adoption**: Easy onboarding, clear value proposition

## Future Roadmap

- **Phase 2**: CRM integration (HubSpot, Salesforce)
- **Phase 3**: Advanced AI insights and recommendations
- **Phase 4**: Multi-agent support and team collaboration
- **Phase 5**: Mobile app for on-the-go lead management

---

*Propello: Propelling real estate professionals to success with AI-powered lead management.*







