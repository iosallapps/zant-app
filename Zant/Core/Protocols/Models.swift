import Foundation

// MARK: - Gem

enum GemType: String, Codable, CaseIterable, Sendable, Identifiable {
    var id: String { rawValue }

    case stone
    case quartz
    case amethyst
    case emerald
    case ruby
    case diamond
    case obsidian

    var displayName: String {
        switch self {
        case .stone: "Stone"
        case .quartz: "Quartz"
        case .amethyst: "Amethyst"
        case .emerald: "Emerald"
        case .ruby: "Ruby"
        case .diamond: "Diamond"
        case .obsidian: "Obsidian"
        }
    }

    var rarity: GemRarity {
        switch self {
        case .stone: .common
        case .quartz: .uncommon
        case .amethyst: .rare
        case .emerald, .ruby: .epic
        case .diamond, .obsidian: .legendary
        }
    }

    var isPremium: Bool {
        switch self {
        case .stone, .quartz: false
        default: true
        }
    }

    var requiredSessionMinutes: Int? {
        switch self {
        case .stone: 15
        case .quartz: 30
        case .amethyst: 60
        default: nil
        }
    }
}

enum GemRarity: String, Codable, Sendable, Comparable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    private var sortOrder: Int {
        switch self {
        case .common: 0
        case .uncommon: 1
        case .rare: 2
        case .epic: 3
        case .legendary: 4
        }
    }

    static func < (lhs: GemRarity, rhs: GemRarity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum GemReason: String, Codable, Sendable {
    case sessionComplete = "session_complete"
    case streak = "streak"
    case challenge = "challenge"
    case achievement = "achievement"
    case welcome = "welcome"
}

struct Gem: Codable, Identifiable, Sendable {
    let id: UUID
    let type: GemType
    let earnedAt: Date
    let reason: GemReason

    init(id: UUID = UUID(), type: GemType, earnedAt: Date = .now, reason: GemReason) {
        self.id = id
        self.type = type
        self.earnedAt = earnedAt
        self.reason = reason
    }
}

// MARK: - Migration Mapper: Old Gem → New Crystal
extension GemType {
    var asCrystal: CrystalType {
        switch self {
        case .stone: .clearQuartz        // 1
        case .quartz: .roseQuartz        // 2
        case .amethyst: .amethyst        // 9
        case .emerald: .emerald          // 13
        case .ruby: .ruby                // 15
        case .diamond: .alexandrite      // 19
        case .obsidian: .blackObsidian   // 20
        }
    }
}

// MARK: - Crystal (New System - 20 Levels)

enum CrystalType: Int, Codable, CaseIterable, Sendable, Identifiable {
    // Tier 1 - Common (15-30 min sessions)
    case clearQuartz = 1
    case roseQuartz = 2
    case citrine = 3
    case moonstone = 4

    // Tier 2 - Uncommon (30-45 min sessions)
    case blueLaceAgate = 5
    case greenAventurine = 6
    case carnelian = 7
    case sodalite = 8

    // Tier 3 - Rare (45-60 min sessions)
    case amethyst = 9
    case labradorite = 10
    case tigersEye = 11
    case lapisLazuli = 12

    // Tier 4 - Epic (60-90 min sessions)
    case emerald = 13
    case sapphire = 14
    case ruby = 15
    case aquamarine = 16

    // Tier 5 - Legendary (90+ min sessions)
    case blackTourmaline = 17
    case moldavite = 18
    case alexandrite = 19
    case blackObsidian = 20

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .clearQuartz: "Starter"
        case .roseQuartz: "Bronze"
        case .citrine: "Silver"
        case .moonstone: "Gold"
        case .blueLaceAgate: "Platinum"
        case .greenAventurine: "Emerald"
        case .carnelian: "Sapphire"
        case .sodalite: "Ruby"
        case .amethyst: "Diamond"
        case .labradorite: "Master"
        case .tigersEye: "Elite"
        case .lapisLazuli: "Champion"
        case .emerald: "Legend"
        case .sapphire: "Mythic"
        case .ruby: "Immortal"
        case .aquamarine: "Divine"
        case .blackTourmaline: "Celestial"
        case .moldavite: "Eternal"
        case .alexandrite: "Supreme"
        case .blackObsidian: "Godlike"
        }
    }

    var lore: String {
        switch self {
        case .clearQuartz: "The Clarity Stone"
        case .roseQuartz: "The Heart Stone"
        case .citrine: "The Success Stone"
        case .moonstone: "The Intuition Stone"
        case .blueLaceAgate: "The Calm Stone"
        case .greenAventurine: "The Opportunity Stone"
        case .carnelian: "The Courage Stone"
        case .sodalite: "The Logic Stone"
        case .amethyst: "The Protection Stone"
        case .labradorite: "The Transformation Stone"
        case .tigersEye: "The Confidence Stone"
        case .lapisLazuli: "The Wisdom Stone"
        case .emerald: "The Harmony Stone"
        case .sapphire: "The Truth Stone"
        case .ruby: "The Vitality Stone"
        case .aquamarine: "The Flow Stone"
        case .blackTourmaline: "The Grounding Stone"
        case .moldavite: "The Catalyst Stone"
        case .alexandrite: "The Adaptability Stone"
        case .blackObsidian: "The Ultimate Stone"
        }
    }

    var tier: CrystalTier {
        switch rawValue {
        case 1...4: .common
        case 5...8: .uncommon
        case 9...12: .rare
        case 13...16: .epic
        case 17...20: .legendary
        default: .common
        }
    }

    var requiredSessionMinutes: Int {
        // Progressive: level 1 = 15min, level 2 = 20min, level 3 = 25min, etc.
        15 + (rawValue - 1) * 5
    }

    var assetName: String {
        "Crystal\(String(format: "%02d", rawValue))"
    }

    var isPremium: Bool {
        // Only first 4 crystals are free
        rawValue > 4
    }
}

