import Foundation
import SwiftUI

// MARK: - Block Template Model

/// A pre-configured blocking schedule template
/// Templates provide quick-start blocking configurations similar to Opal
struct BlockTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let description: String
    let category: TemplateCategory
    let startTime: DateComponents
    let endTime: DateComponents
    let daysOfWeek: Set<Int> // 1=Sunday, 7=Saturday
    let strictness: BlockingStrictness
    let backgroundImage: String // Asset name
    let accentColor: String // Hex color
    let isPremium: Bool
    let sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        description: String,
        category: TemplateCategory,
        startTime: DateComponents,
        endTime: DateComponents,
        daysOfWeek: Set<Int> = Set(1...7),
        strictness: BlockingStrictness = .strict,
        backgroundImage: String = "template-default",
        accentColor: String = "#6366F1",
        isPremium: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.description = description
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
        self.strictness = strictness
        self.backgroundImage = backgroundImage
        self.accentColor = accentColor
        self.isPremium = isPremium
        self.sortOrder = sortOrder
    }

    /// Convert template to BlockingRuleRecord for scheduling
    func toBlockingRule() -> BlockingRuleRecord {
        BlockingRuleRecord(
            name: name,
            isActive: true,
            strictness: strictness,
            daysOfWeek: daysOfWeek,
            startTime: startTime,
            endTime: endTime
        )
    }

    /// Formatted time range string
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let calendar = Calendar.current
        let startDate = calendar.date(from: startTime) ?? Date()
        let endDate = calendar.date(from: endTime) ?? Date()

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    /// Days of week as readable string
    var daysString: String {
        if daysOfWeek == Set(1...7) {
            return "Every day"
        } else if daysOfWeek == Set([2, 3, 4, 5, 6]) {
            return "Weekdays"
        } else if daysOfWeek == Set([1, 7]) {
            return "Weekends"
        } else {
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return daysOfWeek.sorted().map { dayNames[$0 - 1] }.joined(separator: ", ")
        }
    }

    /// SwiftUI Color from hex
    var color: Color {
        Color(hex: accentColor)
    }
}

// MARK: - Template Category

enum TemplateCategory: String, Codable, CaseIterable {
    case focus = "Focus & Productivity"
    case sleep = "Sleep & Rest"
    case wellness = "Health & Wellness"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .sleep: return "moon.stars.fill"
        case .wellness: return "heart.fill"
        case .custom: return "slider.horizontal.3"
        }
    }

    var color: Color {
        switch self {
        case .focus: return Color(hex: "#6366F1") // Indigo
        case .sleep: return Color(hex: "#8B5CF6") // Purple
        case .wellness: return Color(hex: "#10B981") // Green
        case .custom: return Color(hex: "#F59E0B") // Amber
        }
    }
}

// MARK: - Pre-made Templates

extension BlockTemplate {

    /// All default templates (Opal-inspired)
    static let allTemplates: [BlockTemplate] = [
        // FOCUS & PRODUCTIVITY
        .laserFocus,
        .deepWork,
        .morningFocus,
        .afternoonFlow,
        .workTime,

        // SLEEP & REST
        .deepSleep,
        .riseAndShine,
        .windDown,
        .weekendZen,

        // HEALTH & WELLNESS
        .digitalSabbath,
        .mealTime,
        .exerciseHour
    ]

    /// Laser Focus - 2-3pm weekdays (Opal's signature)
    static let laserFocus = BlockTemplate(
        name: "Laser Focus",
        emoji: "🕯️",
        description: "Your daily focus hour from 2-3pm, Weekdays",
        category: .focus,
        startTime: DateComponents(hour: 14, minute: 0),
        endTime: DateComponents(hour: 15, minute: 0),
        daysOfWeek: Set([2, 3, 4, 5, 6]), // Mon-Fri
        strictness: .strict,
        backgroundImage: "template-laser-focus",
        accentColor: "#F59E0B", // Amber
        sortOrder: 0
    )

    /// Deep Work - Morning block
    static let deepWork = BlockTemplate(
        name: "Deep Work",
        emoji: "🧠",
        description: "Uninterrupted deep work session, 9am-12pm",
        category: .focus,
        startTime: DateComponents(hour: 9, minute: 0),
        endTime: DateComponents(hour: 12, minute: 0),
        daysOfWeek: Set([2, 3, 4, 5, 6]),
        strictness: .strict,
        backgroundImage: "template-deep-work",
        accentColor: "#6366F1", // Indigo
        isPremium: true,
        sortOrder: 1
    )

    /// Morning Focus - Early bird
    static let morningFocus = BlockTemplate(
        name: "Morning Focus",
        emoji: "🌅",
        description: "Start your day focused, 7-9am",
        category: .focus,
        startTime: DateComponents(hour: 7, minute: 0),
        endTime: DateComponents(hour: 9, minute: 0),
        daysOfWeek: Set([2, 3, 4, 5, 6]),
        strictness: .normal,
        backgroundImage: "template-morning",
        accentColor: "#F97316", // Orange
        sortOrder: 2
    )

