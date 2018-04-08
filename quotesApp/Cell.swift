//
//  Cell.swift
//  quotesApp
//
//  Created by Stephen Samuelsen on 3/16/18.
//  Copyright © 2018 Unplugged Apps LLC. All rights reserved.
//

import UIKit

@IBDesignable
class Cell: UIView {
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {  //@IBInspectable allows to change in the storyboard
        
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
}
