const defaultTheme = require('tailwindcss/defaultTheme')

// Design tokens live in app/assets/stylesheets/application.css as CSS custom
// properties. This file only *maps* them to Tailwind utilities, so there are
// no raw colour/size values here — that file is the single source of truth.

// Colours are stored as "R G B" channels so opacity modifiers work.
const rgb = (token) => `rgb(var(${token}) / <alpha-value>)`
const token = (name) => `var(${name})`

const color = (name) => ({
  DEFAULT: rgb(`--color-${name}`),
  hover: rgb(`--color-${name}-hover`),
  strong: rgb(`--color-${name}-strong`),
})

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: rgb('--color-primary'),
          hover: rgb('--color-primary-hover'),
          active: rgb('--color-primary-active'),
        },
        secondary: color('secondary'),
        accent: color('accent'),
        success: color('success'),
        warning: color('warning'),
        danger: color('danger'),
        info: color('info'),
        surface: {
          DEFAULT: rgb('--color-surface'),
          muted: rgb('--color-surface-muted'),
        },
        background: rgb('--color-background'),
        border: {
          DEFAULT: rgb('--color-border'),
          focus: rgb('--color-border-focus'),
        },
        text: {
          DEFAULT: rgb('--color-text'),
          muted: rgb('--color-text-muted'),
        },
        'on-primary': rgb('--color-on-primary'),
        'on-dark': rgb('--color-on-dark'),
      },
      fontFamily: {
        sans: [token('--font-family-sans'), ...defaultTheme.fontFamily.sans],
      },
      fontSize: {
        xs: token('--text-xs'),
        sm: token('--text-sm'),
        base: token('--text-base'),
        lg: token('--text-lg'),
        xl: token('--text-xl'),
        '2xl': token('--text-2xl'),
        '3xl': token('--text-3xl'),
      },
      spacing: {
        1: token('--space-1'),
        2: token('--space-2'),
        3: token('--space-3'),
        4: token('--space-4'),
        5: token('--space-5'),
        6: token('--space-6'),
        8: token('--space-8'),
        10: token('--space-10'),
        12: token('--space-12'),
        16: token('--space-16'),
        20: token('--space-20'),
        24: token('--space-24'),
        sidebar: token('--space-sidebar'),
        'sidebar-collapsed': token('--space-sidebar-collapsed'),
        'sidebar-mobile': token('--space-sidebar-mobile'),
      },
      borderRadius: {
        sm: token('--radius-sm'),
        DEFAULT: token('--radius'),
        md: token('--radius-md'),
        lg: token('--radius-lg'),
        full: token('--radius-full'),
      },
      boxShadow: {
        sm: token('--shadow-sm'),
        DEFAULT: token('--shadow'),
        md: token('--shadow-md'),
        lg: token('--shadow-lg'),
      },
      screens: {
        sm: token('--breakpoint-sm'),
        md: token('--breakpoint-md'),
        lg: token('--breakpoint-lg'),
        xl: token('--breakpoint-xl'),
      },
      zIndex: {
        backdrop: token('--z-backdrop'),
        sidebar: token('--z-sidebar'),
        overlay: token('--z-overlay'),
      },
      transitionDuration: {
        fast: token('--transition-fast'),
        DEFAULT: token('--transition'),
        slow: token('--transition-slow'),
      },
      transitionTimingFunction: {
        DEFAULT: token('--easing-default'),
      },
    },
    container: {
      center: true,
      padding: '1rem',
      screens: {
        sm: token('--breakpoint-sm'),
        md: token('--breakpoint-md'),
        lg: token('--breakpoint-lg'),
        xl: token('--breakpoint-xl'),
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ],
}