enum CrystalTier: String, Codable, Sendable, Comparable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    private var sortOrder: Int {
        switch self {
        case .common: 0
        case .uncommon: 1
        case .rare: 2
        case .epic: 3
        case .legendary: 4
        }
    }

    static func < (lhs: CrystalTier, rhs: CrystalTier) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var displayName: String {
        switch self {
        case .common: "Common"
        case .uncommon: "Uncommon"
        case .rare: "Rare"
        case .epic: "Epic"
        case .legendary: "Legendary"
        }
    }
}

enum CrystalReason: String, Codable, Sendable {
    case sessionComplete = "session_complete"
    case streak = "streak"
    case challenge = "challenge"
    case achievement = "achievement"
    case welcome = "welcome"
}

struct Crystal: Codable, Identifiable, Sendable {
    let id: UUID
    let type: CrystalType
    let earnedAt: Date
    let reason: CrystalReason

    init(id: UUID = UUID(), type: CrystalType, earnedAt: Date = .now, reason: CrystalReason) {
        self.id = id
        self.type = type
        self.earnedAt = earnedAt
        self.reason = reason
    }
}

// MARK: - Habit

enum Habit: String, Codable, CaseIterable, Identifiable, Sendable {
    case socialMediaScrolling = "Social Media Scrolling"
    case lateNightPhoneUse = "Late Night Phone Use"
    case checkingPhoneFirstThing = "Checking Phone First Thing"
    case mindlessBrowsing = "Mindless Browsing"
    case notificationAddiction = "Notification Addiction"
    case excessiveGaming = "Excessive Gaming"
    case doomScrollingNews = "Doom Scrolling News"
    case compulsiveAppSwitching = "Compulsive App Switching"
    case phoneDuringMeals = "Phone During Meals"
    case phoneDuringConversations = "Phone During Conversations"
    case other = "Other"

    var id: String { rawValue }

