import React from 'react'
import { Phone, Mail, Calendar, Clock, User, MapPin } from 'lucide-react'
import { Lead } from '../../types/lead.types'
import { formatDistanceToNow } from 'date-fns'

interface LeadCardProps {
  lead: Lead
  onClick?: (lead: Lead) => void
}

const LeadCard: React.FC<LeadCardProps> = ({ lead, onClick }) => {
  const getQualityBadge = (quality: string) => {
    switch (quality) {
      case 'hot':
        return 'badge-hot'
      case 'warm':
        return 'badge-warm'
      case 'cold':
        return 'badge-cold'
      default:
        return 'badge-cold'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'new':
        return 'text-status-new bg-status-new bg-opacity-10'
      case 'contacted':
        return 'text-status-contacted bg-status-contacted bg-opacity-10'
      case 'qualified':
        return 'text-status-qualified bg-status-qualified bg-opacity-10'
      case 'closed':
        return 'text-status-closed bg-status-closed bg-opacity-10'
      case 'dead':
        return 'text-status-dead bg-status-dead bg-opacity-10'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const formatPhone = (phone: string) => {
    // Simple phone formatting - can be enhanced
    const cleaned = phone.replace(/\D/g, '')
    if (cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`
    }
    return phone
  }

  return (
    <div 
      className={`propello-card lead-card ${lead.lead_quality} cursor-pointer hover:shadow-lg transition-all duration-200`}
      onClick={() => onClick?.(lead)}
    >
      {/* Header with name and quality */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 mb-1">
            {lead.name}
          </h3>
          <div className="flex items-center space-x-2">
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getQualityBadge(lead.lead_quality)}`}>
              {lead.lead_quality.toUpperCase()}
            </span>
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(lead.status)}`}>
              {lead.status.charAt(0).toUpperCase() + lead.status.slice(1)}
            </span>
          </div>
        </div>
        <div className="text-right">
          <span className="text-sm text-gray-500">
            {formatDistanceToNow(new Date(lead.created_at), { addSuffix: true })}
          </span>
        </div>
      </div>

      {/* Contact Information */}
      <div className="space-y-2 mb-4">
        <div className="flex items-center text-sm text-gray-600">
          <Phone className="h-4 w-4 mr-2 text-gray-400" />
          <a 
            href={`tel:${lead.phone}`}
            className="hover:text-propello-blue"
            onClick={(e) => e.stopPropagation()}
          >
            {formatPhone(lead.phone)}
          </a>
        </div>
        {lead.email && (
          <div className="flex items-center text-sm text-gray-600">
            <Mail className="h-4 w-4 mr-2 text-gray-400" />
            <a 
              href={`mailto:${lead.email}`}
              className="hover:text-propello-blue truncate"
              onClick={(e) => e.stopPropagation()}
            >
              {lead.email}
            </a>
          </div>
        )}
      </div>

      {/* Lead Details */}
      <div className="space-y-2 mb-4">
        <div className="flex items-center text-sm">
          <User className="h-4 w-4 mr-2 text-gray-400" />
          <span className="text-gray-600">
            {lead.type === 'buyer' ? 'Looking to Buy' : 'Looking to Sell'}
          </span>
        </div>
        <div className="flex items-center text-sm">
          <Calendar className="h-4 w-4 mr-2 text-gray-400" />
          <span className="text-gray-600">{lead.timeframe}</span>
        </div>
        {lead.property_details && (
          <div className="flex items-start text-sm">
            <MapPin className="h-4 w-4 mr-2 text-gray-400 mt-0.5 flex-shrink-0" />
            <span className="text-gray-600 line-clamp-2">{lead.property_details}</span>
          </div>
        )}
      </div>

      {/* Call Information */}
      {lead.call_duration && (
        <div className="flex items-center text-sm text-gray-500 mb-2">
          <Clock className="h-4 w-4 mr-2" />
          <span>{Math.floor(lead.call_duration / 60)}m {lead.call_duration % 60}s call</span>
        </div>
      )}

      {/* Tags */}
      {lead.tags && lead.tags.length > 0 && (
        <div className="flex flex-wrap gap-1 mb-2">
          {lead.tags.slice(0, 3).map((tag, index) => (
            <span 
              key={index}
              className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full"
            >
              {tag}
            </span>
          ))}
          {lead.tags.length > 3 && (
            <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
              +{lead.tags.length - 3} more
            </span>
          )}
        </div>
      )}

      {/* Notes Preview */}
      {lead.notes && lead.notes.length > 0 && (
        <div className="text-sm text-gray-600 bg-gray-50 p-2 rounded">
          <span className="font-medium">Latest note:</span> {lead.notes[lead.notes.length - 1]}
        </div>
      )}
    </div>
  )
}

export default LeadCard

