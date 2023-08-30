//
//  TutorialStep.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 18/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import Foundation
import UIKit

class TutorialStep: NSObject {
    
    var index = 0
    var heading = ""
    var content = ""
    var image: UIImage!
    
    init(index: Int, heading: String, content: String, image: UIImage) {
        self.index = index
        self.heading = heading
        self.content = content
        self.image = image
    }
    
}
