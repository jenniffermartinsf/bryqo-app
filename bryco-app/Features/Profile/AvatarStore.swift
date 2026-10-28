import Foundation
import ImageIO
import UniformTypeIdentifiers

enum AvatarError: Error {
    case unreadableImage
}

/// Owns the avatar file on disk.
///
/// - As an actor, its state is touched by one caller at a time, and file I/O never runs on
///   the main thread.
/// - Shrinking the photo is `@concurrent`, outside the actor, so a slow photo doesn't hold the
///   actor while it works.
/// - Only `Data` (which is `Sendable`) crosses in and out.
actor AvatarStore {
    /// The avatar is a 96 pt circle: 512 px covers it at 3x with room to spare.
    static let maxPixelSize = 512

    typealias Shrink = @Sendable (Data) async throws -> Data

    private let fileURL: URL
    private let shrink: Shrink
    /// Bumped by every save, so an older save that finishes late knows it was replaced.
    private var latestSave = 0

    init(fileURL: URL = AvatarStore.defaultFileURL,
         shrink: @escaping Shrink = { try await AvatarStore.thumbnail(from: $0) }) {
        self.fileURL = fileURL
        self.shrink = shrink
    }

    nonisolated static var defaultFileURL: URL {
        URL.documentsDirectory.appendingPathComponent("bryqo_avatar.jpg")
    }

    /// Shrinks a picked photo and stores it. Returns the stored JPEG.
    /// Throws `CancellationError` if a newer photo was saved while this one was being shrunk.
    func save(_ photo: Data) async throws -> Data {
        latestSave += 1
        let thisSave = latestSave

        let avatar = try await shrink(photo)

        // Reentrancy: the actor took other calls during the `await`. Check again before writing.
        guard thisSave == latestSave else { throw CancellationError() }
        try avatar.write(to: fileURL, options: .atomic)
        return avatar
    }

    /// The stored avatar. Photos saved before the avatar was shrunk are shrunk once here.
    func load() async -> Data? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard let size = Self.pixelSize(of: data), max(size.width, size.height) > Self.maxPixelSize else {
            return data
        }
        return (try? await save(data)) ?? data
    }

    func remove() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Image work, off every actor

    /// Decodes only as many pixels as the thumbnail needs (a 12 MP photo is never fully
    /// decoded) and encodes the result as JPEG.
    @concurrent
    nonisolated static func thumbnail(from data: Data, maxPixelSize: Int = maxPixelSize) async throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw AvatarError.unreadableImage
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw AvatarError.unreadableImage
        }
        try Task.checkCancellation()

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw AvatarError.unreadableImage
        }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw AvatarError.unreadableImage }
        return output as Data
    }

    nonisolated static func pixelSize(of data: Data) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        return (width, height)
    }
}
