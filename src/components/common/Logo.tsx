import React from 'react'

interface LogoProps {
  size?: 'sm' | 'md' | 'lg'
  showText?: boolean
  className?: string
}

const Logo: React.FC<LogoProps> = ({ size = 'md', showText = true, className = '' }) => {

  const textSizeClasses = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl'
  }

  const iconSizeClasses = {
    sm: 'w-6 h-6',
    md: 'w-8 h-8',
    lg: 'w-10 h-10'
  }

  return (
    <div className={`flex items-center space-x-3 ${className}`}>
      {/* House Icon */}
      <div className={`${iconSizeClasses[size]} flex items-center justify-center`}>
        <svg 
          viewBox="0 0 24 24" 
          className="w-full h-full text-white"
          fill="currentColor"
        >
          {/* House structure */}
          <path d="M12 2L2 7v10c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V7L12 2z"/>
          
          {/* Roof windows */}
          <rect x="6" y="8" width="2" height="2" fill="white"/>
          <rect x="8" y="8" width="2" height="2" fill="white"/>
          <rect x="10" y="8" width="2" height="2" fill="white"/>
          <rect x="12" y="8" width="2" height="2" fill="white"/>
          
          {/* L-shaped element */}
          <path d="M16 10h2v2h-2v2h-2v-4h2z" fill="#94a3b8"/>
          
          {/* Main door */}
          <rect x="10" y="14" width="4" height="6" fill="white"/>
        </svg>
      </div>

      {/* Logo Text */}
      {showText && (
        <div className="flex flex-col">
          <span className={`${textSizeClasses[size]} font-bold text-white tracking-tight font-serif`}>
            PROPELLO
          </span>
          <span className="text-xs text-gray-300 font-medium tracking-wider uppercase">
            AI Realtor
          </span>
        </div>
      )}
    </div>
  )
}

export default Logo
