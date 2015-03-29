//
//  SampleCell.swift
//  DynamicStylesExample
//
//  Created by Sam Easterby-Smith on 29/03/2015.
//  Copyright (c) 2015 Spotlight Kid. All rights reserved.
//

import UIKit
import DynamicStyles

class SampleCell: UITableViewCell{
    
    @IBOutlet weak var styleDescriptionLabel: UILabel!
    @IBOutlet weak var sampleLabel: UILabel!
    
    var style: DynamicStyles.Style? {
        didSet{
            self.styleDescriptionLabel.text=self.style?.name
            self.sampleLabel.font=self.style?.font()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    
    
}
