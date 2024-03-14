//
//  DrawSignatureView.swift
//  PDFEditor
//
//  Created by Alaa on 12/03/2024.
//

import UIKit
import CoreGraphics
import PDFKit
import Combine

@IBDesignable
final public class DrawSignatureView: UIView {
    
    weak var delegate: SignatureDelegate?
    
    
    // MARK: - properties
    fileprivate var path = UIBezierPath()
    fileprivate var points = [CGPoint](repeating: CGPoint(), count: 5)
    fileprivate var controlPoint = 0
    fileprivate var touchPointTracker: PassthroughSubject<CGPoint, Never> = .init()
    fileprivate var bag: Set<AnyCancellable> = []

    
    // MARK: - Public properties
    @IBInspectable public var strokeWidth: CGFloat = 2.0 {
        didSet {
            path.lineWidth = strokeWidth
        }
    }
    
    @IBInspectable public var strokeColor: UIColor = .black {
        didSet {
            strokeColor.setStroke()
        }
    }
    
    // Computed Property returns true if the view actually contains a signature
    public var doesContainSignature: Bool {
        get {
            if path.isEmpty {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: - Init
       required public init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)

           path.lineWidth = strokeWidth
           path.lineJoinStyle = .round
           path.lineCapStyle = .round
       }

       override public init(frame: CGRect) {
           super.init(frame: frame)

           path.lineWidth = strokeWidth
           path.lineJoinStyle = .round
           path.lineCapStyle = .round
       }

       // MARK: - Draw
       override public func draw(_ rect: CGRect) {
           self.strokeColor.setStroke()
           self.path.stroke()
       }


    
    // MARK: - Touch handling functions
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didStart()

        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            controlPoint = 0
            points[0] = touchPoint
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            controlPoint += 1
            points[controlPoint] = touchPoint
            if (controlPoint == 4) {
                points[3] = CGPoint(x: (points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y)/2.0)
                path.move(to: points[0])
                path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])

                setNeedsDisplay()
                points[0] = points[3]
                points[1] = points[4]
                controlPoint = 1
            }

            setNeedsDisplay()
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didFinish(self)

        if controlPoint < 4 {
            let touchPoint = points[0]
            path.move(to: CGPoint(x: touchPoint.x, y: touchPoint.y))
            path.addLine(to: CGPoint(x: touchPoint.x, y: touchPoint.y))
            touchPointTracker.send(touchPoint)
            setNeedsDisplay()
        } else {
            controlPoint = 0
        }
    }
    
    
    // MARK: - Methods for interacting with Signature View

 
    public func clear() {
        self.path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    public func getSignature(scale: CGFloat = 1) -> UIImage? {
        if !doesContainSignature { return nil }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        self.strokeColor.setStroke()
        self.path.stroke()
        let signature = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return signature
    }

    public func getCroppedSignature(scale: CGFloat = 1) -> UIImage? {
        guard let fullRender = getSignature(scale: scale) else { return nil }
        let bounds = self.scale(path.bounds.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2), byFactor: scale)
        guard let imageRef = fullRender.cgImage?.cropping(to: bounds) else { return nil }
        return UIImage(cgImage: imageRef)
    }

    fileprivate func scale(_ rect: CGRect, byFactor factor: CGFloat) -> CGRect {
        var scaledRect = rect
        scaledRect.origin.x *= factor
        scaledRect.origin.y *= factor
        scaledRect.size.width *= factor
        scaledRect.size.height *= factor
        return scaledRect
    }

    
    public func drawSignature(on page: PDFPage) {
        var rect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        
        let annotation = PDFAnnotation(bounds: rect, forType: .ink, withProperties: nil)
        
        annotation.color = strokeColor
        
        touchPointTracker.receive(on: RunLoop.main)
            .sink { [weak self] touchPoint in
                guard let self = self else { return }
                
                path.move(to: CGPoint(x: touchPoint.x, y: touchPoint.y))
                path.addLine(to: CGPoint(x: touchPoint.x, y: touchPoint.y))
                
            }.store(in: &bag)
        
        
        // Add the annotation to the page
        annotation.add(path)
        page.addAnnotation(annotation)
    }
    

    
    func drawOnPDF(cgPDFDucomunt:CGPDFDocument ,pageIndex:Int) -> Data? {
     
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
         
         if index == pageIndex {
             let image = getSignature() ?? UIImage()
             var newRectImage: CGRect?
             
             newRectImage =
             CGRect(x: 0, y: ((pageFrame?.height)!) - bounds.height ,
                                   width: bounds.width,
                                   height: bounds.height)
             
             if let newRectImage = newRectImage{
                 image.draw(in: newRectImage)
             }
       
         }
         
     }
   
     UIGraphicsEndPDFContext()
     
     let pdfData = mutableData as Data
         
     return pdfData

    }

    
}

// MARK: - Protocol definition for DrawSignatureViewDelegate
@objc
protocol SignatureDelegate: AnyObject {
    func didStart()
    func didFinish(_ view: DrawSignatureView)
    func startedDrawing()
    func finishedDrawing()
}
