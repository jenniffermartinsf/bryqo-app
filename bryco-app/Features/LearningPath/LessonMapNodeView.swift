import SwiftUI

// MARK: - Lesson Status

enum LessonStatus {
    case locked
    case available  // unlocked, not yet the highlighted "next"
    case current    // the one lesson the user should do next — pulsing
    case completed
}

// MARK: - Lesson Map Node

struct LessonMapNodeView: View {
    let lesson: Lesson
    let status: LessonStatus
    var entranceDelay: Double = 0
    let onTap: () -> Void

    @State private var pulsing = false
    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: BryqoTheme.Spacing.sm) {
                nodeStack
                    .frame(width: nodeSize + 32, height: nodeSize + 14)

                Text(lesson.title)
                    .bryqoFont(12, weight: .bold, design: .rounded)
                    .foregroundStyle(
                        status == .locked ? BryqoTheme.textSecondary : BryqoTheme.textPrimary
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 96)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .scaleEffect(appeared ? 1.0 : 0.6)
        .opacity(appeared ? 1.0 : 0)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.7).delay(entranceDelay),
            value: appeared
        )
        .overlay(alignment: .topTrailing) {
            if status == .completed {
                Text("+\(lesson.xpReward) XP")
                    .bryqoFont(9, weight: .black, design: .rounded)
                    .foregroundStyle(BryqoTheme.sun)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(BryqoTheme.sun.opacity(0.18))
                    .clipShape(Capsule())
                    .offset(x: 10, y: -2)
            }
        }
        .onAppear {
            appeared = true
            guard status == .current || status == .available else { return }
            pulsing = true
        }
    }

    // MARK: - Node Stack

    private var nodeStack: some View {
        ZStack {
            // Expanding pulse ring (current / available)
            if status == .current || status == .available {
                Circle()
                    .stroke(accentColor.opacity(pulsing ? 0 : 0.4), lineWidth: 4)
                    .scaleEffect(pulsing ? 1.65 : 1.0)
                    .frame(width: nodeSize, height: nodeSize)
                    .animation(
                        .easeOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: pulsing
                    )
            }

            // 3D shadow disc
            if status != .locked {
                Circle()
                    .fill(accentColor.shadowed)
                    .frame(width: nodeSize, height: nodeSize)
                    .offset(y: 5)
            }

            // Face disc
            Circle()
                .fill(faceFill)
                .overlay {
                    if status == .locked {
                        Circle().stroke(BryqoTheme.border, lineWidth: 2.5)
                    } else {
                        // Inner highlight for depth
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.24), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(width: nodeSize, height: nodeSize)

            // Icon
            Image(systemName: iconName)
                .font(.system(size: nodeSize * 0.30, weight: .bold))
                .foregroundStyle(iconColor)
                .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
        }
    }

    // MARK: - Computed Properties

    private var nodeSize: CGFloat {
        switch status {
        case .locked:    return 52
        case .available: return 64
        case .current:   return 74
        case .completed: return 56
        }
    }

    private var accentColor: Color {
        switch status {
        case .locked:    return BryqoTheme.border
        case .available: return BryqoTheme.river
        case .current:   return BryqoTheme.success
        case .completed: return BryqoTheme.success
        }
    }

    private var faceFill: Color {
        status == .locked ? BryqoTheme.surface : accentColor
    }

    private var iconName: String {
        switch status {
        case .locked:    return "lock.fill"
        case .available: return "play.fill"
        case .current:   return "star.fill"
        case .completed: return "checkmark"
        }
    }

    private var iconColor: Color {
        status == .locked ? BryqoTheme.textSecondary : .white
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        LessonMapNodeView(
            lesson: BryqoContent.sampleUnit.lessons[0],
            status: .completed,
            onTap: {}
        )
        LessonMapNodeView(
            lesson: BryqoContent.sampleUnit.lessons[1],
            status: .current,
            onTap: {}
        )
        LessonMapNodeView(
            lesson: BryqoContent.sampleUnit.lessons[2],
            status: .available,
            onTap: {}
        )
        LessonMapNodeView(
            lesson: BryqoContent.sampleUnit.lessons[3],
            status: .locked,
            onTap: {}
        )
    }
    .padding(32)
    .background(BryqoTheme.background)
    .preferredColorScheme(.dark)
}
