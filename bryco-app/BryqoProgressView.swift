import SwiftUI

struct BryqoProgressView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    private var unitProgress: Double {
        guard !unit.lessons.isEmpty else {
            return 0
        }

        return Double(appState.completedLessonCount) / Double(unit.lessons.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.spacing) {
                    header
                    statsGrid
                    materials
                }
                .padding()
            }
            .background(BryqoTheme.softBackground.ignoresSafeArea())
            .navigationTitle("Progresso")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sua construção")
                .font(.title2.bold())
                .foregroundStyle(BryqoTheme.forest)

            ProgressView(value: unitProgress)
                .tint(BryqoTheme.forest)

            Text("\(appState.completedLessonCount) de \(unit.lessons.count) lições concluídas")
                .foregroundStyle(.secondary)
        }
        .bryqoCard()
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(title: "XP", value: "\(appState.progress.xp)", icon: "sparkles")
            statCard(title: "Ritmo", value: "\(appState.progress.streakDays)d", icon: "flame.fill")
            statCard(title: "Unidade", value: "\(Int(unitProgress * 100))%", icon: "map.fill")
            statCard(title: "Materiais", value: "\(appState.progress.earnedMaterials.count)", icon: "shippingbox.fill")
        }
    }

    private var materials: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Materiais conquistados")
                .font(.headline)

            if appState.progress.earnedMaterials.isEmpty {
                Text("Complete uma lição para ganhar o primeiro material.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(appState.progress.earnedMaterials.enumerated()), id: \.offset) { _, material in
                    Label(material, systemImage: "checkmark.seal.fill")
                        .foregroundStyle(BryqoTheme.forest)
                }
            }
        }
        .bryqoCard()
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(BryqoTheme.forest)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bryqoCard()
    }
}
