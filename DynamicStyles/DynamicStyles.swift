//
//  DynamicStyles.swift
//  DynamicStyles
//
//  Created by Sam Easterby-Smith on 29/03/2015.
//  Copyright (c) 2015 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit

public class Stylesheet{
    
    public var styles: [String:Style]

    public init?(named stylesheetName: String,
        inBundle bundle: NSBundle?){
            styles=[:]
            var inBundle = (bundle != nil) ? bundle : NSBundle.mainBundle()
            if let stylesheetPath: String? = inBundle?.pathForResource(stylesheetName, ofType: "plist") {
                if let stylesheetDict = NSDictionary(contentsOfFile: stylesheetPath!){
                    
                    // Iterate through the incoming dict and create style objects for each of the keys
                    for (styleIdentifier: String, styleDict: [String:AnyObject]) in stylesheetDict as [String:[String:AnyObject]] {
                        styles[styleIdentifier]=Style(name: styleIdentifier, definition: styleDict)
                    }
                }
            }
            
            // Resolve parents
            for (styleIdentifier: String, style: Style) in styles{
                if (style.parentName != nil){
                    style.parent=self.style(style.parentName!)
                }
            }
            
            // Check for cyclicity
            for (styleIdentifier: String, style: Style) in styles{
                assert(!style.parentIsCyclical(),"Styles must not be cyclical")
            }
            
            
    }
    
    public convenience init?(named name: String){
        self.init(named: name, inBundle: nil)
    }
    
    public func style(name: String)->Style?{
        return styles[name]
    }
    
    func fontForStyle(style: String)->UIFont?{
        return nil
    }
    
    
}

public class Style{
    
    private var definition: [String:AnyObject]
    public var name: String
    
    var parentName: String?
    var parent: Style?
    
    public init(name: String, definition dictionary: [String:AnyObject]){
        definition=dictionary
        self.name=name
        self.parentName=self.definition["parent"] as? String
    }
    
    public func font()->UIFont{
        let fontDescriptor = self.fontDescriptor()
        let scaledPointSize=fontDescriptor.pointSize
        
        return UIFont(descriptor: fontDescriptor, size: scaledPointSize)
    }
    
    public func fontDescriptor()->UIFontDescriptor{

        var fontDescriptor: UIFontDescriptor?
        if (self.parent != nil){
            fontDescriptor=self.parent!.fontDescriptor()
        } else {
            fontDescriptor=baseFontDescriptor()
        }
        
        var localAttributes: [NSString:AnyObject] = [:]
        
        var size: CGFloat?
        
        if (definition["size"] != nil){
            size = scaledSize(definition["size"] as CGFloat)
        }
        
        if (size != nil){
            localAttributes[UIFontDescriptorSizeAttribute] = size
        }
        
        if let family: String = definition["family"] as? String {
            localAttributes[UIFontDescriptorFamilyAttribute] = family
        }
        
        if let face: String = definition["face"] as? String {
            localAttributes[UIFontDescriptorFaceAttribute] = face
        }
        
        fontDescriptor=fontDescriptor?.fontDescriptorByAddingAttributes(localAttributes)
        return fontDescriptor!
    }
    
    public func parentIsCyclical()->Bool{

        var thisParent: Style? = self.parent
        while (thisParent != nil){
            if (thisParent === self){
                return true
            } else {
                thisParent = thisParent!.parent
            }
        }
        return false
    }
}

func baseFontDescriptor()->UIFontDescriptor{
    let size = scaledSize(17)
    return UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute:"Helvetica Neue",
        UIFontDescriptorSizeAttribute:size])
    
}

func scaledSize(targetSize: CGFloat)->CGFloat{
    let systemFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let systemPointSize: CGFloat = systemFontDescriptor.pointSize
    let size = (systemPointSize/17) * targetSize
    return size
}