    /// Short label for chip display (fits 2-3 per row)
    var chipLabel: String {
        switch self {
        case .socialMediaScrolling: "Social Media"
        case .lateNightPhoneUse: "Late Night Use"
        case .checkingPhoneFirstThing: "Morning Check"
        case .mindlessBrowsing: "Browsing"
        case .notificationAddiction: "Notifications"
        case .excessiveGaming: "Gaming"
        case .doomScrollingNews: "News Scrolling"
        case .compulsiveAppSwitching: "App Switching"
        case .phoneDuringMeals: "During Meals"
        case .phoneDuringConversations: "During Convos"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .socialMediaScrolling: "arrow.up.arrow.down.circle"
        case .lateNightPhoneUse: "moon.fill"
        case .checkingPhoneFirstThing: "sunrise.fill"
        case .mindlessBrowsing: "globe"
        case .notificationAddiction: "bell.badge.fill"
        case .excessiveGaming: "gamecontroller.fill"
        case .doomScrollingNews: "newspaper.fill"
        case .compulsiveAppSwitching: "square.stack.3d.up"
        case .phoneDuringMeals: "fork.knife"
        case .phoneDuringConversations: "person.2.fill"
        case .other: "ellipsis.circle"
        }
    }

    /// Personalized alternative message for CalculateTimeView
    var timeAlternative: String {
        switch self {
        case .socialMediaScrolling: "Connect with friends in person"
        case .lateNightPhoneUse: "Get more restful sleep every night"
        case .checkingPhoneFirstThing: "Start your mornings with intention"
        case .mindlessBrowsing: "Read books you've been putting off"
        case .notificationAddiction: "Experience deep, uninterrupted focus"
        case .excessiveGaming: "Build real-world skills and hobbies"
        case .doomScrollingNews: "Reduce anxiety and feel calmer"
        case .compulsiveAppSwitching: "Complete tasks faster with deep focus"
        case .phoneDuringMeals: "Enjoy meals and conversations fully"
        case .phoneDuringConversations: "Strengthen your relationships"
        case .other: "Reclaim your time for what matters"
        }
    }
}

// MARK: - Focus Session

enum FocusMode: String, Codable, Sendable, CaseIterable {
    case normal
    case deepFocus = "deep_focus"
    case unbreakable

    var displayName: String {
        switch self {
        case .normal: "Normal"
        case .deepFocus: "Deep Focus"
        case .unbreakable: "Unbreakable"
        }
    }

    var isPremium: Bool {
        switch self {
        case .normal: false
        case .deepFocus, .unbreakable: true
        }
    }

    var icon: String {
        switch self {
        case .normal: "brain.head.profile"
        case .deepFocus: "lock.shield"
        case .unbreakable: "flame.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .normal: "Cancel anytime"
        case .deepFocus: "Apps blocked"
        case .unbreakable: "Can't quit"
        }
    }
}

enum SessionTag: String, Codable, CaseIterable, Sendable {
    case work = "Work"
    case study = "Study"
    case deepWork = "Deep Work"
    case reading = "Reading"
    case exercise = "Exercise"
    case creative = "Creative"
    case focus = "Focus"

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .deepWork: return "brain.head.profile"
        case .reading: return "text.book.closed.fill"
        case .exercise: return "figure.run"
        case .creative: return "paintbrush.fill"
        case .focus: return "target"
        }
    }

    var gradient: [String] {
        switch self {
        case .work: return ["6366F1", "3B82F6"] // Indigo to Blue
        case .study: return ["8B5CF6", "EC4899"] // Purple to Pink
        case .deepWork: return ["0EA5E9", "06B6D4"] // Sky to Cyan
        case .reading: return ["F59E0B", "F97316"] // Amber to Orange
        case .exercise: return ["10B981", "14B8A6"] // Emerald to Teal
        case .creative: return ["EC4899", "F43F5E"] // Pink to Rose
        case .focus: return ["34D399", "22D3EE"] // Mint to Cyan
        }
    }
}

/// Domain model for focus session records (maps to Core Data entity)
struct FocusSessionRecord: Identifiable, Sendable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    let targetDuration: Int // seconds
    var actualDuration: Int // seconds
    let mode: FocusMode
    let tag: SessionTag?
    var wasCompleted: Bool
    var gemEarned: Bool
    var gemType: GemType?
    var crystalEarned: Bool
    var crystalType: CrystalType?

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        endedAt: Date? = nil,
        targetDuration: Int,
        actualDuration: Int = 0,
        mode: FocusMode = .normal,
        tag: SessionTag? = nil,
        wasCompleted: Bool = false,
        gemEarned: Bool = false,
        gemType: GemType? = nil,
        crystalEarned: Bool = false,
        crystalType: CrystalType? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.targetDuration = targetDuration
        self.actualDuration = actualDuration
        self.mode = mode
        self.tag = tag
        self.wasCompleted = wasCompleted
        self.gemEarned = gemEarned
        self.gemType = gemType
        self.crystalEarned = crystalEarned
        self.crystalType = crystalType
    }
}

