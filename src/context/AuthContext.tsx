import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import { AuthContextType, UserProfile, SignupData } from '../types/auth.types'

// Auth context for managing user authentication state

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
      console.log('Starting login process for email:', email)
      
      // Check Supabase connection first
      const { data: connectionTest } = await supabase.auth.getSession()
      console.log('Supabase connection test:', connectionTest ? 'Connected' : 'Failed')

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      console.log('Supabase auth response:', {
        hasData: !!data,
        hasUser: !!data?.user,
        hasError: !!error,
        errorCode: error?.code,
        errorMessage: error?.message
      })

      if (error) {
        console.error('Supabase auth error details:', {
          code: error.code,
          message: error.message,
          status: error.status,
          name: error.name
        })
        throw error
      }

      if (!data.user) {
        console.error('No user data returned from Supabase auth')
        throw new Error('No user data returned')
      }

      console.log('Auth successful, loading user profile for user ID:', data.user.id)

      // Load user profile
      const userProfile = await loadUserProfile(data.user.id)
      console.log('User profile loaded:', userProfile ? 'Success' : 'Failed')
      
      if (!userProfile) {
        console.error('User profile not found for user ID:', data.user.id)
        throw new Error('User profile not found. Please contact support.')
      }

      console.log('Login successful, setting user and profile')
      setUser(data.user)
      setProfile(userProfile)
    } catch (error: any) {
      console.error('Login error details:', {
        message: error.message,
        code: error.code,
        status: error.status,
        name: error.name,
        stack: error.stack
      })
      
      // Re-throw with more specific error messages
      if (error.message?.includes('Invalid login credentials')) {
        throw new Error('Invalid email or password')
      } else if (error.message?.includes('Email not confirmed') || error.message?.includes('email_not_confirmed')) {
        // Since email confirmation is disabled, this might be a false positive
        // Let's try to proceed anyway or provide a different message
        console.warn('Email confirmation error detected but email confirmation is disabled:', error.message)
        throw new Error('Invalid email or password')
      } else if (error.message?.includes('User profile not found')) {
        throw new Error('Account setup incomplete. Please contact support.')
      } else if (error.code === 'PGRST301') {
        throw new Error('Authentication service temporarily unavailable')
      } else if (error.message?.includes('fetch')) {
        throw new Error('Network error. Please check your connection.')
      }
      
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
        console.log('Initializing auth...')
        
        // Get initial session
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('Error getting session:', error)
          // Still set loading to false even on error
          if (mounted) {
            setLoading(false)
          }
          return
        }

        if (session?.user && mounted) {
          console.log('Session found for user:', session.user.email)
          setUser(session.user)
          
          // Load user profile with timeout
          try {
            const userProfile = await Promise.race<UserProfile | null>([
              loadUserProfile(session.user.id),
              new Promise<never>((_, reject) => 
                setTimeout(() => reject(new Error('Profile load timeout')), 10000)
              )
            ])
            
            if (userProfile && mounted) {
              console.log('Profile loaded successfully')
              setProfile(userProfile)
            } else if (mounted) {
              console.warn('No profile found for user, logging out')
              // If no profile, clear the session
              await supabase.auth.signOut()
              setUser(null)
              setProfile(null)
            }
          } catch (profileError) {
            console.error('Error loading profile:', profileError)
            // Clear auth state if profile fails to load
            if (mounted) {
              await supabase.auth.signOut()
              setUser(null)
              setProfile(null)
            }
          }
        } else {
          console.log('No active session found')
        }
      } catch (error) {
        console.error('Error initializing auth:', error)
      } finally {
        if (mounted) {
          console.log('Auth initialization complete, setting loading to false')
          setLoading(false)
        }
      }
    }

    initializeAuth()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event)
        if (!mounted) return

        try {
          if (event === 'SIGNED_IN' && session?.user) {
            setUser(session.user)
            
            // Load user profile with timeout
            try {
              const userProfile = await Promise.race<UserProfile | null>([
                loadUserProfile(session.user.id),
                new Promise<never>((_, reject) => 
                  setTimeout(() => reject(new Error('Profile load timeout')), 10000)
                )
              ])
              
              if (userProfile) {
                setProfile(userProfile)
              } else {
                console.warn('No profile found after sign in')
                await supabase.auth.signOut()
                setUser(null)
                setProfile(null)
              }
            } catch (profileError) {
              console.error('Error loading profile on sign in:', profileError)
              await supabase.auth.signOut()
              setUser(null)
              setProfile(null)
            }
          } else if (event === 'SIGNED_OUT') {
            setUser(null)
            setProfile(null)
          } else if (event === 'TOKEN_REFRESHED') {
            console.log('Token refreshed')
          } else if (event === 'USER_UPDATED') {
            console.log('User updated')
          }
        } catch (error) {
          console.error('Error handling auth state change:', error)
        } finally {
          setLoading(false)
        }
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
