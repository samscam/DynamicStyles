//
//  Stylesheet.swift
//  DynamicStyles
//
//  Created by Easterby-Smith, Sam (Developer) on 04/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import Foundation

/**
 A `Stylesheet` is a container for a selection of styles loaded from a plist. Currently this only properly supports the default `Stylesheet.plist` which should be located somewhere in your project.
 */

open class Stylesheet{
    
    static open let defaultStylesheet = Stylesheet(named: "Stylesheet")
    
    open var styles: [String:Style] = [:]
    
    
    
    /// Designated initialiser - grabs the named .plist and instantiates all the styles it contains
    
    public init?(path stylesheetPath: String){
        
        if let stylesheetDict = NSDictionary(contentsOfFile: stylesheetPath){
            
            // Iterate through the incoming dict and create style objects for each of the keys
            for (styleIdentifier, styleDict): (String, [String:AnyObject]) in stylesheetDict as! [String:[String:AnyObject]] {
                styles[styleIdentifier]=Style(name: styleIdentifier, definition: styleDict)
            }
        }
        
        // Resolve parents
        styles.forEach { (_, style) in
            if let parentName = style.parentName {
                style.parent=self.style(parentName)
            }
        }
        
        // Sanity checks
        styles.forEach { (_, style) in
            // Check for cyclicity. This will throw an error at runtime if styles are inbred ;-)
            assert(!style.parentIsCyclical,"Styles must not be cyclical")
            
            // Check that styles resolve to real fonts
            _ = style.resolvedFontExists
        }
    }
    
    // Convenience initialisers
    
    public convenience init?(named stylesheetName: String,
                             inBundle bundle: Bundle?){
        
        if let inBundle = (bundle != nil) ? bundle : Bundle.main,
            let stylesheetPath: String = inBundle.path(forResource: stylesheetName, ofType: "plist") {
            self.init(path:stylesheetPath)
        } else {
            return nil
        }
    }
    
    public convenience init?(named name: String){
        self.init(named: name, inBundle: nil)
    }
    
    open func style(_ name: String)->Style?{
        return styles[name]
    }
    
}
