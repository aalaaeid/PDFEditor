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
    @IBOutlet weak var annotationView: UIView!
    
    var selectedColor:UIColor = .blue
    
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
     
    }
    
    @IBAction func colorButtonTapped(_ sender: Any) {
       
        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 1
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
    
    
    func handleColorSelectionWith(color: SelectedColor) {
        
        switch color {
        case .red:
            colorButton.backgroundColor = .red
            selectedColor = .red

        case .blue:
            colorButton.backgroundColor = .blue
            selectedColor = .blue

        case .black:
            colorButton.backgroundColor = .black
            selectedColor = .black

        case .green:
            colorButton.backgroundColor = .green
            selectedColor = .green
        }

        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 0
        }
    }
    



}
