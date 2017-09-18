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
    
    @IBOutlet weak var styleDescriptionLabel: DynamicStyleLabel!
    @IBOutlet weak var sampleLabel: DynamicStyleLabel!
    
    var style: Style? {
        didSet{
            self.styleDescriptionLabel.text=self.style?.name
            self.sampleLabel.text = self.style?.name
            self.sampleLabel.style=self.style
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    
    
}
