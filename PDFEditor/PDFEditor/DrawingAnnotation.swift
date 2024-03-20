//
//  DrawingAnnotation.swift
//  PDFEditor
//
//  Created by Alaa on 20/03/2024.
//

import Foundation
import PDFKit

class DrawingAnnotation: PDFAnnotation {
    public var path = UIBezierPath()
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        let pathCopy = path.copy() as! UIBezierPath
        UIGraphicsPushContext(context)
        context.saveGState()
        
        context.setShouldAntialias(true)
        
        color.set()
        pathCopy.lineJoinStyle = .round
        pathCopy.lineCapStyle = .round
        pathCopy.lineWidth = border?.lineWidth ?? 2.0
        pathCopy.stroke()
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}
