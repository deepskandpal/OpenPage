import Foundation
import SwiftData

// MARK: - Project Template System
enum ProjectTemplateType: String, CaseIterable, Codable {
    case novel = "novel"
    case screenplay = "screenplay"
    case techBlog = "tech_blog"
    case researchPaper = "research_paper"
    case businessPlan = "business_plan"
    case shortStory = "short_story"
    case essay = "essay"
    case journal = "journal"
    case poetry = "poetry"
    case nonFiction = "non_fiction"
    
    var displayName: String {
        switch self {
        case .novel: return "Novel"
        case .screenplay: return "Screenplay"
        case .techBlog: return "Technical Blog"
        case .researchPaper: return "Research Paper"
        case .businessPlan: return "Business Plan"
        case .shortStory: return "Short Story"
        case .essay: return "Essay"
        case .journal: return "Journal"
        case .poetry: return "Poetry Collection"
        case .nonFiction: return "Non-Fiction Book"
        }
    }
    
    var description: String {
        switch self {
        case .novel:
            return "Full-length fiction with chapters, character development, and plot structure"
        case .screenplay:
            return "Script for film or TV with industry-standard formatting"
        case .techBlog:
            return "Technical articles with code examples and documentation"
        case .researchPaper:
            return "Academic paper with citations, methodology, and analysis"
        case .businessPlan:
            return "Comprehensive business planning document"
        case .shortStory:
            return "Short fiction piece with focused narrative"
        case .essay:
            return "Structured argumentative or analytical writing"
        case .journal:
            return "Personal writing and reflection space"
        case .poetry:
            return "Collection of poems with thematic organization"
        case .nonFiction:
            return "Factual book with chapters and research"
        }
    }
    
    var icon: String {
        switch self {
        case .novel: return "book.closed"
        case .screenplay: return "theatermasks"
        case .techBlog: return "code"
        case .researchPaper: return "doc.text.magnifyingglass"
        case .businessPlan: return "briefcase"
        case .shortStory: return "book.pages"
        case .essay: return "doc.richtext"
        case .journal: return "journal"
        case .poetry: return "quote.bubble"
        case .nonFiction: return "books.vertical"
        }
    }
    
    var color: String {
        switch self {
        case .novel: return "Blue"
        case .screenplay: return "Purple"
        case .techBlog: return "Green"
        case .researchPaper: return "Orange"
        case .businessPlan: return "Red"
        case .shortStory: return "Pink"
        case .essay: return "Yellow"
        case .journal: return "Teal"
        case .poetry: return "Purple"
        case .nonFiction: return "Blue"
        }
    }
    
    var defaultTags: [String] {
        switch self {
        case .novel:
            return ["Fiction", "Novel", "Creative Writing"]
        case .screenplay:
            return ["Screenplay", "Script", "Film", "TV"]
        case .techBlog:
            return ["Technical", "Blog", "Programming", "Tutorial"]
        case .researchPaper:
            return ["Research", "Academic", "Paper", "Analysis"]
        case .businessPlan:
            return ["Business", "Planning", "Strategy", "Professional"]
        case .shortStory:
            return ["Fiction", "Short Story", "Creative Writing"]
        case .essay:
            return ["Essay", "Academic", "Analysis", "Writing"]
        case .journal:
            return ["Journal", "Personal", "Reflection", "Daily"]
        case .poetry:
            return ["Poetry", "Creative Writing", "Literature"]
        case .nonFiction:
            return ["Non-Fiction", "Book", "Educational", "Informative"]
        }
    }
    
    var writingTaskType: WritingTaskType {
        switch self {
        case .novel, .shortStory, .poetry:
            return .creative
        case .screenplay:
            return .creative
        case .techBlog:
            return .technical
        case .researchPaper:
            return .analysis
        case .businessPlan:
            return .technical
        case .essay:
            return .analysis
        case .journal:
            return .creative
        case .nonFiction:
            return .analysis
        }
    }
}

// MARK: - Project Template Structure
struct ProjectTemplate {
    let type: ProjectTemplateType
    let sections: [DocumentSectionTemplate]
    
    var name: String { type.displayName }
    var description: String { type.description }
    var icon: String { type.icon }
    var color: String { type.color }
    var tags: [String] { type.defaultTags }
    var writingTaskType: WritingTaskType { type.writingTaskType }
}

struct DocumentSectionTemplate {
    let title: String
    let content: String
    let type: String
    let isContainer: Bool
    let children: [DocumentSectionTemplate]
    let placeholder: String?
    let instructions: String?
    
    init(
        title: String,
        content: String = "",
        type: String = "text",
        isContainer: Bool = false,
        children: [DocumentSectionTemplate] = [],
        placeholder: String? = nil,
        instructions: String? = nil
    ) {
        self.title = title
        self.content = content
        self.type = type
        self.isContainer = isContainer
        self.children = children
        self.placeholder = placeholder
        self.instructions = instructions
    }
}

