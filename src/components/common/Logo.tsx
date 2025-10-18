import React from 'react'

interface LogoProps {
  size?: 'sm' | 'md' | 'lg'
  showText?: boolean
  className?: string
}

const Logo: React.FC<LogoProps> = ({ size = 'md', showText = true, className = '' }) => {
  const sizeClasses = {
    sm: 'w-8 h-8',
    md: 'w-10 h-10',
    lg: 'w-12 h-12'
  }

  const textSizeClasses = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl'
  }

  return (
    <div className={`flex items-center space-x-3 ${className}`}>
      {/* Logo Icon */}
      <div className={`${sizeClasses[size]} relative`}>
        {/* Outer ring */}
        <div className="absolute inset-0 rounded-full border-2 border-navy-600 bg-gradient-to-br from-navy-700 to-navy-800 shadow-lg">
          {/* Inner circle */}
          <div className="absolute inset-1 rounded-full bg-gradient-to-br from-navy-500 to-navy-600 flex items-center justify-center">
            {/* P for Propello */}
            <div className="text-white font-bold text-sm tracking-tight">
              P
            </div>
          </div>
        </div>
        
        {/* Accent dot */}
        <div className="absolute -top-1 -right-1 w-3 h-3 bg-gradient-to-br from-blue-400 to-blue-500 rounded-full shadow-md"></div>
      </div>

      {/* Logo Text */}
      {showText && (
        <div className="flex flex-col">
          <span className={`${textSizeClasses[size]} font-bold text-navy-800 tracking-tight`}>
            Propello
          </span>
          <span className="text-xs text-gray-600 font-medium tracking-wider uppercase">
            AI Realtor
          </span>
        </div>
      )}
    </div>
  )
}

export default Logo
