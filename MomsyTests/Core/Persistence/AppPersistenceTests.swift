import Foundation
import Testing
import SwiftData
@testable import Momsy

@MainActor
struct AppPersistenceTests {
    @Test func freshStoreFailureThrowsAndKeepsBackup() throws {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: directory) }

        let store = directory.appendingPathComponent("default.store")
        let wal = URL(fileURLWithPath: store.path + "-wal")
        try Data("store".utf8).write(to: store)
        try Data("wal".utf8).write(to: wal)

        let suiteName = "AppPersistenceTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var attempts = 0

        do {
            _ = try AppPersistence.makeContainer(
                defaults: defaults,
                fileManager: fileManager,
                storeURL: store
            ) { _, _ in
                attempts += 1
                throw StubContainerError()
            }
            Issue.record("Expected AppPersistence.makeContainer to throw")
        } catch let error as AppPersistenceError {
            guard case .freshStoreCreationFailed = error else {
                Issue.record("Unexpected persistence error: \(error)")
                return
            }
        }

        #expect(attempts == 2)
        #expect(!fileManager.fileExists(atPath: store.path))
        #expect(!fileManager.fileExists(atPath: wal.path))
        #expect(fileManager.fileExists(atPath: store.path + ".backup"))
        #expect(fileManager.fileExists(atPath: store.path + ".backup-wal"))
    }
}

private struct StubContainerError: LocalizedError {
    var errorDescription: String? { "Stub container failure" }
}
