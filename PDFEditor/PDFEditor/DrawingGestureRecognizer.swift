//
//  DrawingGestureRecognizer.swift
//  PDFEditor
//
//  Created by Alaa on 20/03/2024.
//


import Foundation
import UIKit

protocol SignatureDelegate: AnyObject {
    func touchesDidStart(_ location: CGPoint)
    func touchesDidFinish(_ location: CGPoint)
    func toucheStartedDrawing(_ location: CGPoint)
}

class DrawingGestureRecognizer: UIGestureRecognizer {
    weak var drawingDelegate: SignatureDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            // touch.type == .pencil, // Uncomment this line to test on device with Apple Pencil
            let numberOfTouches = event?.allTouches?.count,
            numberOfTouches == 1 {
            state = .began
            
            let location = touch.location(in: self.view)
            drawingDelegate?.touchesDidStart(location)
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        drawingDelegate?.toucheStartedDrawing(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return
        }
        drawingDelegate?.touchesDidFinish(location)
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}
