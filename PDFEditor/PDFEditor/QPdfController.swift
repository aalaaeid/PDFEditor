//
//  QPdfController.swift
//  PDFEditor
//
//  Created by Alaa on 11/03/2024.
//

import UIKit
import PDFKit

enum SelectedColor {
    case red
    case blue
    case black
    case green
}

class QPdfController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var colorsPalate: UIStackView!
    @IBOutlet weak var annotationView: DrawSignatureView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous

        if let fileURL = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: fileURL)
        }
        
        view.bringSubviewToFront(colorsPalate)
        pdfView.bringSubviewToFront(annotationView)
        
        annotationView.delegate = self
        annotationView.strokeColor = .blue
     
    }
    
    @IBAction func colorButtonTapped(_ sender: Any) {
       
        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 1
        }
    }
    @IBAction func penTapped(_ sender: Any) {
        annotationView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func handTapped(_ sender: Any) {
        annotationView.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func blueTapped(_ sender: Any) {
        handleColorSelectionWith(color: .blue)
    }
    
    @IBAction func redTapped(_ sender: Any) {
        handleColorSelectionWith(color: .red)
    }
    @IBAction func greenTapped(_ sender: Any) {
        handleColorSelectionWith(color: .green)
    }
    @IBAction func blackTapped(_ sender: Any) {
 
        handleColorSelectionWith(color: .black)
    }
    @IBAction func eraseTapped(_ sender: Any) {
        annotationView.clear()
    }
    
    
    func handleColorSelectionWith(color: SelectedColor) {
        
        switch color {
        case .red:
            colorButton.backgroundColor = .red
            annotationView.strokeColor = .red

        case .blue:
            colorButton.backgroundColor = .blue
            annotationView.strokeColor = .blue

        case .black:
            colorButton.backgroundColor = .black
            annotationView.strokeColor = .black

        case .green:
            colorButton.backgroundColor = .green
            annotationView.strokeColor = .green
        }

        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 0
        }
    }
    



}


extension QPdfController: SignatureDelegate {
    func didStart() {
        print("didStart 🎃")
    }
    
    func didFinish(_ view: DrawSignatureView) {
        print("didFinish")
    }
    
    func startedDrawing() {
        print("startedDrawing")
    }
    
    func finishedDrawing() {
        print("finishedDrawing")
    }
    
    
}
