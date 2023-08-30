//
//  Place.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 12/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Place : NSManagedObject {
    @NSManaged var name : String
    @NSManaged var type : String
    @NSManaged var location : String
    @NSManaged var telephone : String?
    @NSManaged var website : String?
    @NSManaged var image : NSData?
    @NSManaged var rating : String?
   
    
}
