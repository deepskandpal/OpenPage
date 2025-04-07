import SwiftUI

/// Extension to provide theme colors for the application that adapt to light and dark mode
extension Color {
    /// Background color for the main areas of the app
    static var adaptiveBackground: Color {
        Color.primary.opacity(0.05)
    }
    
    /// Background color for secondary containers
    static var adaptiveSecondaryBackground: Color {
        Color.primary.opacity(0.1)
    }
    
    /// Background color for tertiary elements
    static var adaptiveTertiaryBackground: Color {
        Color.primary.opacity(0.15)
    }
    
    /// Background color for grouped content
    static var adaptiveGroupedBackground: Color {
        Color.primary.opacity(0.08)
    }
    
    /// Background color for cards
    static var adaptiveCardBackground: Color {
        Color.primary.opacity(0.07)
    }
    
    /// Color for borders and separators
    static var adaptiveBorder: Color {
        Color.primary.opacity(0.2)
    }
    
    /// Color for faint overlays
    static var adaptiveOverlay: Color {
        Color.primary.opacity(0.1)
    }
    
    /// Color for button backgrounds
    static var adaptiveButtonBackground: Color {
        Color.accentColor.opacity(0.2)
    }
    
    /// Chat message bubble colors
    enum ChatBubble {
        /// User message bubble background
        static let user = Color.blue
        
        /// AI assistant message bubble background (adapts to color scheme)
        static func assistant(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2)
        }
        
        /// System message bubble background (adapts to color scheme)
        static func system(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
        }
    }
} 