// MARK: - Daily Stats

struct DailyStatsRecord: Identifiable, Sendable {
    let id: UUID
    let date: Date
    var totalFocusTime: Double    // minutes
    var sessionsCompleted: Int
    var focusScore: Int           // 0-100

    init(
        id: UUID = UUID(),
        date: Date = .now,
        totalFocusTime: Double = 0,
        sessionsCompleted: Int = 0,
        focusScore: Int = 0
    ) {
        self.id = id
        self.date = date
        self.totalFocusTime = totalFocusTime
        self.sessionsCompleted = sessionsCompleted
        self.focusScore = focusScore
    }
}

// MARK: - Blocking Rule

enum BlockingStrictness: String, Codable, Sendable, CaseIterable {
    case normal
    case strict
    case unbreakable

    var displayName: String {
        switch self {
        case .normal: "Normal"
        case .strict: "Strict"
        case .unbreakable: "Unbreakable"
        }
    }
}

struct BlockingRuleRecord: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var isActive: Bool
    var strictness: BlockingStrictness
    var daysOfWeek: Set<Int> // 1=Sunday, 7=Saturday
    var startTime: DateComponents
    var endTime: DateComponents
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        isActive: Bool = true,
        strictness: BlockingStrictness = .normal,
        daysOfWeek: Set<Int> = Set(1...7),
        startTime: DateComponents = DateComponents(hour: 9, minute: 0),
        endTime: DateComponents = DateComponents(hour: 17, minute: 0),
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.strictness = strictness
        self.daysOfWeek = daysOfWeek
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
    }
}

// MARK: - Challenge

enum ChallengeIdentifier: String, Codable, Sendable {
    case focusStarter
    case deepWorker
    case screenLimit
}

struct Challenge: Identifiable, Codable, Sendable {
    let id: UUID
    let identifier: ChallengeIdentifier
    let type: ChallengeType
    let title: String
    let description: String
    var targetValue: Double
    var currentValue: Double
    var isCompleted: Bool
    let startDate: Date
    let endDate: Date
    let xpReward: Int
    let gemReward: GemType?

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    init(
        id: UUID = UUID(),
        identifier: ChallengeIdentifier,
        type: ChallengeType,
        title: String,
        description: String,
        targetValue: Double,
        currentValue: Double = 0,
        isCompleted: Bool = false,
        startDate: Date = .now,
        endDate: Date,
        xpReward: Int = AppConstants.xpPerChallenge,
        gemReward: GemType? = nil
    ) {
        self.id = id
        self.identifier = identifier
        self.type = type
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
        self.xpReward = xpReward
        self.gemReward = gemReward
    }
}

enum ChallengeType: String, Codable, Sendable {
    case daily
    case weekly
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable, Sendable {
    let id: UUID
    let type: String
    let title: String
    let description: String
    var unlockedAt: Date?
    var isUnlocked: Bool

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        description: String,
        unlockedAt: Date? = nil,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.unlockedAt = unlockedAt
        self.isUnlocked = isUnlocked
    }
}

// MARK: - Level

enum Level {
    static func title(for level: Int) -> String {
        switch level {
        case 1...5: "Novice"
        case 6...10: "Apprentice"
        case 11...15: "Focused"
        case 16...20: "Disciplined"
        case 21...25: "Master"
        case 26...30: "Sage"
        case 31...40: "Zenith"
        case 41...50: "Transcendent"
        default: "Novice"
        }
    }

    static func xpRequired(for level: Int) -> Int {
        level * level * 100
    }
}

// MARK: - Insight Card

import SwiftUI

struct InsightCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let metric: String
}
