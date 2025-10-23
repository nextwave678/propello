import { User } from '@supabase/supabase-js'

export interface UserProfile {
  id: string
  user_id: string
  created_at: string
  email: string
  full_name: string | null
  company_name: string | null
  agent_phone_number: string
  agent_id: string | null
  plan: 'free' | 'pro' | 'enterprise'
  is_active: boolean
}

export interface AuthContextType {
  user: User | null
  profile: UserProfile | null
  loading: boolean
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  signup: (data: SignupData) => Promise<void>
  logout: () => Promise<void>
  refreshProfile: () => Promise<void>
}

export interface SignupData {
  email: string
  password: string
  fullName: string
  companyName?: string
  agentPhoneNumber: string
}

export interface LoginData {
  email: string
  password: string
  rememberMe?: boolean
}
