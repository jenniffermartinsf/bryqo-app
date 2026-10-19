import Foundation

enum BryqoTab: String, CaseIterable, Identifiable {
    case valley = "Vale"
    case learn = "Aprender"
    case backpack = "Mochila"
    case achievements = "Conquistas"
    case profile = "Perfil"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .valley:
            return "mountain.2.fill"
        case .learn:
            return "map.fill"
        case .backpack:
            return "backpack.fill"
        case .achievements:
            return "rosette"
        case .profile:
            return "person.crop.circle"
        }
    }
}
