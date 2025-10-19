# Propello Design System

## Brand Identity

### App Name
**Propello** - Derived from "Propelling" real estate professionals to success

### Brand Values
- **Professional**: Clean, trustworthy, business-focused
- **Efficient**: Fast, intuitive, productivity-focused
- **Intelligent**: Smart filtering, data-driven insights
- **Reliable**: Consistent, dependable, always available

## Color Palette

### Primary Colors

```css
/* Primary Blue - Professional, trustworthy */
--propello-blue: #2563eb;
--propello-blue-50: #eff6ff;
--propello-blue-100: #dbeafe;
--propello-blue-500: #3b82f6;
--propello-blue-600: #2563eb;
--propello-blue-700: #1d4ed8;
--propello-blue-900: #1e3a8a;

/* Secondary Gray - Neutral, clean */
--propello-gray-50: #f9fafb;
--propello-gray-100: #f3f4f6;
--propello-gray-200: #e5e7eb;
--propello-gray-300: #d1d5db;
--propello-gray-400: #9ca3af;
--propello-gray-500: #6b7280;
--propello-gray-600: #4b5563;
--propello-gray-700: #374151;
--propello-gray-800: #1f2937;
--propello-gray-900: #111827;
```

### Lead Quality Colors

```css
/* Hot Lead - Urgent, high priority */
--propello-hot: #ef4444;
--propello-hot-50: #fef2f2;
--propello-hot-100: #fee2e2;
--propello-hot-500: #ef4444;
--propello-hot-600: #dc2626;
--propello-hot-700: #b91c1c;

/* Warm Lead - Moderate priority */
--propello-warm: #f97316;
--propello-warm-50: #fff7ed;
--propello-warm-100: #ffedd5;
--propello-warm-500: #f97316;
--propello-warm-600: #ea580c;
--propello-warm-700: #c2410c;

/* Cold Lead - Low priority, nurture */
--propello-cold: #3b82f6;
--propello-cold-50: #eff6ff;
--propello-cold-100: #dbeafe;
--propello-cold-500: #3b82f6;
--propello-cold-600: #2563eb;
--propello-cold-700: #1d4ed8;
```

### Status Colors

```css
/* Status Indicators */
--status-new: #3b82f6;      /* Blue - New leads */
--status-contacted: #f59e0b; /* Amber - In progress */
--status-qualified: #10b981; /* Green - Qualified */
--status-closed: #059669;    /* Green - Success */
--status-dead: #6b7280;      /* Gray - Inactive */
```

## Typography

### Font Stack

```css
/* Primary Font - Inter (Google Fonts) */
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

/* Monospace Font - For data/code */
font-family: 'JetBrains Mono', 'Fira Code', 'Monaco', 'Consolas', monospace;
```

### Type Scale

```css
/* Headings */
--text-4xl: 2.25rem;    /* 36px - Page titles */
--text-3xl: 1.875rem;   /* 30px - Section headers */
--text-2xl: 1.5rem;     /* 24px - Card titles */
--text-xl: 1.25rem;     /* 20px - Subsection headers */
--text-lg: 1.125rem;    /* 18px - Large body text */

/* Body Text */
--text-base: 1rem;      /* 16px - Default body text */
--text-sm: 0.875rem;    /* 14px - Small text, captions */
--text-xs: 0.75rem;     /* 12px - Micro text, labels */

/* Line Heights */
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.625;
```

### Font Weights

```css
--font-light: 300;
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
--font-extrabold: 800;
```

## Spacing System

### Base Unit: 4px

```css
/* Spacing Scale */
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-5: 1.25rem;   /* 20px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-10: 2.5rem;   /* 40px */
--space-12: 3rem;     /* 48px */
--space-16: 4rem;     /* 64px */
--space-20: 5rem;     /* 80px */
--space-24: 6rem;     /* 96px */
```

### Component Spacing

```css
/* Card Padding */
--card-padding: var(--space-6);        /* 24px */
--card-padding-sm: var(--space-4);     /* 16px */

/* Section Spacing */
--section-gap: var(--space-8);         /* 32px */
--section-gap-lg: var(--space-12);     /* 48px */

/* Grid Gaps */
--grid-gap: var(--space-6);            /* 24px */
--grid-gap-sm: var(--space-4);         /* 16px */
```

## Component Patterns

### Cards

```css
/* Base Card */
.propello-card {
  background: white;
  border-radius: 0.75rem;        /* 12px */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  border: 1px solid var(--propello-gray-200);
  padding: var(--card-padding);
  transition: all 0.2s ease;
}

.propello-card:hover {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

/* Lead Card Specific */
.lead-card {
  min-height: 200px;
  position: relative;
}

.lead-card.hot {
  border-left: 4px solid var(--propello-hot);
}

.lead-card.warm {
  border-left: 4px solid var(--propello-warm);
}

.lead-card.cold {
  border-left: 4px solid var(--propello-cold);
}
```

### Buttons

```css
/* Primary Button */
.btn-primary {
  background: var(--propello-blue);
  color: white;
  border: none;
  border-radius: 0.5rem;         /* 8px */
  padding: 0.75rem 1.5rem;        /* 12px 24px */
  font-weight: 500;
  font-size: 0.875rem;           /* 14px */
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: var(--propello-blue-700);
  transform: translateY(-1px);
}

/* Secondary Button */
.btn-secondary {
  background: white;
  color: var(--propello-gray-700);
  border: 1px solid var(--propello-gray-300);
  border-radius: 0.5rem;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: var(--propello-gray-50);
  border-color: var(--propello-gray-400);
}
```

