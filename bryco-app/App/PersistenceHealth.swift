import Foundation

/// Whether the user's progress is actually being written to disk.
enum PersistenceHealth: Equatable {
    /// The on-disk store is open and the last save succeeded.
    case healthy
    /// The on-disk store could not be opened, so the app runs on a throwaway in-memory store:
    /// everything works, but nothing survives closing the app.
    case temporaryStorage
    /// The store is open, but the last save failed. Cleared by the next successful save.
    case saveFailed

    /// The warning shown to the user, or `nil` when there is nothing to report.
    var bannerMessage: String? {
        switch self {
        case .healthy:
            nil
        case .temporaryStorage:
            "Não foi possível abrir seus dados salvos. O progresso de hoje não será guardado ao fechar o app."
        case .saveFailed:
            "Não conseguimos salvar seu progresso agora. Vamos tentar de novo na próxima ação."
        }
    }
}
