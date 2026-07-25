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
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sequência Bryqo")
        .description("Sua sequência de dias e o progresso da meta diária.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

// MARK: - Views

private enum WidgetPalette {
    static let flame = Color(red: 1.0, green: 0.42, blue: 0.29)      // coral
    static let ring = Color(red: 0.30, green: 0.69, blue: 0.42)      // primary green
    static let track = Color.gray.opacity(0.25)
}

struct BryqoWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: BryqoWidgetSnapshot

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircular
        case .systemMedium:
            medium
        default:
            small
        }
    }

    private var medium: some View {
        HStack(spacing: 16) {
            // Streak
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(WidgetPalette.flame)
                    Text("\(snapshot.streakDays)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                }
                Text(snapshot.streakDays == 1 ? "dia de sequência" : "dias de sequência")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Divider()

            // Daily goal
            VStack(spacing: 6) {
                ring(progress: snapshot.dailyGoalProgress, size: 58)
                    .overlay {
                        Text("\(Int(snapshot.dailyGoalProgress * 100))%")
                            .font(.caption.weight(.bold)).foregroundStyle(.primary)
                    }
                Text("\(snapshot.dailyXpEarned)/\(snapshot.dailyGoalXp) XP")
                    .font(.caption.weight(.bold)).foregroundStyle(.primary)
                Text("Meta diária").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill").foregroundStyle(WidgetPalette.flame)
                Text("\(snapshot.streakDays)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
            Text(snapshot.streakDays == 1 ? "dia de sequência" : "dias de sequência")
                .font(.caption).foregroundStyle(.secondary)

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                ring(progress: snapshot.dailyGoalProgress, size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Meta diária").font(.caption2).foregroundStyle(.secondary)
                    Text("\(snapshot.dailyXpEarned)/\(snapshot.dailyGoalXp) XP")
                        .font(.caption.weight(.bold)).foregroundStyle(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var accessoryCircular: some View {
        Gauge(value: snapshot.dailyGoalProgress) {
            Image(systemName: "flame.fill")
        } currentValueLabel: {
            Text("\(snapshot.streakDays)")
        }
        .gaugeStyle(.accessoryCircular)
    }

    private func ring(progress: Double, size: CGFloat) -> some View {
        ZStack {
            Circle().stroke(WidgetPalette.track, lineWidth: 5)
            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(WidgetPalette.ring, style: StrokeStyle(lineWidth: 5, lineCap: .round))
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
