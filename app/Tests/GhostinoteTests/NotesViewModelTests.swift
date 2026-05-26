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
}
