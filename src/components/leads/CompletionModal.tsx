import React, { useState } from 'react'
import { X, CheckCircle, AlertCircle, XCircle } from 'lucide-react'
import { Lead } from '../../types/lead.types'

interface CompletionModalProps {
  isOpen: boolean
  onClose: () => void
  lead: Lead | null
  onComplete: (leadId: string, completionStatus: 'successful' | 'on_the_fence' | 'unsuccessful') => void
}

const CompletionModal: React.FC<CompletionModalProps> = ({
  isOpen,
  onClose,
  lead,
  onComplete
}) => {
  const [selectedStatus, setSelectedStatus] = useState<'successful' | 'on_the_fence' | 'unsuccessful' | null>(null)

  if (!isOpen || !lead) return null

  const handleComplete = () => {
    if (selectedStatus) {
      onComplete(lead.id, selectedStatus)
      setSelectedStatus(null)
      onClose()
    }
  }

  const handleClose = () => {
    setSelectedStatus(null)
    onClose()
  }

  const statusOptions = [
    {
      value: 'successful' as const,
      label: 'Successful',
      description: 'Lead converted to a successful outcome',
      icon: CheckCircle,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
      borderColor: 'border-green-200'
    },
    {
      value: 'on_the_fence' as const,
      label: 'On the Fence',
      description: 'Lead is still considering or needs follow-up',
      icon: AlertCircle,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-50',
      borderColor: 'border-yellow-200'
    },
    {
      value: 'unsuccessful' as const,
      label: 'Unsuccessful',
      description: 'Lead did not convert or is no longer interested',
      icon: XCircle,
      color: 'text-red-600',
      bgColor: 'bg-red-50',
      borderColor: 'border-red-200'
    }
  ]

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        {/* Background overlay */}
        <div 
          className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
          onClick={handleClose}
        />

        {/* Modal panel */}
        <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          {/* Header */}
          <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">
                Mark Lead as Complete
              </h3>
              <button
                onClick={handleClose}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
            
            {/* Lead info */}
            <div className="mb-6 p-3 bg-gray-50 rounded-lg">
              <h4 className="font-medium text-gray-900">{lead.name}</h4>
              <p className="text-sm text-gray-600">{lead.phone}</p>
              {lead.email && (
                <p className="text-sm text-gray-600">{lead.email}</p>
              )}
            </div>

            {/* Status options */}
            <div className="space-y-3">
              <p className="text-sm font-medium text-gray-700 mb-3">
                How would you like to mark this lead?
              </p>
              
              {statusOptions.map((option) => {
                const Icon = option.icon
                const isSelected = selectedStatus === option.value
                
                return (
                  <button
                    key={option.value}
                    onClick={() => setSelectedStatus(option.value)}
                    className={`w-full p-4 rounded-lg border-2 transition-all duration-200 text-left ${
                      isSelected
                        ? `${option.borderColor} ${option.bgColor}`
                        : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    <div className="flex items-start space-x-3">
                      <Icon className={`h-5 w-5 mt-0.5 ${isSelected ? option.color : 'text-gray-400'}`} />
                      <div className="flex-1">
                        <div className={`font-medium ${isSelected ? option.color : 'text-gray-900'}`}>
                          {option.label}
                        </div>
                        <div className="text-sm text-gray-600 mt-1">
                          {option.description}
                        </div>
                      </div>
                      {isSelected && (
                        <CheckCircle className="h-5 w-5 text-green-600" />
                      )}
                    </div>
                  </button>
                )
              })}
            </div>
          </div>

          {/* Footer */}
          <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              onClick={handleComplete}
              disabled={!selectedStatus}
              className={`w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 text-base font-medium text-white sm:ml-3 sm:w-auto sm:text-sm ${
                selectedStatus
                  ? 'bg-propello-blue hover:bg-propello-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-propello-blue'
                  : 'bg-gray-300 cursor-not-allowed'
              }`}
            >
              Mark Complete
            </button>
            <button
              onClick={handleClose}
              className="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-propello-blue sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CompletionModal
