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
    
    struct Singleton {
        static var instance: Stylesheet?
        static var token: dispatch_once_t = 0
    }
    
    /// Creates a shared stylesheet with a given name - if you need to, call this early on
    
    public class func defaultStylesheet(named stylesheetName: String)->Stylesheet{
        dispatch_once(&Singleton.token) {
            Singleton.instance = Stylesheet(named: stylesheetName)
        }
        return Singleton.instance!
    }
    
    /// Returns the shared stylesheet - by default it looks for one called "Stylesheet.plist" in the main bundle
    
    public class var defaultStylesheet: Stylesheet {
        dispatch_once(&Singleton.token) {
            Singleton.instance = Stylesheet(named: "Stylesheet")
        }
        return Singleton.instance!
    }

    /// Designated initialiser - grabs the named .plist and instantiates all the styles it contains
    
    public init?(path stylesheetPath: String?){
        styles=[:]
        
        if (stylesheetPath == nil){
            return
        }

        if let stylesheetDict = NSDictionary(contentsOfFile: stylesheetPath!){
            
            // Iterate through the incoming dict and create style objects for each of the keys
            for (styleIdentifier: String, styleDict: [String:AnyObject]) in stylesheetDict as [String:[String:AnyObject]] {
                styles[styleIdentifier]=Style(name: styleIdentifier, definition: styleDict)
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
    
    /// Convenience initialisers
    
    public convenience init?(named stylesheetName: String,
        inBundle bundle: NSBundle?){
            
            var inBundle = (bundle != nil) ? bundle : NSBundle.mainBundle()
            
            let stylesheetPath: String? = inBundle?.pathForResource(stylesheetName, ofType: "plist")
            self.init(path:stylesheetPath)
            
    }
    
    public convenience init?(named name: String){
        self.init(named: name, inBundle: nil)
    }
    
    public func style(name: String)->Style?{
        return styles[name]
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
        
        var localAttributes: [NSObject:AnyObject] = [:]

        if let size: CGFloat = definition["size"] as? CGFloat {
            let realSize = scaledSize(size)
            localAttributes[UIFontDescriptorSizeAttribute] = realSize
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

// MARK: - UIView inspectability


@IBDesignable public class DynamicStyleLabel: UILabel{
    
    var stylesheet: Stylesheet? = Stylesheet.defaultStylesheet
    
    @IBInspectable public var styleName: NSString? {
        didSet{
            if (styleName != nil) {
                style=stylesheet?.style(styleName!)
            } else {
                style=nil
            }
        }
    }
    
    public var style: Style? {
        didSet{
            self.font=style?.font()
        }
    }
    
    override public func prepareForInterfaceBuilder() {
        
        // We need to fish around directories to create subsitute for the main bundle when using Interface Builder live rendering
        let processInfo = NSProcessInfo.processInfo()
        let environment = processInfo.environment as [String:String]
        let projectSourceDirectories : String = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        let directories = projectSourceDirectories.componentsSeparatedByString(":")

        var path = directories[0] as String
        
        // Remove pods from the path components (assuming we are in a cocoapods environment)
        if (path.lastPathComponent == "Pods"){
            path=path.stringByDeletingLastPathComponent
        }
        
        // Create a bundle based on the project path
        let bundle=NSBundle(path: path)
        
        self.stylesheet=Stylesheet(named: "Stylesheet", inBundle: bundle)

        // Force the style to be updated
        if let sn=self.styleName {
            self.style=self.stylesheet?.style(sn)
        }
    }
    
}


@IBDesignable public class DynamicStyleButton: UIButton{
    
    var stylesheet: Stylesheet? = Stylesheet.defaultStylesheet
    
    @IBInspectable public var styleName: NSString? {
        didSet{
            if (styleName != nil) {
                style=stylesheet?.style(styleName!)
            } else {
                style=nil
            }
        }
    }
    
    public var style: Style? {
        didSet{
            self.titleLabel?.font=style?.font()
        }
    }
    
    override public func prepareForInterfaceBuilder() {
        
        // We need to fish around directories to create subsitute for the main bundle when using Interface Builder live rendering
        let processInfo = NSProcessInfo.processInfo()
        let environment = processInfo.environment as [String:String]
        let projectSourceDirectories : String = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        let directories = projectSourceDirectories.componentsSeparatedByString(":")
        
        var path = directories[0] as String
        
        // Remove pods from the path components (assuming we are in a cocoapods environment)
        if (path.lastPathComponent == "Pods"){
            path=path.stringByDeletingLastPathComponent
        }
        
        // Create a bundle based on the project path
        let bundle=NSBundle(path: path)
        
        self.stylesheet=Stylesheet(named: "Stylesheet", inBundle: bundle)
        
        // Force the style to be updated
        if let sn=self.styleName {
            self.style=self.stylesheet?.style(sn)
        }
    }
    
}

// MARK: - Utility functions...

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