import SwiftUI

// Helper view for tag layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > maxWidth {
                // Start a new row
                width = max(width, rowWidth)
                height += rowHeight + spacing
                rowWidth = viewSize.width
                rowHeight = viewSize.height
            } else {
                // Add to the current row
                rowWidth += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        // Add the last row
        height += rowHeight
        width = max(width, rowWidth)
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowStartIndex = 0
        
        for (index, view) in subviews.enumerated() {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > maxWidth && index > rowStartIndex {
                // Place previous row
                placeRow(from: rowStartIndex, to: index - 1, in: bounds, y: bounds.minY + rowHeight, subviews: subviews)
                
                // Start a new row
                rowStartIndex = index
                rowWidth = viewSize.width
                rowHeight += viewSize.height + spacing
            } else {
                // Add to the current row
                rowWidth += viewSize.width + spacing
            }
        }
        
        // Place the last row
        if rowStartIndex < subviews.count {
            placeRow(from: rowStartIndex, to: subviews.count - 1, in: bounds, y: bounds.minY + rowHeight, subviews: subviews)
        }
    }
    
    private func placeRow(from startIndex: Int, to endIndex: Int, in bounds: CGRect, y: CGFloat, subviews: Subviews) {
        var x = bounds.minX
        
        for i in startIndex...endIndex {
            let viewSize = subviews[i].sizeThatFits(.unspecified)
            subviews[i].place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += viewSize.width + spacing
        }
    }
} 