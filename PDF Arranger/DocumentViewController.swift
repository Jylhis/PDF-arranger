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
    
    @IBAction func RemovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        let alert = UIAlertController(title: "Are you sure?", message: "Remove page number \(pageNumber+1)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.pdfView.document?.removePage(at: pageNumber)
            self.pdfView.layoutDocumentView()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // TODO
    @IBAction func MovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        
        let alert = UIAlertController(title: "Where?", message: "Where do you want to move this pge?", preferredStyle: .alert)
        
        // TODO: korjaa pickerillä
        alert.addTextField { (destinationPage) in
            destinationPage.keyboardType = .numberPad
            destinationPage.text = "\(pageNumber+1)"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let destinationPageIndex = Int((alert?.textFields![0].text)!)!-1
            
            if(destinationPageIndex != pageNumber && destinationPageIndex < self.pdfView.document!.pageCount) {
                self.pdfView.document?.removePage(at: pageNumber)
                
                // Looppaa kaikki sivut ja siirrä niitä yksi pykälä
                // Looppaa alhaalta ylös
                for page in (destinationPageIndex...self.pdfView.document!.pageCount).reversed() {
                    let workingPageIndex = page != 0 ? page-1 : page
                    self.pdfView.document?.insert(self.pdfView.document!.page(at: workingPageIndex)!, at: page)
                    self.pdfView.document?.removePage(at: workingPageIndex)
                }
                
                // laita kohde sivu kohteeseen
                self.pdfView.document?.insert(currentPage!, at: destinationPageIndex)
                
                // Jos siirtää sivuja niin sivujen väliin jää tyhjää tilaa
                // tämä väsäys päivittää koko näkymän
                let newDoc = PDFDocument(data: self.pdfView.document!.dataRepresentation()!)
                self.pdfView.document = newDoc
                
                // Hypää uuden sivun kohdalle
                self.pdfView.go(to: self.pdfView.document!.page(at: destinationPageIndex)!)
            }
            
            self.pdfView.layoutDocumentView()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PressedSave(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: ["Name To Present to User", self.pdfView.document!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                
                self.NavBar.topItem?.title = self.document?.fileURL.lastPathComponent
                if let pdfDocument = PDFDocument(url: self.document!.fileURL) {
                    self.pdfView.displayMode = .singlePageContinuous
                    self.pdfView.autoScales = true
                    self.pdfView.document = pdfDocument
                    self.pdfView.autoScales = true
                }
            } else {
                // TODO
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