// MARK: - Template Factory
class ProjectTemplateFactory {
    static func createTemplate(for type: ProjectTemplateType) -> ProjectTemplate {
        switch type {
        case .novel:
            return createNovelTemplate()
        case .screenplay:
            return createScreenplayTemplate()
        case .techBlog:
            return createTechBlogTemplate()
        case .researchPaper:
            return createResearchPaperTemplate()
        case .businessPlan:
            return createBusinessPlanTemplate()
        case .shortStory:
            return createShortStoryTemplate()
        case .essay:
            return createEssayTemplate()
        case .journal:
            return createJournalTemplate()
        case .poetry:
            return createPoetryTemplate()
        case .nonFiction:
            return createNonFictionTemplate()
        }
    }
    
    static func createProject(from template: ProjectTemplate, name: String, modelContext: ModelContext) -> Project {
        let project = Project(
            name: name,
            projectDescription: template.description,
            color: template.color,
            icon: template.icon,
            tags: template.tags
        )
        
        // Create the main document with hierarchical structure
        let document = Document(
            title: name,
            templateType: template.type.rawValue
        )
        
        // Convert template to hierarchical structure
        if !template.sections.isEmpty {
            document.convertToHierarchical()
            if let rootSection = document.rootSection {
                for sectionTemplate in template.sections {
                    let section = createSection(from: sectionTemplate, document: document)
                    rootSection.addChild(section)
                }
            }
        }
        
        project.addDocument(document)
        modelContext.insert(project)
        
        return project
    }
    
    private static func createSection(from template: DocumentSectionTemplate, document: Document) -> DocumentSection {
        let section = DocumentSection(
            title: template.title,
            content: template.content,
            type: template.type,
            isContainer: template.isContainer
        )
        
        // Add children recursively
        for childTemplate in template.children {
            let childSection = createSection(from: childTemplate, document: document)
            section.addChild(childSection)
        }
        
        return section
    }
}

