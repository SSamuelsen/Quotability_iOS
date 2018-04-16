//
//  QuoteCellStyle.swift
//  quotesApp
//
//  Created by Stephen Samuelsen on 3/16/18.
//  Copyright © Stephen Samuelsen. All rights reserved.
//

import UIKit

class QuoteCellStyle: UITableViewCell {
    
    
    @IBOutlet weak var authorBox: UILabel!
    //@IBOutlet weak var quoteBox: UILabel!
    @IBOutlet weak var quoteBox: UITextView!
    
    
    
    func configureCell(item: SavedQuote) {
        
        authorBox.text = item.author
        quoteBox.text = item.quote
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
