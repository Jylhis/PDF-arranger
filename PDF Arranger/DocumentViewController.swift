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
    @IBOutlet weak var NavBar: UINavigationBar!
    
    
    var document: UIDocument?
    
    
    // TODO
    @IBAction func RemovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        let alert = UIAlertController(title: "Are you sure?", message: "Page number \(pageNumber)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.pdfView.document?.removePage(at: pageNumber)
            //self.pdfView.render
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // TODO
    @IBAction func MovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Where?", message: "Where do you want to move this pge?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = "\(pageNumber)"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = Int((alert?.textFields![0].text)!)// Force unwrapping because we know it exists.
            self.pdfView.document?.insert(currentPage!, at: textField!)
            //print("Text field: \(textField!.text)")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PressedSave(_ sender: UIBarButtonItem) {
        self.pdfView.document?.write(to: <#T##URL#>)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
          //      self.documentNameLabel.text = self.document?.fileURL.absoluteString
                
             //   if let path = Bundle.main.path(forResource: , ofType: "pdf") {
                //let url = URL(fileURLWithPath: self.document?.fileURL)
                self.NavBar.topItem?.title = self.document?.fileURL.lastPathComponent
                if let pdfDocument = PDFDocument(url: self.document!.fileURL) {
                        self.pdfView.displayMode = .singlePageContinuous
                        self.pdfView.autoScales = true
                        // pdfView.displayDirection = .horizontal
                        self.pdfView.document = pdfDocument
                    }
            //    }
                
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
