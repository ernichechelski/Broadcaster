//
//  Document.swift
//  Broadcaster
//
//  Created by Ernest Chechelski on 07/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
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

