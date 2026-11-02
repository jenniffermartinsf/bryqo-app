import Foundation
import Testing
import UIKit
@testable import bryco_app

/// Picking a profile photo: loading while it's read and shrunk, a message for each way it can
/// fail, and the new photo on success.
@MainActor
@Suite("Avatar update")
struct AvatarUpdateTests {
    let appState = BryqoAppState(inMemory: true)

    private func makeModel() -> ProfileModel {
        ProfileModel(appState: appState, account: FakeAccount(), syncWithCloud: {})
    }

    private var jpeg: Data {
        UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40)).jpegData(withCompressionQuality: 0.9) { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
        }
    }

    @Test("A readable photo becomes the avatar and leaves no message")
    func success() async {
        let model = makeModel()

        await model.usePhoto { jpeg }

        #expect(model.avatarImage != nil)
        #expect(model.avatarUpdate == .idle)
    }

    @Test("While the photo loads, the avatar shows it's working")
    func loading() async {
        let model = makeModel()
        let (gate, open) = AsyncStream<Void>.makeStream()

        let pick = Task { await model.usePhoto { for await _ in gate { break }; return jpeg } }
        while model.avatarUpdate != .loading { await Task.yield() }

        #expect(model.avatarUpdate == .loading)
        open.yield()
        await pick.value
        #expect(model.avatarUpdate == .idle)
    }

    @Test("A file that isn't an image says so and keeps the current avatar")
    func unreadable() async {
        let model = makeModel()

        await model.usePhoto { Data("not an image".utf8) }

        #expect(model.avatarUpdate == .failed(.unreadable))
        #expect(model.avatarImage == nil)
    }

    @Test("A photo that doesn't arrive from the library says so", arguments: [true, false])
    func couldNotLoad(throwsError: Bool) async {
        struct OfflineError: Error {}
        let model = makeModel()

        await model.usePhoto {
            if throwsError { throw OfflineError() }
            return nil
        }

        #expect(model.avatarUpdate == .failed(.couldNotLoad))
    }

    @Test("Leaving the screen mid-load doesn't leave the avatar spinning")
    func cancelledLoad() async {
        let model = makeModel()

        let pick = Task { await model.usePhoto { try await Task.sleep(for: .seconds(30)); return jpeg } }
        while model.avatarUpdate != .loading { await Task.yield() }
        pick.cancel()
        await pick.value

        #expect(model.avatarUpdate == .idle)
        #expect(model.avatarImage == nil)
    }

    @Test("Picking again after a failure clears the message")
    func retryClearsFailure() async {
        let model = makeModel()
        await model.usePhoto { Data("not an image".utf8) }

        await model.usePhoto { jpeg }

        #expect(model.avatarUpdate == .idle)
        #expect(model.avatarImage != nil)
    }
}
