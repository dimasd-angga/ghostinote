import XCTest
@testable import Ghostinote

@MainActor
final class NotesViewModelTests: XCTestCase {
    private var tempDir: URL!
    private var store: NoteStore!

    override func setUpWithError() throws {
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("ghostinote-vm-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = NoteStore(directory: tempDir)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testEachTabKeepsItsOwnMode() {
        let vm = NotesViewModel(store: store)
        let firstID = vm.selectedID

        vm.addNote()
        let secondID = vm.selectedID
        XCTAssertNotEqual(firstID, secondID)

        vm.setMode(.preview, for: firstID)
        vm.setMode(.edit, for: secondID)

        XCTAssertEqual(vm.mode(of: firstID), .preview)
        XCTAssertEqual(vm.mode(of: secondID), .edit)

        vm.select(firstID)
        XCTAssertEqual(vm.mode(of: vm.selectedID), .preview)
        vm.select(secondID)
        XCTAssertEqual(vm.mode(of: vm.selectedID), .edit)
    }

    func testClosingTabForgetsItsMode() {
        let vm = NotesViewModel(store: store)
        vm.addNote()
        let id = vm.selectedID
        vm.setMode(.preview, for: id)
        vm.closeNote(id: id)
        XCTAssertEqual(vm.mode(of: id), .edit)
    }

    func testIsMarkdownFlagUpdatesWithBody() {
        let vm = NotesViewModel(store: store)
        vm.addNote()
        let id = vm.selectedID

        vm.updateBody(of: id, to: "plain text")
        XCTAssertFalse(vm.isMarkdown(id))

        vm.updateBody(of: id, to: "# heading\nbody")
        XCTAssertTrue(vm.isMarkdown(id))

        vm.updateBody(of: id, to: "no longer markdown")
        XCTAssertFalse(vm.isMarkdown(id))
    }

    func testMoveReordersNotes() {
        let vm = NotesViewModel(store: store)
        let a = vm.notes[0].id
        vm.addNote()
        let b = vm.notes[0].id
        vm.addNote()
        let c = vm.notes[0].id
        // initial order: [c, b, a]
        XCTAssertEqual(vm.notes.map(\.id), [c, b, a])

        vm.move(a, toIndex: 0)
        XCTAssertEqual(vm.notes.map(\.id), [a, c, b])

        vm.move(c, toIndex: 2)
        XCTAssertEqual(vm.notes.map(\.id), [a, b, c])
    }

    func testOrderIsPersistedAndReloaded() async {
        let vm1 = NotesViewModel(store: store)
        let a = vm1.notes[0].id
        vm1.addNote()
        let b = vm1.notes[0].id
        vm1.move(a, toIndex: 0)
        XCTAssertEqual(vm1.notes.map(\.id), [a, b])

        // Wait past the 150ms order-save debounce.
        try? await Task.sleep(for: .milliseconds(250))

        let vm2 = NotesViewModel(store: store)
        XCTAssertEqual(vm2.notes.map(\.id), [a, b])
    }

    func testPreviewModeIsRetainedEvenForPlainText() {
        let vm = NotesViewModel(store: store)
        vm.addNote()
        let id = vm.selectedID
        vm.updateBody(of: id, to: "plain text")
        vm.setMode(.preview, for: id)
        XCTAssertEqual(vm.mode(of: id), .preview)
    }
}
