Flutter Development with Duolingo Design System
Context
Building Flutter app with Duolingo-inspired design. Strictly follow the attached /mobile/styles.json for all styling decisions.
Key Requirements
Colors & Typography

Use exact hex values from colorPalette section
Primary: duoGreen (#58CC02), Secondary: duoBlue (#1CB0F6)
Nunito font family with specified sizes/weights from JSON
Create Flutter Color/TextStyle constants for all values

Components

Follow exact specs from components section
Create reusable widgets: DuoButton, DuoCard, DuoProgressBar
Implement gamification elements: StreakCounter, XPBadge, HeartCounter, GemCounter
Use spacing values: xs(4px), sm(8px), md(16px), lg(24px), xl(32px)
Apply border radius: small(8px), medium(12px), large(16px)

Design Principles

Rounded corners everywhere (min 8px)
Vibrant colors for positive impact
Bold typography and generous white space
Micro-interactions and animations
Button press scale: 0.95, duration: 100ms

Code Structure
dartclass DuolingoTheme {
  // All colors, text styles, button themes from JSON (/mobile/styles.json )
}
Output Standards

Reference specific JSON sections in comments
No hardcoded values - everything from theme
Reusable, well-documented components
Ensure accessibility (min 44px touch targets)
Final result should feel playful and gamified like Duolingo