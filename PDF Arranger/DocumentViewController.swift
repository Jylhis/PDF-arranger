//
//  DocumentViewController.swift
//  PDF Arranger
//
//  Created by Markus Jylhänkangas on 01/06/2019.
//  Copyright © 2019 Markus Jylhänkangas. All rights reserved.
//

import UIKit
import PDFKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.absoluteString
                
               // if let path = Bundle.main.path(forResource: self.document?.fileURL.lastPathComponent, ofType: "pdf") {
                let url = URL(fileURLWithPath: (self.document?.fileURL.absoluteString)!)
                    if let pdfDocument = PDFDocument(url: url) {
                        self.pdfView.displayMode = .singlePageContinuous
                        self.pdfView.autoScales = true
                        // pdfView.displayDirection = .horizontal
                        self.pdfView.document = pdfDocument
                    }
                //}
                
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
