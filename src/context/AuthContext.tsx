import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import { AuthContextType, UserProfile, SignupData } from '../types/auth.types'

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

interface AuthProviderProps {
  children: ReactNode
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<UserProfile | null>(null)
  const [loading, setLoading] = useState(true)

  const isAuthenticated = !!user && !!profile

  // Load user profile from database
  const loadUserProfile = async (userId: string): Promise<UserProfile | null> => {
    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', userId)
        .single()

      if (error) {
        console.error('Error loading user profile:', error)
        return null
      }

      return data
    } catch (error) {
      console.error('Error loading user profile:', error)
      return null
    }
  }

  // Login function
  const login = async (email: string, password: string): Promise<void> => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (error) {
        throw error
      }

      if (!data.user) {
        throw new Error('No user data returned')
      }

      // Load user profile
      const userProfile = await loadUserProfile(data.user.id)
      if (!userProfile) {
        throw new Error('User profile not found')
      }

      setUser(data.user)
      setProfile(userProfile)
    } catch (error: any) {
      console.error('Login error:', error)
      throw error
    }
  }

  // Signup function
  const signup = async (signupData: SignupData): Promise<void> => {
    try {
      // Create auth user
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: signupData.email,
        password: signupData.password
      })

      if (authError) {
        throw authError
      }

      if (!authData.user) {
        throw new Error('No user data returned from signup')
      }

      // Create user profile
      const { error: profileError } = await supabase
        .from('user_profiles')
        .insert({
          user_id: authData.user.id,
          email: signupData.email,
          full_name: signupData.fullName,
          company_name: signupData.companyName || null,
          agent_phone_number: signupData.agentPhoneNumber,
          plan: 'free',
          is_active: true
        })

      if (profileError) {
        // If profile creation fails, we should clean up the auth user
        // But for now, just throw the error
        throw profileError
      }

      // Set user and profile
      setUser(authData.user)
      setProfile({
        id: authData.user.id,
        user_id: authData.user.id,
        created_at: new Date().toISOString(),
        email: signupData.email,
        full_name: signupData.fullName,
        company_name: signupData.companyName || null,
        agent_phone_number: signupData.agentPhoneNumber,
        agent_id: null,
        plan: 'free',
        is_active: true
      })
    } catch (error: any) {
      console.error('Signup error:', error)
      throw error
    }
  }

  // Logout function
  const logout = async (): Promise<void> => {
    try {
      await supabase.auth.signOut()
      setUser(null)
      setProfile(null)
    } catch (error) {
      console.error('Logout error:', error)
      throw error
    }
  }

  // Refresh profile function
  const refreshProfile = async (): Promise<void> => {
    if (!user) return

    try {
      const userProfile = await loadUserProfile(user.id)
      if (userProfile) {
        setProfile(userProfile)
      }
    } catch (error) {
      console.error('Error refreshing profile:', error)
    }
  }

  // Initialize auth state
  useEffect(() => {
    let mounted = true

    const initializeAuth = async () => {
      try {
        // Get initial session
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('Error getting session:', error)
          return
        }

        if (session?.user && mounted) {
          setUser(session.user)
          
          // Load user profile
          const userProfile = await loadUserProfile(session.user.id)
          if (userProfile && mounted) {
            setProfile(userProfile)
          }
        }
      } catch (error) {
        console.error('Error initializing auth:', error)
      } finally {
        if (mounted) {
          setLoading(false)
        }
      }
    }

    initializeAuth()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return

        if (event === 'SIGNED_IN' && session?.user) {
          setUser(session.user)
          
          // Load user profile
          const userProfile = await loadUserProfile(session.user.id)
          if (userProfile) {
            setProfile(userProfile)
          }
        } else if (event === 'SIGNED_OUT') {
          setUser(null)
          setProfile(null)
        }

        setLoading(false)
      }
    )

    return () => {
      mounted = false
      subscription.unsubscribe()
    }
  }, [])

  const value: AuthContextType = {
    user,
    profile,
    loading,
    isAuthenticated,
    login,
    signup,
    logout,
    refreshProfile
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}
