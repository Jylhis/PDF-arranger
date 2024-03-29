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
    
    var modified = false
    
    var selectedPage : Int? = nil
    
    var document: UIDocument?
    
    @IBAction func RemovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        let alert = UIAlertController(title: "Are you sure?", message: "Remove page number \(pageNumber+1)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.pdfView.document?.removePage(at: pageNumber)
            self.pdfView.layoutDocumentView()
            self.modified = true
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // TODO
    @IBAction func MovePressed(_ sender: UIBarButtonItem) {
        let currentPage = self.pdfView.currentPage
        let pageNumber = pdfView.document!.index(for: currentPage!)
        
        let alert = UIAlertController(title: "Choose page", message: "", preferredStyle: .alert)
        
        // TODO: korjaa pickerillä
       // alert.addTextField { (destinationPage) in
         //   destinationPage.keyboardType = .numberPad
         //   destinationPage.text = "\(pageNumber+1)"
        //}
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 150)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(pageNumber, inComponent: 0, animated: true)
        self.selectedPage = pageNumber
        
        vc.view.addSubview(pickerView)
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [] (_) in
            let destinationPageIndex =  self.selectedPage ?? pageNumber//Int((alert?.textFields![0].text)!)!-1
            
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
            self.modified = true
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PressedSave(_ sender: UIBarButtonItem) {
        
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = self.document!.fileURL.lastPathComponent
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        print(temporaryFileURL.path)  // /Users/lsd/Library/Developer/XCPGDevices/E2003834-07AB-4833-B206-843DC0A52967/data/Containers/Data/Application/322D1F1D-4C97-474C-9040-FE5E740D38CF/tmp/document.pdf
        do {
            try self.pdfView.document?.dataRepresentation()?.write(to: temporaryFileURL)
            // your code
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            present(activityViewController, animated: true) {
                self.modified = false
            }
            
            if let popOver = activityViewController.popoverPresentationController {
                //popOver.sourceView = self.view
                //popOver.sourceRect =
                popOver.barButtonItem = sender
            }
        } catch {
            print(error)
        }
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
        if self.modified {
            let alert = UIAlertController(title: "Are you sure?", message: "All modfications will be lost", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [] (_) in
                self.dismiss(animated: true) {
                    self.document?.close(completionHandler: nil)
                }
                }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true) {
                self.document?.close(completionHandler: nil)
            }
        }
        
       
    }
}

extension DocumentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pdfView.document!.pageCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return String(row+1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedPage = row
        print(row)
    }
    
}
