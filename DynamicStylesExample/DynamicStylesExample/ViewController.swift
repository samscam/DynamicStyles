//
//  ViewController.swift
//  DynamicStylesExample
//
//  Created by Sam Easterby-Smith on 29/03/2015.
//  Copyright (c) 2015 Spotlight Kid. All rights reserved.
//

import UIKit
import DynamicStyles

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var stylesheet: Stylesheet!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let sheet = Stylesheet.defaultStylesheet {
            stylesheet = sheet
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            
        tableView.estimatedRowHeight=54
        tableView.rowHeight=UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        tableView.reloadData()
        
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SampleCell") as! SampleCell
        let key = Array(self.stylesheet.styles.keys)[indexPath.row] as String?
        let style = self.stylesheet.style(key!)
        cell.style=style
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stylesheet.styles.count
    }


}

