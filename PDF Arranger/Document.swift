//
//  Document.swift
//  PDF Arranger
//
//  Created by Markus Jylhänkangas on 01/06/2019.
//  Copyright © 2019 Markus Jylhänkangas. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

