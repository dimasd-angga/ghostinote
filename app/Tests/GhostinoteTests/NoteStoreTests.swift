import XCTest
@testable import Ghostinote

final class NoteStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUpWithError() throws {
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("ghostinote-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testSaveAndLoadRoundTrip() throws {
        let store = NoteStore(directory: tempDir)
        let note = Note(title: "Hello", body: "# Hello\nWorld")
        try store.save(note)

        let loaded = store.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, note.id)
        XCTAssertEqual(loaded[0].title, "Hello")
        XCTAssertEqual(loaded[0].body, "# Hello\nWorld")
    }

    func testDelete() throws {
        let store = NoteStore(directory: tempDir)
        let note = Note(title: "A", body: "body")
        try store.save(note)
        XCTAssertEqual(store.loadAll().count, 1)
        try store.delete(id: note.id)
        XCTAssertEqual(store.loadAll().count, 0)
    }

    func testTitleSurvivesEvenWhenBodyHasNoHeading() throws {
        let store = NoteStore(directory: tempDir)
        let note = Note(title: "Custom Title", body: "no heading here")
        try store.save(note)
        let loaded = store.loadAll().first!
        XCTAssertEqual(loaded.title, "Custom Title")
        XCTAssertEqual(loaded.body, "no heading here")
    }

    func testLoadIgnoresNonMarkdownAndBadFilenames() throws {
        let store = NoteStore(directory: tempDir)
        try "junk".data(using: .utf8)!.write(to: tempDir.appendingPathComponent("not-a-uuid.md"))
        try "junk".data(using: .utf8)!.write(to: tempDir.appendingPathComponent("README.txt"))
        XCTAssertEqual(store.loadAll().count, 0)
    }

    func testDeriveTitleFromBody() {
        XCTAssertEqual(Note.deriveTitle(from: "# Heading\nbody"), "Heading")
        XCTAssertEqual(Note.deriveTitle(from: "plain first line"), "plain first line")
        XCTAssertEqual(Note.deriveTitle(from: ""), "Untitled")
        XCTAssertEqual(Note.deriveTitle(from: "\n\n   \n## Second"), "Second")
    }
}
