import WidgetKit
import SwiftUI

// MARK: - Timeline

struct BryqoEntry: TimelineEntry {
    let date: Date
    let snapshot: BryqoWidgetSnapshot
}

struct BryqoProvider: TimelineProvider {
    func placeholder(in context: Context) -> BryqoEntry {
        BryqoEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (BryqoEntry) -> Void) {
        completion(BryqoEntry(date: Date(), snapshot: BryqoSharedStore.read() ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BryqoEntry>) -> Void) {
        let snapshot = BryqoSharedStore.read() ?? .placeholder
        let entry = BryqoEntry(date: Date(), snapshot: snapshot)
        // The app pushes fresh data + reloads on every change; refresh at the next midnight so the
        // daily ring resets even if the app isn't opened.
        let nextMidnight = Calendar.current.nextDate(
            after: Date(), matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

// MARK: - Widget

struct BryqoStreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BryqoStreakWidget", provider: BryqoProvider()) { entry in
            BryqoWidgetView(snapshot: entry.snapshot)
        }
        .configurationDisplayName("Sequência Bryqo")
        .description("Sua sequência de dias e o progresso da meta diária.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

// MARK: - Palette

private enum WidgetPalette {
    // Brand "valley" gradient — deep forest into teal.
    static let gradientTop = Color(red: 0.19, green: 0.51, blue: 0.34)
    static let gradientBottom = Color(red: 0.09, green: 0.28, blue: 0.27)
    static let flame = Color(red: 1.0, green: 0.58, blue: 0.28)
    static let flameGlow = Color(red: 1.0, green: 0.42, blue: 0.29)
    static let ringFill = Color(red: 0.97, green: 0.82, blue: 0.38)   // sun gold
    static let ringTrack = Color.white.opacity(0.18)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)

    static var background: LinearGradient {
        LinearGradient(colors: [gradientTop, gradientBottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Views

struct BryqoWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: BryqoWidgetSnapshot

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .accessoryCircular {
                    Color.clear
                } else {
                    WidgetPalette.background
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular: accessoryCircular
        case .systemMedium:      medium
        default:                 small
        }
    }

    // MARK: Small

    private var small: some View {
        VStack(alignment: .leading, spacing: 0) {
            flame(size: 30)

            Text("\(snapshot.streakDays)")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(WidgetPalette.textPrimary)
                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
            Text(streakLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(WidgetPalette.textSecondary)

            Spacer(minLength: 6)

            HStack(spacing: 9) {
                ring(size: 30, lineWidth: 5)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(snapshot.dailyXpEarned)/\(snapshot.dailyGoalXp)")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(WidgetPalette.textPrimary)
                    Text("XP hoje")
                        .font(.caption2)
                        .foregroundStyle(WidgetPalette.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Medium

    private var medium: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 2) {
                flame(size: 34)
                Spacer(minLength: 4)
                Text("\(snapshot.streakDays)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(WidgetPalette.textPrimary)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                Text(streakLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WidgetPalette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 1)

            VStack(spacing: 8) {
                ring(size: 74, lineWidth: 8)
                    .overlay {
                        Text("\(Int(snapshot.dailyGoalProgress * 100))%")
                            .font(.headline.weight(.black))
                            .foregroundStyle(WidgetPalette.textPrimary)
                    }
                VStack(spacing: 1) {
                    Text("\(snapshot.dailyXpEarned)/\(snapshot.dailyGoalXp) XP")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(WidgetPalette.textPrimary)
                    Text("Meta diária")
                        .font(.caption2)
                        .foregroundStyle(WidgetPalette.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Lock screen

    private var accessoryCircular: some View {
        Gauge(value: snapshot.dailyGoalProgress) {
            Image(systemName: "flame.fill")
        } currentValueLabel: {
            Text("\(snapshot.streakDays)")
        }
        .gaugeStyle(.accessoryCircular)
    }

    // MARK: Pieces

    private var streakLabel: String {
        snapshot.streakDays == 1 ? "dia de sequência" : "dias de sequência"
    }

    private func flame(size: CGFloat) -> some View {
        Image(systemName: "flame.fill")
            .font(.system(size: size))
            .foregroundStyle(
                LinearGradient(colors: [WidgetPalette.flame, WidgetPalette.flameGlow],
                               startPoint: .top, endPoint: .bottom)
            )
            .shadow(color: WidgetPalette.flameGlow.opacity(0.55), radius: 7)
    }

    private func ring(size: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle().stroke(WidgetPalette.ringTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, snapshot.dailyGoalProgress))
                .stroke(
                    AngularGradient(
                        colors: [WidgetPalette.ringFill.opacity(0.85), WidgetPalette.ringFill],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

#Preview(as: .systemSmall) {
    BryqoStreakWidget()
} timeline: {
    BryqoEntry(date: .now, snapshot: .placeholder)
    BryqoEntry(date: .now, snapshot: BryqoWidgetSnapshot(streakDays: 12, dailyXpEarned: 30, dailyGoalXp: 30, updatedAt: .now))
}

#Preview(as: .systemMedium) {
    BryqoStreakWidget()
} timeline: {
    BryqoEntry(date: .now, snapshot: BryqoWidgetSnapshot(streakDays: 5, dailyXpEarned: 20, dailyGoalXp: 30, updatedAt: .now))
}
