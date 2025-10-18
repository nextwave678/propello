import React from 'react'

interface LoadingAnimationProps {
  onComplete?: () => void
}

const LoadingAnimation: React.FC<LoadingAnimationProps> = ({ onComplete }) => {
  React.useEffect(() => {
    const timer = setTimeout(() => {
      onComplete?.()
    }, 3000) // Show animation for 3 seconds

    return () => clearTimeout(timer)
  }, [onComplete])

  return (
    <div className="fixed inset-0 bg-gradient-to-br from-blue-900 via-purple-900 to-indigo-900 flex items-center justify-center z-50">
      <div className="text-center">
        {/* Animated Logo */}
        <div className="relative mb-8">
          <div className="w-24 h-24 mx-auto relative propello-loading-logo">
            {/* House Icon */}
            <div className="absolute inset-0 flex items-center justify-center">
              <svg 
                viewBox="0 0 24 24" 
                className="w-16 h-16 text-white animate-pulse"
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
            
            {/* Rotating ring around house */}
            <div className="absolute inset-0 rounded-full border-2 border-transparent bg-gradient-to-r from-blue-400 to-purple-400 animate-spin opacity-30">
              <div className="absolute inset-1 rounded-full border-2 border-transparent bg-gradient-to-r from-purple-400 to-pink-400 animate-spin opacity-50" style={{ animationDirection: 'reverse', animationDuration: '2s' }}></div>
            </div>
          </div>
        </div>

        {/* Propello Text */}
        <div className="space-y-4">
          <h1 className="text-4xl font-bold text-white mb-2 font-serif">
            <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              PROPELLO
            </span>
          </h1>
          
          <div className="text-lg text-gray-300 font-medium">
            AI Realtor Lead Management
          </div>
          
          {/* Loading dots */}
          <div className="flex justify-center space-x-1 mt-6">
            <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce"></div>
            <div className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
            <div className="w-2 h-2 bg-pink-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
          </div>
        </div>

        {/* Floating particles */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          {[...Array(20)].map((_, i) => (
            <div
              key={i}
              className="absolute w-1 h-1 bg-white rounded-full opacity-30 propello-floating-particle"
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
                animationDelay: `${Math.random() * 3}s`,
                animationDuration: `${2 + Math.random() * 2}s`
              }}
            />
          ))}
        </div>
      </div>
    </div>
  )
}

export default LoadingAnimation
