import Foundation
import Testing
import UIKit
@testable import bryco_app

private func tempAvatarURL() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent("avatar-\(UUID().uuidString).jpg")
}

/// A camera-sized JPEG (4032×3024, like the photos on a real phone).
private func cameraPhoto(color: UIColor = .systemGreen) -> Data {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let image = UIGraphicsImageRenderer(size: CGSize(width: 4032, height: 3024), format: format).image { context in
        color.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 4032, height: 3024))
    }
    return image.jpegData(compressionQuality: 0.9)!
}

@MainActor
@Suite("Avatar store")
struct AvatarStoreTests {

    @Test("A camera photo is stored at most 512 px wide")
    func photoIsShrunk() async throws {
        let url = tempAvatarURL()
        let photo = cameraPhoto()
        let stored = try await AvatarStore(fileURL: url).save(photo)

        let size = try #require(AvatarStore.pixelSize(of: stored))
        #expect(max(size.width, size.height) == AvatarStore.maxPixelSize)
        #expect(size.width * 3 == size.height * 4)   // aspect ratio kept
        #expect(stored.count < photo.count / 10)
        #expect(try Data(contentsOf: url) == stored)
    }

    @Test("Data that isn't an image is rejected and nothing is written")
    func invalidImage() async {
        let url = tempAvatarURL()
        await #expect(throws: AvatarError.self) {
            try await AvatarStore(fileURL: url).save(Data("not an image".utf8))
        }
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test("A slow photo that finishes after a newer one never overwrites it")
    func olderSaveLosesTheRace() async throws {
        let url = tempAvatarURL()
        let (firstStarted, started) = AsyncStream<Void>.makeStream()
        let (firstMayFinish, release) = AsyncStream<Void>.makeStream()
        let first = Data("first".utf8)

        // The first photo waits until the test releases it; the second is immediate.
        let store = AvatarStore(fileURL: url) { photo in
            if photo == first {
                started.yield()
                for await _ in firstMayFinish { break }
            }
            return photo
        }

        let slowSave = Task { try await store.save(first) }
        for await _ in firstStarted { break }   // the first save is now shrinking
        _ = try await store.save(Data("second".utf8))
        release.yield()

        await #expect(throws: CancellationError.self) { try await slowSave.value }
        #expect(try Data(contentsOf: url) == Data("second".utf8))
    }

    @Test("An avatar saved full size by an older version is shrunk on first load")
    func legacyAvatarIsShrunkOnLoad() async throws {
        let url = tempAvatarURL()
        try cameraPhoto().write(to: url)

        let loaded = try #require(await AvatarStore(fileURL: url).load())

        let size = try #require(AvatarStore.pixelSize(of: loaded))
        #expect(max(size.width, size.height) == AvatarStore.maxPixelSize)
        #expect(try Data(contentsOf: url) == loaded)
    }

    @Test("The app state shows the shrunk avatar")
    func appStateShowsAvatar() async throws {
        let appState = BryqoAppState(inMemory: true, avatarStore: AvatarStore(fileURL: tempAvatarURL()))
        #expect(appState.avatarImage == nil)

        try await appState.setAvatar(cameraPhoto())

        let image = try #require(appState.avatarImage)
        #expect(max(image.size.width * image.scale, image.size.height * image.scale) == 512)
    }
}
