import SwiftUI

struct TemplateSelectionView: View {
    @Binding var selectedTemplate: DocumentTemplate
    @State private var searchText = ""
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search templates", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Template grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)], spacing: 16) {
                    ForEach(filteredTemplates) { template in
                        TemplateCard(
                            template: template,
                            isSelected: template.id == selectedTemplate.id,
                            namespace: animation
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedTemplate = template
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private var filteredTemplates: [DocumentTemplate] {
        if searchText.isEmpty {
            return DocumentTemplate.allTemplates
        } else {
            return DocumentTemplate.allTemplates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText) ||
                template.suggestedTags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

struct TemplateCard: View {
    let template: DocumentTemplate
    let isSelected: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Template icon and title
            HStack {
                Image(systemName: template.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .matchedGeometryEffect(id: "checkmark", in: namespace)
                }
            }
            
            // Template name
            Text(template.name)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            // Template description
            Text(template.description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(2)
            
            Spacer()
            
            // Template tags
            if !template.suggestedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(template.suggestedTags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isSelected ? Color.white.opacity(0.2) : Color.accentColor.opacity(0.1))
                                )
                                .foregroundColor(isSelected ? .white : .accentColor)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                .shadow(color: isSelected ? Color.accentColor.opacity(0.6) : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: 2)
        )
    }
}

struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateSelectionView(selectedTemplate: .constant(DocumentTemplate.novel))
    }
} 