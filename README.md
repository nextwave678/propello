# Propello - AI Realtor Lead Management Dashboard

A real-time lead management dashboard for real estate professionals using AI phone agents to capture and qualify leads.

## Features

- **Real-time Lead Tracking**: Instant visibility when AI agents capture new leads
- **Intelligent Filtering**: Smart categorization by lead quality (Hot/Warm/Cold), type (Buyer/Seller), and timeframe
- **Actionable Analytics**: Data-driven insights to optimize lead conversion
- **Professional Interface**: Clean, modern design built for real estate professionals

## Tech Stack

- **Frontend**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Deployment**: Vercel
- **Icons**: Lucide React
- **Charts**: Recharts

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account
- Vercel account (for deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/propello.git
cd propello
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp env.example .env
```

Edit `.env` with your Supabase credentials:
```
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

4. Start the development server:
```bash
npm run dev
```

5. Open [http://localhost:5173](http://localhost:5173) in your browser.

## Database Setup

1. Create a new Supabase project
2. Run the SQL schema from `/docs/DATABASE_SCHEMA.md`
3. Configure Row Level Security policies
4. Generate TypeScript types:
```bash
supabase gen types typescript --project-id [your-project-id] > src/lib/database.types.ts
```

## AI Agent Integration

### Retell AI Setup (Recommended)

Propello integrates directly with Retell AI agents. Each agent uses the same webhook endpoint but includes its unique `agent_phone_number` to route leads to the correct user account.

**Webhook Endpoint**: `https://your-project-ref.supabase.co/rest/v1/leads`

**Required Headers**:
```
apikey: your-supabase-anon-key
Authorization: Bearer your-supabase-anon-key
Content-Type: application/json
Prefer: return=representation
```

**Critical**: The webhook payload **must** include the `agent_phone_number` field for proper lead routing:

```json
{
  "name": "{{caller_name}}",
  "phone": "{{caller_phone}}",
  "email": "{{caller_email}}",
  "type": "{{lead_type}}",
  "timeframe": "{{timeframe}}",
  "property_details": "{{property_details}}",
  "lead_quality": "{{lead_quality}}",
  "call_duration": "{{call_duration}}",
  "call_transcript": "{{call_transcript}}",
  "status": "new",
  "agent_phone_number": "+1-555-123-4567"
}
```

See [docs/RETELL_WEBHOOK_SETUP.md](docs/RETELL_WEBHOOK_SETUP.md) for complete setup instructions.

### Multi-User Lead Routing

- Each user provides their AI agent's phone number during signup
- Leads are automatically routed to users based on the `agent_phone_number` field
- Row Level Security ensures users only see their own leads
- All agents use the same webhook endpoint - routing happens via the `agent_phone_number` field

### Make.com Integration (Alternative)

If using Make.com instead of Retell AI, configure your webhook to send data to the same endpoint with the same payload structure including `agent_phone_number`.

## Deployment

### Vercel Deployment

1. Connect your GitHub repository to Vercel
2. Add environment variables in Vercel dashboard
3. Deploy automatically on git push

### Manual Deployment

```bash
npm run build
npm run preview
```

## Project Structure

```
src/
├── components/
│   ├── layout/          # Layout components (Navbar, Sidebar)
│   ├── leads/           # Lead-related components
│   ├── analytics/       # Analytics components
│   └── common/          # Shared components
├── pages/               # Page components
├── services/            # API service layer
├── types/               # TypeScript type definitions
├── hooks/               # Custom React hooks
├── context/             # React context providers
├── lib/                 # Utility libraries
└── utils/               # Helper functions
```

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Code Style

- TypeScript for type safety
- ESLint for code quality
- Prettier for code formatting
- Tailwind CSS for styling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For support, email support@propello.com or create an issue on GitHub.

---

**Propello**: Propelling real estate professionals to success with AI-powered lead management.








