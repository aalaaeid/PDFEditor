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
    @IBOutlet weak var thumbnailView: PDFThumbnailView!

    private let pdfDrawer = PDFDrawer()
    let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

      
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawingGestureRecognizer.isEnabled = false
        pdfDrawer.pdfView = pdfView
        pdfDrawer.drawingTool = .pen
        
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true)
        if let fileURL = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: fileURL)
        }
        
        view.bringSubviewToFront(colorsPalate)
 
        
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)
        thumbnailView.layoutMode = .horizontal
        thumbnailView.backgroundColor = .lightGray
        
    }
    


    @IBAction func colorButtonTapped(_ sender: Any) {
       
        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 1
        }
    }
    
    @IBAction func penTapped(_ sender: Any) {       
        pdfDrawer.drawingTool = .pen
        pdfDrawingGestureRecognizer.isEnabled = true
  
    }
    
    @IBAction func handTapped(_ sender: Any) {
        pdfDrawingGestureRecognizer.isEnabled = false
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
        pdfDrawer.drawingTool = .eraser


    }
    
    @IBAction func confirmSignatureTapped(_ sender: Any) {
        
        let data = pdfView.document?.dataRepresentation()
                    
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print(documentDirectory.absoluteString)
            let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
            
            do{
                try data?.write(to: docURL, options: [.atomic, .completeFileProtection])

            }catch(let error){
                print("error is \(error.localizedDescription)")
            }
        }
        pdfDrawingGestureRecognizer.isEnabled = false
    }
    
    @IBAction func dismissSignatureTapped(_ sender: Any) {
        if let fileURL = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: fileURL)
        }
        //this line for reloading thumbnailView to remove all drawings
        thumbnailView.pdfView = pdfView
    }
    
    
    func handleColorSelectionWith(color: SelectedColor) {
        
        switch color {
        case .red:
            colorButton.backgroundColor = .red
            pdfDrawer.color = .red

        case .blue:
            colorButton.backgroundColor = .blue
            pdfDrawer.color = .blue

        case .black:
            colorButton.backgroundColor = .black
            pdfDrawer.color = .black

        case .green:
            colorButton.backgroundColor = .green
            pdfDrawer.color = .green
        }

        UIView.animate(withDuration: 0.25) {
            self.colorsPalate.alpha = 0
        }
    }
    


    
}




