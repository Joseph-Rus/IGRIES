import UIKit
import SwiftUI
import UniformTypeIdentifiers

func createPDF(from text: String, email: String, detailedNotes: String) -> Data {
    let pdfMetaData = [
        kCGPDFContextCreator: "Speech Note App",
        kCGPDFContextAuthor: email
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]
    
    let pageWidth: CGFloat = 612 // US Letter width in points
    let pageHeight: CGFloat = 792 // US Letter height in points
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    let margin: CGFloat = 20
    let usableWidth = pageWidth - (2 * margin)
    let maxY = pageHeight - margin // Bottom margin
    
    let charactersPerPage = 2500 // Limit per page as requested
    
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    let data = renderer.pdfData { context in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .natural
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        func drawText(_ text: String, at y: inout CGFloat, attributes: [NSAttributedString.Key: Any], context: UIGraphicsPDFRendererContext) {
            var remainingText = text
            var pageStart = 0
            
            while !remainingText.isEmpty {
                if y >= maxY {
                    context.beginPage()
                    y = margin
                }
                
                let chunkLength = min(charactersPerPage, remainingText.count)
                let chunk = String(remainingText.prefix(chunkLength))
                
                let attributedText = NSAttributedString(string: chunk, attributes: attributes)
                let textRect = CGRect(x: margin, y: y, width: usableWidth, height: .greatestFiniteMagnitude)
                let textHeight = attributedText.boundingRect(with: CGSize(width: usableWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).height
                
                attributedText.draw(in: textRect)
                y += textHeight
                
                remainingText = String(remainingText.dropFirst(chunkLength))
                pageStart += chunkLength
            }
        }
        
        // Combine all content into a single string for splitting
        let fullContent = """
        Detailed Notes
        From: \(email)
        
        Original Transcription:
        \(text)
        
        Structured Notes:
        \(detailedNotes)
        """
        
        var yOffset: CGFloat = margin
        context.beginPage() // Start the first page
        
        drawText(fullContent, at: &yOffset, attributes: bodyAttributes, context: context)
    }
    
    return data
}

struct PDFDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.featureUnsupported)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url)
    }
}