// MARK: - Template Definitions
private extension ProjectTemplateFactory {
    static func createNovelTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .novel,
            sections: [
                DocumentSectionTemplate(
                    title: "Planning",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "Plot Outline",
                            placeholder: "Describe your main plot points, story arc, and key events...",
                            instructions: "Outline the major plot points and story structure"
                        ),
                        DocumentSectionTemplate(
                            title: "Characters",
                            placeholder: "Create character profiles for your main characters...",
                            instructions: "Develop your main characters with backgrounds, motivations, and arcs"
                        ),
                        DocumentSectionTemplate(
                            title: "World Building",
                            placeholder: "Describe the setting, world, and environment of your story...",
                            instructions: "Build the world where your story takes place"
                        ),
                        DocumentSectionTemplate(
                            title: "Themes",
                            placeholder: "What themes and messages will your novel explore?",
                            instructions: "Identify the central themes and messages"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Manuscript",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "Chapter 1",
                            placeholder: "Begin your story here...",
                            instructions: "Write your opening chapter - hook the reader immediately"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Research Notes",
                    placeholder: "Keep track of research, references, and fact-checking...",
                    instructions: "Document any research needed for your novel"
                )
            ]
        )
    }
    
    static func createScreenplayTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .screenplay,
            sections: [
                DocumentSectionTemplate(
                    title: "Logline",
                    placeholder: "One sentence description of your screenplay...",
                    instructions: "Write a compelling logline that captures the essence of your story"
                ),
                DocumentSectionTemplate(
                    title: "Treatment",
                    placeholder: "2-3 page prose summary of your screenplay...",
                    instructions: "Write a detailed treatment covering the entire story"
                ),
                DocumentSectionTemplate(
                    title: "Character List",
                    placeholder: "Main characters and their descriptions...",
                    instructions: "List and describe your main characters"
                ),
                DocumentSectionTemplate(
                    title: "Script",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "Act I",
                            placeholder: "FADE IN:\n\nEXT. LOCATION - TIME\n\nDescription of the scene...",
                            instructions: "Write Act I following screenplay format"
                        )
                    ]
                )
            ]
        )
    }
    
    static func createTechBlogTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .techBlog,
            sections: [
                DocumentSectionTemplate(
                    title: "Article Ideas",
                    placeholder: "List potential topics and angles...",
                    instructions: "Brainstorm article ideas and keep track of topics to cover"
                ),
                DocumentSectionTemplate(
                    title: "Posts",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "First Post",
                            content: "# Title\n\n## Introduction\n\n## Main Content\n\n## Code Examples\n\n```language\n// Your code here\n```\n\n## Conclusion\n\n",
                            placeholder: "Write your technical blog post...",
                            instructions: "Structure your post with clear headings and code examples"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Research & References",
                    placeholder: "Keep track of technical resources, documentation, and references...",
                    instructions: "Document sources, APIs, libraries, and technical references"
                )
            ]
        )
    }
    
    static func createResearchPaperTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .researchPaper,
            sections: [
                DocumentSectionTemplate(
                    title: "Abstract",
                    placeholder: "Brief summary of your research question, methodology, and findings...",
                    instructions: "Write a concise abstract (150-250 words)"
                ),
                DocumentSectionTemplate(
                    title: "Introduction",
                    placeholder: "Introduce your research topic and question...",
                    instructions: "Present the research problem and its significance"
                ),
                DocumentSectionTemplate(
                    title: "Literature Review",
                    placeholder: "Review existing research and scholarship on your topic...",
                    instructions: "Analyze and synthesize relevant academic sources"
                ),
                DocumentSectionTemplate(
                    title: "Methodology",
                    placeholder: "Describe your research methods and approach...",
                    instructions: "Explain how you conducted your research"
                ),
                DocumentSectionTemplate(
                    title: "Results/Analysis",
                    placeholder: "Present your findings and analysis...",
                    instructions: "Share your research results and interpret them"
                ),
                DocumentSectionTemplate(
                    title: "Conclusion",
                    placeholder: "Summarize findings and suggest future research...",
                    instructions: "Conclude with implications and future directions"
                ),
                DocumentSectionTemplate(
                    title: "Bibliography",
                    placeholder: "List all sources in proper citation format...",
                    instructions: "Include all references in required citation style"
                )
            ]
        )
    }
    
    static func createBusinessPlanTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .businessPlan,
            sections: [
                DocumentSectionTemplate(
                    title: "Executive Summary",
                    placeholder: "Brief overview of your business concept...",
                    instructions: "Summarize your business plan in 1-2 pages"
                ),
                DocumentSectionTemplate(
                    title: "Market Analysis",
                    placeholder: "Research your target market and competition...",
                    instructions: "Analyze market size, trends, and competitive landscape"
                ),
                DocumentSectionTemplate(
                    title: "Business Model",
                    placeholder: "Describe how your business will operate and make money...",
                    instructions: "Explain your value proposition and revenue streams"
                ),
                DocumentSectionTemplate(
                    title: "Financial Projections",
                    placeholder: "Include revenue forecasts, expenses, and funding needs...",
                    instructions: "Provide detailed financial projections and assumptions"
                )
            ]
        )
    }
    
    static func createShortStoryTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .shortStory,
            sections: [
                DocumentSectionTemplate(
                    title: "Story Concept",
                    placeholder: "What's the central idea or conflict of your story?",
                    instructions: "Define the core concept and conflict"
                ),
                DocumentSectionTemplate(
                    title: "Character Notes",
                    placeholder: "Brief notes about your main characters...",
                    instructions: "Develop key characters for your short story"
                ),
                DocumentSectionTemplate(
                    title: "Story",
                    placeholder: "Begin your short story here...",
                    instructions: "Write your complete short story"
                )
            ]
        )
    }
    
    static func createEssayTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .essay,
            sections: [
                DocumentSectionTemplate(
                    title: "Thesis & Outline",
                    placeholder: "State your thesis and outline main arguments...",
                    instructions: "Develop a strong thesis statement and essay structure"
                ),
                DocumentSectionTemplate(
                    title: "Essay Draft",
                    content: "# Essay Title\n\n## Introduction\n\n## Body Paragraph 1\n\n## Body Paragraph 2\n\n## Body Paragraph 3\n\n## Conclusion\n\n",
                    placeholder: "Write your essay...",
                    instructions: "Follow standard essay structure with introduction, body, and conclusion"
                ),
                DocumentSectionTemplate(
                    title: "Sources & Citations",
                    placeholder: "Keep track of sources and citations...",
                    instructions: "Document all sources used in your essay"
                )
            ]
        )
    }
    
    static func createJournalTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .journal,
            sections: [
                DocumentSectionTemplate(
                    title: "Daily Entries",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "Today's Entry",
                            placeholder: "Write about your day, thoughts, and reflections...",
                            instructions: "Use this space for daily reflection and personal writing"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Goals & Reflections",
                    placeholder: "Set goals and reflect on your progress...",
                    instructions: "Track personal goals and long-term reflections"
                )
            ]
        )
    }
    
    static func createPoetryTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .poetry,
            sections: [
                DocumentSectionTemplate(
                    title: "Poems",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "First Poem",
                            placeholder: "Write your poem here...",
                            instructions: "Create your poetry with attention to rhythm and imagery"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Ideas & Inspiration",
                    placeholder: "Collect ideas, phrases, and inspiration for poems...",
                    instructions: "Keep a collection of ideas and inspiration"
                )
            ]
        )
    }
    
    static func createNonFictionTemplate() -> ProjectTemplate {
        return ProjectTemplate(
            type: .nonFiction,
            sections: [
                DocumentSectionTemplate(
                    title: "Book Proposal",
                    placeholder: "Describe your book concept, audience, and outline...",
                    instructions: "Develop a comprehensive book proposal"
                ),
                DocumentSectionTemplate(
                    title: "Chapters",
                    type: "folder",
                    isContainer: true,
                    children: [
                        DocumentSectionTemplate(
                            title: "Chapter 1",
                            placeholder: "Begin your first chapter...",
                            instructions: "Write engaging, informative content for your readers"
                        )
                    ]
                ),
                DocumentSectionTemplate(
                    title: "Research & Sources",
                    placeholder: "Keep track of research, interviews, and sources...",
                    instructions: "Document all research and fact-checking materials"
                )
            ]
        )
    }
}