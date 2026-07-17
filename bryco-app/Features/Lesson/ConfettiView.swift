import SwiftUI

struct ConfettiView: View {
    struct Particle: Identifiable {
        let id: Int
        let startX: CGFloat
        let driftX: CGFloat
        let color: Color
        let size: CGFloat
        let duration: Double
        let delay: Double
        let rotationEnd: Double
        let isCircle: Bool
    }

    @State private var particles: [Particle] = []
    @State private var active = false

    private let colors: [Color] = [
        BryqoTheme.success, BryqoTheme.sun, BryqoTheme.river,
        Color(hex: 0xCE82FF), BryqoTheme.error, Color(hex: 0xFF9800)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                ForEach(particles) { p in
                    confettiShape(p)
                        .offset(
                            x: (active ? p.startX + p.driftX : p.startX) - p.size / 2,
                            y: active ? geo.size.height + 60 : -20
                        )
                        .rotationEffect(.degrees(active ? p.rotationEnd : 0))
                        .animation(
                            .easeIn(duration: p.duration).delay(p.delay),
                            value: active
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                particles = generate(width: geo.size.width)
                Task {
                    try? await Task.sleep(for: .milliseconds(80))
                    active = true
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func confettiShape(_ p: Particle) -> some View {
        if p.isCircle {
            Circle()
                .fill(p.color)
                .frame(width: p.size, height: p.size)
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(p.color)
                .frame(width: p.size * 1.6, height: p.size * 0.65)
        }
    }

    private func generate(width: CGFloat) -> [Particle] {
        (0..<60).map { i in
            let column = CGFloat(i % 12) / 12.0
            let jitter = CGFloat(i * 13 % 30 - 15)
            let startX = column * width + jitter
            let driftX = CGFloat(i * 11 % 100 - 50)
            let sizes: [CGFloat] = [6, 8, 10, 12]
            let duration = 1.1 + Double(i % 7) * 0.15
            let delay = Double(i % 12) * 0.03
            let rotation = Double(i * 37 % 720) - 360.0
            return Particle(
                id: i,
                startX: startX,
                driftX: driftX,
                color: colors[i % colors.count],
                size: sizes[i % 4],
                duration: duration,
                delay: delay,
                rotationEnd: rotation,
                isCircle: i % 3 == 0
            )
        }
    }
}
