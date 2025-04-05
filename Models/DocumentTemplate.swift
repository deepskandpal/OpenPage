import Foundation
import SwiftUI

// Template structure for different document types
struct DocumentTemplate: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var icon: String
    var initialContent: String
    var suggestedTags: [String]
    var defaultFontName: String
    var defaultFontSize: Double
    
    // Default templates
    static let empty = DocumentTemplate(
        name: "Blank Document",
        description: "Start with a clean slate",
        icon: "doc",
        initialContent: "",
        suggestedTags: [],
        defaultFontName: "",
        defaultFontSize: 0
    )
    
    static let screenplay = DocumentTemplate(
        name: "Screenplay",
        description: "Standard screenplay format with scene headings",
        icon: "film",
        initialContent: """
        # TITLE
        
        Written by
        
        YOUR NAME HERE
        
        ## FADE IN:
        
        ### INT. LOCATION - DAY
        
        Character description and scene setting.
        
        CHARACTER NAME
            (parenthetical)
            Dialogue goes here.
        
        ### CUT TO:
        """,
        suggestedTags: ["screenplay", "script", "film"],
        defaultFontName: "Courier",
        defaultFontSize: 12.0
    )
    
    static let novel = DocumentTemplate(
        name: "Novel Chapter",
        description: "Novel format with chapter heading",
        icon: "book",
        initialContent: """
        # Chapter 1
        
        Begin your story here. The first paragraph should set the scene and draw your reader in.
        
        Continue developing your narrative. Remember to show, not tell.
        
        ## Scene Break
        
        Use these to separate different scenes within your chapter.
        """,
        suggestedTags: ["novel", "fiction", "chapter"],
        defaultFontName: "Times New Roman",
        defaultFontSize: 12.0
    )
    
    static let blogPost = DocumentTemplate(
        name: "Blog Post",
        description: "Structure for online articles",
        icon: "text.quote",
        initialContent: """
        # Compelling Headline Goes Here
        
        ## Introduction
        
        Hook your readers with an engaging opening that presents the problem or situation.
        
        ## Main Point 1
        
        Support your argument with evidence and examples.
        
        ## Main Point 2
        
        Continue building your case with additional information.
        
        ## Main Point 3
        
        Provide your third key point.
        
        ## Conclusion
        
        Summarize your main points and provide a call to action.
        """,
        suggestedTags: ["blog", "article", "web"],
        defaultFontName: "Helvetica",
        defaultFontSize: 12.0
    )
    
    static let academicPaper = DocumentTemplate(
        name: "Academic Paper",
        description: "Formal academic paper structure",
        icon: "doc.text.magnifyingglass",
        initialContent: """
        # Title of Your Research Paper
        
        ## Abstract
        
        Summarize your research question, methods, results, and conclusions here.
        
        ## Introduction
        
        Introduce the topic and provide context for your research question.
        
        ## Literature Review
        
        Summarize relevant existing research on your topic.
        
        ## Methodology
        
        Describe how you conducted your research.
        
        ## Results
        
        Present your findings.
        
        ## Discussion
        
        Interpret your results and discuss their implications.
        
        ## Conclusion
        
        Summarize your findings and suggest directions for future research.
        
        ## References
        
        List your sources here.
        """,
        suggestedTags: ["academic", "research", "paper"],
        defaultFontName: "Times New Roman",
        defaultFontSize: 12.0
    )
    
    // All available templates
    static let allTemplates: [DocumentTemplate] = [
        .empty,
        .screenplay,
        .novel,
        .blogPost,
        .academicPaper
    ]
    
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DocumentTemplate, rhs: DocumentTemplate) -> Bool {
        lhs.id == rhs.id
    }
} 