### Badges

```css
/* Quality Badges */
.badge-hot {
  background: var(--propello-hot-100);
  color: var(--propello-hot-700);
  border: 1px solid var(--propello-hot-200);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge-warm {
  background: var(--propello-warm-100);
  color: var(--propello-warm-700);
  border: 1px solid var(--propello-warm-200);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge-cold {
  background: var(--propello-cold-100);
  color: var(--propello-cold-700);
  border: 1px solid var(--propello-cold-200);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

### Form Elements

```css
/* Input Fields */
.propello-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid var(--propello-gray-300);
  border-radius: 0.5rem;
  font-size: 0.875rem;
  transition: all 0.2s ease;
  background: white;
}

.propello-input:focus {
  outline: none;
  border-color: var(--propello-blue);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.propello-input::placeholder {
  color: var(--propello-gray-400);
}

/* Select Dropdown */
.propello-select {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid var(--propello-gray-300);
  border-radius: 0.5rem;
  font-size: 0.875rem;
  background: white;
  cursor: pointer;
}
```

## Layout System

### Grid System

```css
/* Container */
.propello-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 var(--space-6);
}

/* Grid Layouts */
.grid-1 { display: grid; grid-template-columns: 1fr; gap: var(--grid-gap); }
.grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: var(--grid-gap); }
.grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--grid-gap); }
.grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--grid-gap); }

/* Responsive Grid */
@media (max-width: 768px) {
  .grid-2, .grid-3, .grid-4 {
    grid-template-columns: 1fr;
  }
}

@media (min-width: 769px) and (max-width: 1024px) {
  .grid-3, .grid-4 {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

### Flexbox Utilities

```css
.flex { display: flex; }
.flex-col { flex-direction: column; }
.flex-row { flex-direction: row; }
.items-center { align-items: center; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }
.gap-2 { gap: var(--space-2); }
.gap-4 { gap: var(--space-4); }
.gap-6 { gap: var(--space-6); }
```

## Responsive Breakpoints

```css
/* Mobile First Approach */
/* Base styles for mobile (320px+) */

/* Small tablets (640px+) */
@media (min-width: 640px) {
  .sm\:grid-2 { grid-template-columns: repeat(2, 1fr); }
  .sm\:text-lg { font-size: 1.125rem; }
}

/* Tablets (768px+) */
@media (min-width: 768px) {
  .md\:grid-3 { grid-template-columns: repeat(3, 1fr); }
  .md\:text-xl { font-size: 1.25rem; }
}

/* Desktop (1024px+) */
@media (min-width: 1024px) {
  .lg\:grid-4 { grid-template-columns: repeat(4, 1fr); }
  .lg\:text-2xl { font-size: 1.5rem; }
}

/* Large Desktop (1280px+) */
@media (min-width: 1280px) {
  .xl\:text-3xl { font-size: 1.875rem; }
}
```

## Animation & Transitions

### Standard Transitions

```css
/* Base Transition */
.transition {
  transition: all 0.2s ease;
}

/* Hover Effects */
.hover-lift:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.hover-scale:hover {
  transform: scale(1.02);
}

/* Focus States */
.focus-ring:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}
```

### Loading States

```css
/* Spinner */
.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--propello-gray-200);
  border-top: 2px solid var(--propello-blue);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Skeleton Loading */
.skeleton {
  background: linear-gradient(90deg, var(--propello-gray-200) 25%, var(--propello-gray-100) 50%, var(--propello-gray-200) 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

## Accessibility Standards

### Color Contrast

- **Normal Text**: Minimum 4.5:1 contrast ratio
- **Large Text**: Minimum 3:1 contrast ratio
- **Interactive Elements**: Minimum 3:1 contrast ratio

### Focus Management

```css
/* Focus Indicators */
.focus-visible:focus {
  outline: 2px solid var(--propello-blue);
  outline-offset: 2px;
}

/* Skip Links */
.skip-link {
  position: absolute;
  top: -40px;
  left: 6px;
  background: var(--propello-blue);
  color: white;
  padding: 8px;
  text-decoration: none;
  border-radius: 4px;
}

.skip-link:focus {
  top: 6px;
}
```

### Screen Reader Support

```css
/* Screen Reader Only */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

## Icon System

### Icon Library: Lucide React

```typescript
// Common Icons Used
import {
  Phone, Mail, MapPin, Calendar, Clock,
  Filter, Search, Plus, Edit, Trash2,
  Eye, EyeOff, ChevronDown, ChevronUp,
  Check, X, AlertCircle, Info, Star
} from 'lucide-react';
```

### Icon Sizes

```css
.icon-xs { width: 12px; height: 12px; }
.icon-sm { width: 16px; height: 16px; }
.icon-md { width: 20px; height: 20px; }
.icon-lg { width: 24px; height: 24px; }
.icon-xl { width: 32px; height: 32px; }
```

---

*This design system ensures consistency, accessibility, and professional appearance across all Propello components.*


