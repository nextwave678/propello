export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      leads: {
        Row: {
          id: string
          created_at: string
          updated_at: string
          name: string
          phone: string
          email: string | null
          type: 'buyer' | 'seller'
          timeframe: string
          property_details: string | null
          lead_quality: 'hot' | 'warm' | 'cold'
          status: 'new' | 'contacted' | 'qualified' | 'closed' | 'dead'
          call_duration: number | null
          call_transcript: string | null
          call_recording_url: string | null
          notes: string[]
          tags: string[]
          assigned_to: string | null
          is_archived: boolean
        }
        Insert: {
          id?: string
          created_at?: string
          updated_at?: string
          name: string
          phone: string
          email?: string | null
          type: 'buyer' | 'seller'
          timeframe: string
          property_details?: string | null
          lead_quality: 'hot' | 'warm' | 'cold'
          status?: 'new' | 'contacted' | 'qualified' | 'closed' | 'dead'
          call_duration?: number | null
          call_transcript?: string | null
          call_recording_url?: string | null
          notes?: string[]
          tags?: string[]
          assigned_to?: string | null
          is_archived?: boolean
        }
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          name?: string
          phone?: string
          email?: string | null
          type?: 'buyer' | 'seller'
          timeframe?: string
          property_details?: string | null
          lead_quality?: 'hot' | 'warm' | 'cold'
          status?: 'new' | 'contacted' | 'qualified' | 'closed' | 'dead'
          call_duration?: number | null
          call_transcript?: string | null
          call_recording_url?: string | null
          notes?: string[]
          tags?: string[]
          assigned_to?: string | null
          is_archived?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "leads_assigned_to_fkey"
            columns: ["assigned_to"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      lead_activities: {
        Row: {
          id: string
          created_at: string
          lead_id: string
          performed_by: string | null
          activity_type: string
          description: string | null
          metadata: Json | null
        }
        Insert: {
          id?: string
          created_at?: string
          lead_id: string
          performed_by?: string | null
          activity_type: string
          description?: string | null
          metadata?: Json | null
        }
        Update: {
          id?: string
          created_at?: string
          lead_id?: string
          performed_by?: string | null
          activity_type?: string
          description?: string | null
          metadata?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "lead_activities_lead_id_fkey"
            columns: ["lead_id"]
            isOneToOne: false
            referencedRelation: "leads"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lead_activities_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

