// DesignTokens.swift
// Auto-generated from tokens.json — DO NOT EDIT by hand.
// Run: npm run tokens:build in messaging-app/design-tokens/
// Generated: 2026-02-28

import SwiftUI

enum DesignTokens {
  enum Color {
    /// indigo-500 — main CTA, active states, links
    static let brandPrimary = SwiftUI.Color(hex: "6366f1")
    /// indigo-600 — hover state for primary
    static let brandPrimaryHover = SwiftUI.Color(hex: "4f46e5")
    /// indigo-50 — tinted backgrounds, selected rows (light)
    static let brandPrimarySubtle = SwiftUI.Color(hex: "eef2ff")
    /// indigo-950 — tinted backgrounds (dark)
    static let brandPrimarySubtleDark = SwiftUI.Color(hex: "1e1b4b")
    /// violet-500 — decorative, illustrations, empty states
    static let brandAccent = SwiftUI.Color(hex: "8b5cf6")
    /// violet-50 — accent tint bg (light)
    static let brandAccentSubtle = SwiftUI.Color(hex: "f5f3ff")
    /// indigo-950 — sidebar background (both modes)
    static let sidebarBg = SwiftUI.Color(hex: "1e1b4b")
    /// indigo-900 — hovered channel/item in sidebar
    static let sidebarHover = SwiftUI.Color(hex: "312e81")
    /// indigo-700 — active/selected channel in sidebar
    static let sidebarActive = SwiftUI.Color(hex: "4338ca")
    /// indigo-100 — primary text on sidebar
    static let sidebarTextPrimary = SwiftUI.Color(hex: "e0e7ff")
    /// indigo-400 — muted / section headers on sidebar
    static let sidebarTextMuted = SwiftUI.Color(hex: "818cf8")
    /// white — text when channel is active
    static let sidebarTextOnActive = SwiftUI.Color(hex: "ffffff")
    /// red-500 — unread count badge
    static let sidebarBadge = SwiftUI.Color(hex: "ef4444")
    /// Main content background (light)
    static let surfaceBase = SwiftUI.Color(hex: "ffffff")
    /// slate-50 — subtle bg for alternating rows, panels
    static let surfaceSubtle = SwiftUI.Color(hex: "f8fafc")
    /// Modals, dropdowns, tooltips (light)
    static let surfaceOverlay = SwiftUI.Color(hex: "ffffff")
    /// Channel header / top nav bg (light)
    static let surfaceHeader = SwiftUI.Color(hex: "ffffff")
    /// slate-900 — Main content background (dark)
    static let surfaceDarkBase = SwiftUI.Color(hex: "0f172a")
    /// slate-800 — subtle bg (dark)
    static let surfaceDarkSubtle = SwiftUI.Color(hex: "1e293b")
    /// slate-800 — Modals, dropdowns (dark)
    static let surfaceDarkOverlay = SwiftUI.Color(hex: "1e293b")
    /// slate-900 — Channel header bg (dark)
    static let surfaceDarkHeader = SwiftUI.Color(hex: "0f172a")
    /// slate-900 — body text (light)
    static let textPrimary = SwiftUI.Color(hex: "0f172a")
    /// slate-700 — secondary text (light)
    static let textSecondary = SwiftUI.Color(hex: "334155")
    /// slate-400 — timestamps, metadata (light)
    static let textMuted = SwiftUI.Color(hex: "94a3b8")
    /// white — text on brand-primary bg
    static let textOnBrand = SwiftUI.Color(hex: "ffffff")
    /// indigo-500 — inline links (light)
    static let textLink = SwiftUI.Color(hex: "6366f1")
    /// blue-700 — inline code text (light)
    static let textCode = SwiftUI.Color(hex: "1d4ed8")
    /// slate-100 — body text (dark)
    static let textDarkPrimary = SwiftUI.Color(hex: "f1f5f9")
    /// slate-300 — secondary text (dark)
    static let textDarkSecondary = SwiftUI.Color(hex: "cbd5e1")
    /// slate-500 — timestamps (dark)
    static let textDarkMuted = SwiftUI.Color(hex: "64748b")
    /// indigo-400 — inline links (dark)
    static let textDarkLink = SwiftUI.Color(hex: "818cf8")
    /// blue-300 — inline code text (dark)
    static let textDarkCode = SwiftUI.Color(hex: "93c5fd")
    /// slate-200 — default dividers (light)
    static let borderDefault = SwiftUI.Color(hex: "e2e8f0")
    /// slate-300 — stronger borders (light)
    static let borderStrong = SwiftUI.Color(hex: "cbd5e1")
    /// indigo-500 — focus rings on inputs
    static let borderFocus = SwiftUI.Color(hex: "6366f1")
    /// slate-700 — default dividers (dark)
    static let borderDarkDefault = SwiftUI.Color(hex: "334155")
    /// slate-600 — stronger borders (dark)
    static let borderDarkStrong = SwiftUI.Color(hex: "475569")
    /// green-500
    static let semanticSuccess = SwiftUI.Color(hex: "22c55e")
    /// green-50
    static let semanticSuccessSubtle = SwiftUI.Color(hex: "f0fdf4")
    /// amber-400
    static let semanticWarning = SwiftUI.Color(hex: "f59e0b")
    /// amber-50
    static let semanticWarningSubtle = SwiftUI.Color(hex: "fffbeb")
    /// red-500
    static let semanticError = SwiftUI.Color(hex: "ef4444")
    /// red-50
    static let semanticErrorSubtle = SwiftUI.Color(hex: "fef2f2")
    /// blue-500
    static let semanticInfo = SwiftUI.Color(hex: "3b82f6")
    /// blue-50
    static let semanticInfoSubtle = SwiftUI.Color(hex: "eff6ff")
    /// green-500 — user online
    static let presenceOnline = SwiftUI.Color(hex: "22c55e")
    /// amber-400 — user away/idle
    static let presenceAway = SwiftUI.Color(hex: "f59e0b")
    /// red-500 — do not disturb
    static let presenceDnd = SwiftUI.Color(hex: "ef4444")
    /// slate-400 — user offline
    static let presenceOffline = SwiftUI.Color(hex: "94a3b8")
    /// slate-100 — code block background (light)
    static let codeBlockBg = SwiftUI.Color(hex: "f1f5f9")
    /// slate-800 — code block background (dark)
    static let codeBlockBgDark = SwiftUI.Color(hex: "1e293b")
    /// slate-200 — code block border (light)
    static let codeBlockBorder = SwiftUI.Color(hex: "e2e8f0")
    /// slate-700 — code block border (dark)
    static let codeBlockBorderDark = SwiftUI.Color(hex: "334155")
  }

