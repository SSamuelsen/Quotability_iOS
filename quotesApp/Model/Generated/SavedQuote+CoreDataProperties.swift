//
//  SavedQuote+CoreDataProperties.swift
//  quotesApp
//
//  Created by Stephen Samuelsen on 3/21/18.
//  Copyright © 2018 Unplugged Apps LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedQuote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedQuote> {
        return NSFetchRequest<SavedQuote>(entityName: "SavedQuote")
    }

    @NSManaged public var author: String?
    @NSManaged public var quote: String?

}
