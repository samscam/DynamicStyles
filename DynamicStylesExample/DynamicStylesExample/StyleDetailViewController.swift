//
//  StyleDetailViewController.swift
//  DynamicStylesExample
//
//  Created by Sam Easterby-Smith on 05/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import UIKit
import DynamicStyles

class StyleDetailViewController: UIViewController {
    
    var style: Style? {
        didSet{
            populate()
        }
    }
    
    @IBOutlet weak var topSampleLabel: DynamicStyleLabel!
    @IBOutlet weak var postscriptNameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var longSampleLabel: DynamicStyleLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populate(){
        guard self.isViewLoaded,
        let style = style else {
            return
        }
        self.navigationItem.title = style.name
        
        topSampleLabel.style = style
        topSampleLabel.text = style.name
        
        postscriptNameLabel.text = style.fontDescriptor.postscriptName
        weightLabel.text = "\(style.weight?.rawValue ?? 0)"
        familyLabel.text = style.family
        faceLabel.text = style.face
        sizeLabel.text = "\(style.size)"
        longSampleLabel.style = style
        
    }

}
