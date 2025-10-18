/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Propello Brand Colors
        'propello-blue': '#2563eb',
        'propello-blue-50': '#eff6ff',
        'propello-blue-100': '#dbeafe',
        'propello-blue-500': '#3b82f6',
        'propello-blue-600': '#2563eb',
        'propello-blue-700': '#1d4ed8',
        'propello-blue-900': '#1e3a8a',
        
        // Lead Quality Colors
        'propello-hot': '#ef4444',
        'propello-hot-50': '#fef2f2',
        'propello-hot-100': '#fee2e2',
        'propello-hot-500': '#ef4444',
        'propello-hot-600': '#dc2626',
        'propello-hot-700': '#b91c1c',
        
        'propello-warm': '#f97316',
        'propello-warm-50': '#fff7ed',
        'propello-warm-100': '#ffedd5',
        'propello-warm-500': '#f97316',
        'propello-warm-600': '#ea580c',
        'propello-warm-700': '#c2410c',
        
        'propello-cold': '#3b82f6',
        'propello-cold-50': '#eff6ff',
        'propello-cold-100': '#dbeafe',
        'propello-cold-500': '#3b82f6',
        'propello-cold-600': '#2563eb',
        'propello-cold-700': '#1d4ed8',
        
        // Status Colors
        'status-new': '#3b82f6',
        'status-contacted': '#f59e0b',
        'status-qualified': '#10b981',
        'status-closed': '#059669',
        'status-dead': '#6b7280',
      },
      fontFamily: {
        'sans': ['Inter', 'system-ui', 'sans-serif'],
        'mono': ['JetBrains Mono', 'Monaco', 'Consolas', 'monospace'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}