  enum Typography {
    static let fontSizeXs: CGFloat = 11
    static let fontSizeSm: CGFloat = 13
    static let fontSizeBase: CGFloat = 15
    static let fontSizeLg: CGFloat = 17
    static let fontSizeXl: CGFloat = 20
    static let fontSize2xl: CGFloat = 24
    static let fontSize3xl: CGFloat = 30
    static let fontWeightNormal: CGFloat = 400
    static let fontWeightMedium: CGFloat = 500
    static let fontWeightSemibold: CGFloat = 600
    static let fontWeightBold: CGFloat = 700
  }

  enum Spacing {
    static let sp0: CGFloat = 0
    static let sp1: CGFloat = 4
    static let sp2: CGFloat = 8
    static let sp3: CGFloat = 12
    static let sp4: CGFloat = 16
    static let sp5: CGFloat = 20
    static let sp6: CGFloat = 24
    static let sp8: CGFloat = 32
    static let sp10: CGFloat = 40
    static let sp12: CGFloat = 48
    static let sp16: CGFloat = 64
    static let sp20: CGFloat = 80
    static let sp24: CGFloat = 96
  }

  enum Size {
    static let sidebarWidth: CGFloat = 240
    static let sidebarWidthCollapsed: CGFloat = 64
    static let threadPanelWidth: CGFloat = 360
    static let avatarXs: CGFloat = 20
    static let avatarSm: CGFloat = 28
    static let avatarMd: CGFloat = 36
    static let avatarLg: CGFloat = 48
    static let avatarXl: CGFloat = 72
    static let iconSm: CGFloat = 14
    static let iconMd: CGFloat = 16
    static let iconLg: CGFloat = 20
  }

  enum BorderRadius {
    static let none: CGFloat = 0
    static let sm: CGFloat = 4
    static let md: CGFloat = 6
    static let lg: CGFloat = 8
    static let xl: CGFloat = 12
    static let xxl: CGFloat = 16
    static let full: CGFloat = 9999
  }

  enum Shadow {
  }

  enum ZIndex {
  }

  enum Transition {
  }

}

// MARK: - Color(hex:) extension
// Add this once to your project (e.g., Extensions/Color+Hex.swift):
// extension Color {
//   init(hex: String) {
//     let scanner = Scanner(string: hex)
//     var rgb: UInt64 = 0
//     scanner.scanHexInt64(&rgb)
//     let r = Double((rgb >> 16) & 0xFF) / 255
//     let g = Double((rgb >> 8) & 0xFF) / 255
//     let b = Double(rgb & 0xFF) / 255
//     self.init(red: r, green: g, blue: b)
//   }
// }