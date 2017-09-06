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



open class Stylesheet: Decodable {
    
    static open var defaultStylesheet: Stylesheet? = try! Stylesheet.with(name: "Stylesheet")
    
    
    struct StyleNameKey: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StyleNameKey.self)
        for key in container.allKeys {
            let style = try container.decode(Style.self, forKey: key)
            style.name = key.stringValue
            styles[key.stringValue] = style
        }
        resolve()
    }

    
    open var styles: [String:Style] = [:]
    
    func resolve(){
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
    
    // MARK: Factory methods
    
    
    /// grabs the .plist from the given path and instantiates the styles
    class func with(path stylesheetPath: String) throws -> Stylesheet {
        let stylesheetURL = URL(fileURLWithPath: stylesheetPath)
        let stylesheetData = try Data(contentsOf: stylesheetURL)
        return try PropertyListDecoder().decode(self.self, from: stylesheetData)
    }
    
    // finds the named plist in the bundle and instantiates the styles
    class func with(name stylesheetName: String,
                             inBundle bundle: Bundle? = nil) throws -> Stylesheet? {
        
        if let inBundle = (bundle != nil) ? bundle : Bundle.main,
            let stylesheetPath: String = inBundle.path(forResource: stylesheetName, ofType: "plist") {
            return try Stylesheet.with(path:stylesheetPath)
        } else {
            return nil
        }
    }
    
    
    open func style(_ name: String)->Style?{
        return styles[name]
    }
    
    
}
