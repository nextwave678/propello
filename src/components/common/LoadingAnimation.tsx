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
            {/* Outer rotating ring */}
            <div className="absolute inset-0 rounded-full border-4 border-transparent bg-gradient-to-r from-blue-400 to-purple-400 animate-spin">
              <div className="absolute inset-1 rounded-full border-4 border-transparent bg-gradient-to-r from-purple-400 to-pink-400 animate-spin" style={{ animationDirection: 'reverse', animationDuration: '2s' }}></div>
            </div>
            
            {/* Inner pulsing circle */}
            <div className="absolute inset-4 rounded-full bg-gradient-to-r from-blue-500 to-purple-500 animate-pulse flex items-center justify-center">
              <div className="w-8 h-8 bg-white rounded-full flex items-center justify-center">
                <div className="w-4 h-4 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full animate-ping"></div>
              </div>
            </div>
          </div>
        </div>

        {/* Propello Text */}
        <div className="space-y-4">
          <h1 className="text-4xl font-bold text-white mb-2">
            <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              Propello
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
