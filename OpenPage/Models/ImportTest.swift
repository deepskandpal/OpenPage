import Foundation
import SwiftData

// This file is just to test imports and circular dependencies
struct ImportTest {
    func testImports() {
        let document = Document()
        let project = Project(name: "Test")
        let section = DocumentSection(title: "Test")
        
        print("Document: \(document)")
        print("Project: \(project)")
        print("Section: \(section)")
    }
} 