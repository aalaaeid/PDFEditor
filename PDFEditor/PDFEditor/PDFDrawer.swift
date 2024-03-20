//
//  PDFDrawer.swift
//  PDFEditor
//
//  Created by Alaa on 20/03/2024.
//

import Foundation
import PDFKit


enum DrawingTool: Int {
    case eraser = 0
    case pen = 1
    
}
class PDFDrawer {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    private var currentAnnotation : DrawingAnnotation?
    private var currentPage: PDFPage?
    var color = UIColor.blue // default color is blue
    var drawingTool = DrawingTool.pen
}


extension PDFDrawer: SignatureDelegate {
    
    func touchesDidStart(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
    }

    func toucheStartedDrawing(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        print(convertedPoint)
        
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: page)
    }
    
    
    func touchesDidFinish(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        // Erasing
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        // Drawing
        guard let _ = currentAnnotation else { return }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        
        // Final annotation
        page.removeAnnotation(currentAnnotation!)
        let finalAnnotation = createFinalAnnotation(path: path!, page: page)
        currentAnnotation = nil
    }
    
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = 2.0
        
        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        annotation.color = color
        annotation.border = border
        return annotation
    }
    

    
    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage)
        }
        
        currentAnnotation?.path = path
        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
        let border = PDFBorder()
        border.lineWidth = 2.0
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        var signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        signingPathCentered.moveCenter(to: bounds.center)
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = color
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
                
        return annotation
    }
    
    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        }
    }
    
    func renderPDF() -> Data? {
        guard let currentPageIndex = pdfView.currentPage?.pageRef?.pageNumber else { return nil }
       
        guard let cgPDFDucomunt = pdfView.document?.documentRef else { return nil }
        
       let pdf = cgPDFDucomunt
       
       let pageCount = pdf.numberOfPages
           
       let mutableData = NSMutableData()
       UIGraphicsBeginPDFContextToData(mutableData,CGRect.zero, nil)
       
       for index in 1...pageCount {
           
           let page =  pdf.page(at: index)
           
           let pageFrame = page?.getBoxRect(.mediaBox)
           
           UIGraphicsBeginPDFPageWithInfo(pageFrame!, nil)

           guard let ctx = UIGraphicsGetCurrentContext() else {return nil}
      
           ctx.saveGState()
           ctx.scaleBy(x: 1, y: -1)
           ctx.translateBy(x: 0, y: -pageFrame!.size.height)
           
           ctx.drawPDFPage(page!)
           ctx.restoreGState()
           
           if index == currentPageIndex {
//               let image = getSignature() ?? UIImage()
//               var newRectImage: CGRect?
//               
//               newRectImage =
//               CGRect(x: 0, y: ((pageFrame?.height)!) - bounds.height ,
//                                     width: bounds.width,
//                                     height: bounds.height)
//               
//               if let newRectImage = newRectImage{
//                   image.draw(in: newRectImage)
//               }
         
           }
           
       }
     
       UIGraphicsEndPDFContext()
       
       let pdfData = mutableData as Data
           
       return pdfData

      }
}


extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
                if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}

extension PDFAnnotation {
    
    func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        
        if let path = paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        }
        
        return hitPath?.contains(point) ?? false
    }
}
