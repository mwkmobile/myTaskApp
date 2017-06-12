//
//  Note.swift
//  myTaskApp
//
//  Created by Michael Koenig on 6/10/17.
//  Copyright © 2017 Michael Koenig. All rights reserved.
//


import Foundation
import CoreData

class Note: NSManagedObject {
  
  @NSManaged var noteText: String
  @NSManaged var date: Date
  
}
