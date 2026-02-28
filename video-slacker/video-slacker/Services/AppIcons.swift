// AppIcons.swift
// Centralized SF Symbol name constants for video-slacker-ios.
// Keep in sync with ICON_MAP.md in messaging-app/design-tokens/.
// NEVER hardcode SF Symbol strings elsewhere — always use these constants.

enum AppIcons {

    // MARK: - Navigation
    static let back            = "chevron.left"
    static let close           = "xmark"
    static let menu            = "line.3.horizontal"
    static let settings        = "gear"
    static let search          = "magnifyingglass"
    static let filter          = "slider.horizontal.3"
    static let sort            = "arrow.up.arrow.down"
    static let moreVertical    = "ellipsis"
    static let externalLink    = "arrow.up.right.square"
    static let sidebarOpen     = "sidebar.left"
    static let expand          = "arrow.up.left.and.arrow.down.right"
    static let collapse        = "arrow.down.right.and.arrow.up.left"

    // MARK: - Channels & Workspaces
    static let channelPublic   = "number"
    static let channelPrivate  = "lock.fill"
    static let addChannel      = "plus"
    static let browseChannels  = "square.grid.2x2"
    static let channelSettings = "gearshape"
    static let leaveChannel    = "arrow.right.square"
    static let archive         = "archivebox"
    static let pin             = "pin.fill"
    static let workspace       = "square.on.square"
    static let inviteMember    = "person.badge.plus"
    static let removeMember    = "person.badge.minus"
    static let members         = "person.2.fill"
    static let presenceDot     = "circle.fill"   // tint green/amber/slate per status

    // MARK: - Messaging
    static let send            = "paperplane.fill"
    static let message         = "message"
    static let directMessage   = "bubble.left.and.bubble.right"
    static let reply           = "arrowshape.turn.up.right"
    static let thread          = "bubble.left.and.bubble.right.fill"
    static let editMessage     = "pencil"
    static let deleteMessage   = "trash"
    static let copyText        = "doc.on.doc"
    static let markUnread      = "envelope.badge"
    static let bookmark        = "bookmark"
    static let bookmarkFilled  = "bookmark.fill"
    static let reaction        = "face.smiling"
    static let addReaction     = "face.smiling.inverse"
    static let mention         = "at"

    // MARK: - Files & Attachments
    static let attach          = "paperclip"
    static let upload          = "arrow.up.to.line"
    static let download        = "arrow.down.to.line"
    static let image           = "photo"
    static let video           = "video"
    static let document        = "doc.text"
    static let folder          = "folder"
    static let link            = "link"
    static let copyLink        = "link.badge.plus"
    static let qrCode          = "qrcode"

    // MARK: - User & Profile
    static let person          = "person"
    static let personCircle    = "person.circle.fill"
    static let editProfile     = "person.crop.circle.badge.pencil"
    static let visibility      = "eye"
    static let visibilityOff   = "eye.slash"
    static let blockUser       = "person.fill.xmark"

    // MARK: - Auth & Security
    static let login           = "arrow.right.square"
    static let logout          = "rectangle.portrait.and.arrow.forward"
    static let lock            = "lock"
    static let lockOpen        = "lock.open"
    static let key             = "key"
    static let shield          = "shield"
    static let verified        = "checkmark.shield"
    static let device          = "desktopcomputer"
    static let mobileDevice    = "iphone"

    // MARK: - Status & Feedback
    static let success         = "checkmark.circle.fill"
    static let warning         = "exclamationmark.triangle.fill"
    static let error           = "xmark.circle.fill"
    static let info            = "info.circle"
    static let emptyTray       = "tray"
    static let notification    = "bell"
    static let notificationOff = "bell.slash"
    static let notificationBadge = "bell.badge"

    // MARK: - Actions
    static let add             = "plus"
    static let addCircle       = "plus.circle"
    static let minus           = "minus"
    static let check           = "checkmark"
    static let star            = "star"
    static let starFilled      = "star.fill"
    static let refresh         = "arrow.clockwise"
    static let share           = "square.and.arrow.up"
    static let copy            = "doc.on.doc"
    static let tag             = "tag"
    static let clock           = "clock"
    static let calendar        = "calendar"
    static let scheduled       = "calendar.badge.clock"

    // MARK: - Theme
    static let lightMode       = "sun.max"
    static let darkMode        = "moon"
    static let systemTheme     = "circle.lefthalf.filled"
}
