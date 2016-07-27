//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 22/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    var color: UIColor {
        set {
            self.backgroundColor = UIColor.whiteColor()
        }
        
        get {
            return self.backgroundColor ?? UIColor.whiteColor()
        }
    }
}