    /// Afternoon Flow - Post-lunch productivity
    static let afternoonFlow = BlockTemplate(
        name: "Afternoon Flow",
        emoji: "⚡",
        description: "Beat the afternoon slump, 1-4pm",
        category: .focus,
        startTime: DateComponents(hour: 13, minute: 0),
        endTime: DateComponents(hour: 16, minute: 0),
        daysOfWeek: Set([2, 3, 4, 5, 6]),
        strictness: .normal,
        backgroundImage: "template-afternoon",
        accentColor: "#14B8A6", // Teal
        sortOrder: 3
    )

    /// Work Time - Standard 9-5
    static let workTime = BlockTemplate(
        name: "Work Time",
        emoji: "💼",
        description: "Block distractions during work, 9am-5pm Weekdays",
        category: .focus,
        startTime: DateComponents(hour: 9, minute: 0),
        endTime: DateComponents(hour: 17, minute: 0),
        daysOfWeek: Set([2, 3, 4, 5, 6]),
        strictness: .normal,
        backgroundImage: "template-work",
        accentColor: "#3B82F6", // Blue
        isPremium: true,
        sortOrder: 4
    )

    /// Deep Sleep - Night blocking
    static let deepSleep = BlockTemplate(
        name: "Deep Sleep",
        emoji: "🌙",
        description: "Boost your sleep's restorative qualities, 10pm-6am",
        category: .sleep,
        startTime: DateComponents(hour: 22, minute: 0),
        endTime: DateComponents(hour: 6, minute: 0),
        daysOfWeek: Set(1...7),
        strictness: .strict,
        backgroundImage: "template-deep-sleep",
        accentColor: "#8B5CF6", // Purple
        sortOrder: 5
    )

    /// Rise & Shine - Morning block
    static let riseAndShine = BlockTemplate(
        name: "Rise & Shine",
        emoji: "☀️",
        description: "Wake up without distraction, 6-9am Daily",
        category: .sleep,
        startTime: DateComponents(hour: 6, minute: 0),
        endTime: DateComponents(hour: 9, minute: 0),
        daysOfWeek: Set(1...7),
        strictness: .normal,
        backgroundImage: "template-rise-shine",
        accentColor: "#FBBF24", // Yellow
        sortOrder: 6
    )

    /// Wind Down - Evening routine
    static let windDown = BlockTemplate(
        name: "Wind Down",
        emoji: "🌆",
        description: "Great sleep starts before bed, 8pm-10pm",
        category: .sleep,
        startTime: DateComponents(hour: 20, minute: 0),
        endTime: DateComponents(hour: 22, minute: 0),
        daysOfWeek: Set(1...7),
        strictness: .normal,
        backgroundImage: "template-wind-down",
        accentColor: "#EC4899", // Pink
        sortOrder: 7
    )

    /// Weekend Zen - Weekend morning peace
    static let weekendZen = BlockTemplate(
        name: "Weekend Zen",
        emoji: "🧘",
        description: "Peaceful morning routine, 9am-11am Weekends",
        category: .wellness,
        startTime: DateComponents(hour: 9, minute: 0),
        endTime: DateComponents(hour: 11, minute: 0),
        daysOfWeek: Set([1, 7]),
        strictness: .normal,
        backgroundImage: "template-weekend-zen",
        accentColor: "#10B981", // Green
        sortOrder: 8
    )

    /// Digital Sabbath - Full weekend day
    static let digitalSabbath = BlockTemplate(
        name: "Digital Sabbath",
        emoji: "🙏",
        description: "Block apps from sundown to sundown, Weekends",
        category: .wellness,
        startTime: DateComponents(hour: 18, minute: 0),
        endTime: DateComponents(hour: 18, minute: 0),
        daysOfWeek: Set([1, 7]),
        strictness: .unbreakable,
        backgroundImage: "template-sabbath",
        accentColor: "#7C3AED", // Violet
        isPremium: true,
        sortOrder: 9
    )

    /// Meal Time - No phones during meals
    static let mealTime = BlockTemplate(
        name: "Mindful Meals",
        emoji: "🍽️",
        description: "Focus on food, not phones. Lunch & dinner blocks",
        category: .wellness,
        startTime: DateComponents(hour: 12, minute: 0),
        endTime: DateComponents(hour: 13, minute: 0),
        daysOfWeek: Set(1...7),
        strictness: .normal,
        backgroundImage: "template-meals",
        accentColor: "#EF4444", // Red
        sortOrder: 10
    )

    /// Exercise Hour - Workout time
    static let exerciseHour = BlockTemplate(
        name: "Exercise Hour",
        emoji: "🏃",
        description: "Stay present during workouts, 6-7am Daily",
        category: .wellness,
        startTime: DateComponents(hour: 6, minute: 0),
        endTime: DateComponents(hour: 7, minute: 0),
        daysOfWeek: Set(1...7),
        strictness: .normal,
        backgroundImage: "template-exercise",
        accentColor: "#06B6D4", // Cyan
        sortOrder: 11
    )
}
