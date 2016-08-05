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
    
    override init(frame: CGRect) {
    super.init(frame: frame)
    imageView = UIImageView(frame: contentView.bounds)
    imageView.contentMode = .ScaleAspectFit
    let image = UIImage(contentsOfFile: "placeholder")
    imageView.image = image
    contentView.addSubview(imageView)
    }
    
    required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    }
    
    var imageView: UIImageView!
    
    var color: UIColor {
        set {
            self.backgroundColor = UIColor.blackColor()
        }
        
        get {
            return self.backgroundColor ?? UIColor.whiteColor()
        }
    }
}