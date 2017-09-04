//
//  Style.swift
//  DynamicStyles
//
//  Created by Easterby-Smith, Sam (Developer) on 04/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit

/**
 `Style` is the main model object for styles!
 */

open class Style{
    
    
    /// The name of the style
    open var name: String
    
    /// The name of the parent style - used internally to resolve the hierarchy
    var parentName: String?
    
    /// The parent style object - populated by the stylesheet after creation. Properties of the parent will be reflected unless overriden by the child...
    weak var parent: Style?
    
    /// UIFont object based on this style
    open var font: UIFont? {
        get{
            let fontDescriptor = self.fontDescriptor
            let size = fontDescriptor.pointSize
            return UIFont(descriptor: fontDescriptor, size: size)
            
        }
    }
    
    
    /// Returns a UIFontDescriptor
    open var fontDescriptor: UIFontDescriptor {
        get{
            
            var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [:]
            
            fontAttributes[.size] = scaledSize
            
            if let face = face {
                fontAttributes[.face] = face
            }
            
            if let weight = weight {
                fontAttributes[.traits] = [UIFontDescriptor.TraitKey.weight: weight]
            }
            
            if let family = family {
                fontAttributes[.family] = family
            } else  {
                return UIFont.systemFont(ofSize: scaledSize, weight: weight ?? UIFont.Weight.regular).fontDescriptor
//                return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).addingAttributes(fontAttributes)
            }
            let fontDescriptor = UIFontDescriptor(fontAttributes: fontAttributes)
            
            return fontDescriptor

        }
    }
    
    open var paragraphStyle: NSParagraphStyle? {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            
            if let minimumLineHeight = minimumLineHeight {
                paragraphStyle.minimumLineHeight = minimumLineHeight
            }
            
            if let maximumLineHeight = maximumLineHeight {
                paragraphStyle.maximumLineHeight = maximumLineHeight
            }
            
            paragraphStyle.lineSpacing = self.lineSpacing
            
            paragraphStyle.paragraphSpacing = self.paragraphSpacing
            
            paragraphStyle.paragraphSpacingBefore = self.paragraphSpacingBefore
            
            if (self.alignment != nil){
                paragraphStyle.alignment = self.alignment!
            }
            
            paragraphStyle.lineBreakMode = .byTruncatingTail
            
            return paragraphStyle
        }
    }
    
    
    // MARK: - Primitive getters and setters for the various attributes
    
    /// Family name as a string - if nothing is set, will resolve to the parent's family (or nil, being the system font)
    open var family: String?{
        get{
            return _family ?? parent?.family
        }
        set{
            _family = newValue
        }
    }
    
    /// Private variable to back family name
    fileprivate var _family: String?
    
    
    /// Face as a string
    open var face: String?{
        get{
            return _face ?? parent?.face
        }
        set{
            _face = newValue
        }
    }
    
    private var _weight: UIFont.Weight?
    var weight: UIFont.Weight? {
        get { return _weight ?? parent?.weight ?? .regular }
        set { _weight = newValue }
    }
    
    
    /// Private variable to back face name
    fileprivate var _face: String?
    
    /// RAW size of the font (prior to any dynamic scaling)
    open var size: CGFloat{
        get{
            return _size ?? parent?.size ?? 17
        }
        set{
            _size = newValue
        }
    }
    
    fileprivate var _size: CGFloat?
    
    /// The scaled size, obeying whether scaling is enabled for this style
    open var scaledSize: CGFloat {
        get{
            if (self.shouldScale){
                return scaleSize(self.size)
            } else {
                return self.size
            }
        }
    }
    
    /// minimumLineHeight sets the explicit line height - this is absolute and will not scale - set to nil if you want to use lineSpacing
    
    open var minimumLineHeight: CGFloat? {
        get{
            return _minimumLineHeight ?? parent?.minimumLineHeight
        }
        set {
            _minimumLineHeight = newValue
        }
    }
    fileprivate var _minimumLineHeight: CGFloat?
    
    open var maximumLineHeight: CGFloat? {
        get{
            return _maximumLineHeight ?? parent?.maximumLineHeight
        }
        set {
            _maximumLineHeight = newValue
        }
    }
    fileprivate var _maximumLineHeight: CGFloat?
    
    /// Spacing between lines
    
    open var lineSpacing: CGFloat {
        get{
            return _lineSpacing ?? parent?.lineSpacing ?? 0
        }
        set {
            _lineSpacing = newValue
        }
    }
    fileprivate var _lineSpacing: CGFloat?
    
    /// Spacing between paragraphs
    
    open var paragraphSpacing: CGFloat {
        get{
            return _paragraphSpacing ?? parent?.paragraphSpacing ?? 0
        }
        set {
            _paragraphSpacing = newValue
        }
    }
    fileprivate var _paragraphSpacing: CGFloat?
    
    
    /// Spacing before paragraphs
    
    open var paragraphSpacingBefore: CGFloat {
        get{
            return _paragraphSpacingBefore ?? parent?.paragraphSpacingBefore ?? 0
        }
        set {
            _paragraphSpacingBefore = newValue
        }
    }
    fileprivate var _paragraphSpacingBefore: CGFloat?
    
    
    /// Text alignment
    
    open var alignment: NSTextAlignment? {
        get{
            return _alignment ?? parent?.alignment
        }
        set {
            _alignment = newValue
        }
    }
    fileprivate var _alignment: NSTextAlignment?
    
    /// Set to true if the
    
    open var shouldScale: Bool{
        get{
            return _shouldScale ?? parent?.shouldScale ?? false
        }
        set{
            _shouldScale = newValue
        }
    }
    
    fileprivate var _shouldScale: Bool?
    
    ///
    
    /**
     The designated initializer
     @param name The name of this style
     @param dictionary The fragment of the plist containing the definition of the style
     */
    
    public init(name: String, definition : [String:AnyObject]){
        
        self.name=name
        self.parentName=definition["parent"] as? String
        
        // Set properties based on what was in the plist fragment
        
        if let val = definition["family"] as? String {
            self.family=val
        }
        
        if let face = definition["face"] as? String {
            self.face = face
        }
        if let weight = definition["weight"] as? CGFloat {
            self.weight = UIFont.Weight(rawValue:weight)
        }
        
        if let val = definition["size"] as? CGFloat {
            self.size=val
        }
        
        if let val = definition["paragraphSpacing"] as? CGFloat {
            self.paragraphSpacing=val
        }
        
        if let val = definition["paragraphSpacingBefore"] as? CGFloat {
            self.paragraphSpacingBefore=val
        }

        
        if let val = definition["lineSpacing"] as? CGFloat {
            self.lineSpacing=val
        }
        
        if let val = definition["alignment"] as? String {
            switch (val){
            case "center":
                self.alignment = NSTextAlignment.center
            case "right":
                self.alignment = NSTextAlignment.right
            case "justified":
                self.alignment = NSTextAlignment.justified
            case "natural":
                self.alignment = NSTextAlignment.natural
            default:
                self.alignment = NSTextAlignment.left
            }
        }
        
        if let val = definition["minimumLineHeight"] as? CGFloat {
            self.minimumLineHeight=val
        }
        if let val = definition["maximumLineHeight"] as? CGFloat {
            self.maximumLineHeight=val
        }
        
        if let val = definition["shouldScale"] as? Bool {
            self.shouldScale=val
        }
        
        
    }
    
    
    
    open func attributedString(_ text: String?)->NSAttributedString?{
        if let text = text, let font = self.font, let paragraphStyle = self.paragraphStyle {
            let attributes: [NSAttributedStringKey : Any] = [ .font : font , .paragraphStyle : paragraphStyle ]
            return NSAttributedString(string: text, attributes: attributes)
        } else {
            return nil
        }
    }
    
    open func attributedString(_ text: String?, baseParagraphStyle: NSParagraphStyle) -> NSAttributedString? {
        // This doesn't seem to have got implemented - will probably throw it out
        return nil
    }
    
    
    /// Check for whether the parent relationship for this style is cyclical (which would be a bad thing)
    var parentIsCyclical: Bool{
        
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
    
    
    /// Get or set the root style
    
    open var rootStyle: Style{
        get{
            if let parent = parent {
                return parent.rootStyle
            }
            return self
        }
        set{
            if (self.rootStyle !== newValue){
                self.rootStyle.parent=newValue
            }
        }
    }
    
    /// Calculates a scaled size based on the users's current Dynamic Type settings
    
    fileprivate func scaleSize(_ targetSize: CGFloat)->CGFloat{
        let systemFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let systemPointSize: CGFloat = systemFontDescriptor.pointSize
        let size = (systemPointSize/17) * targetSize
        return size
    }
    
    var resolvedFontExists: Bool {
        let postscriptName = fontDescriptor.postscriptName
        print("🔡 Style \(name) resolves to \(postscriptName)")
        if UIFont(name: postscriptName, size: 12) != nil {
            return true
        } else {
            print("😭 Style \(name) has nonexistent font \(postscriptName) - \(family ?? "-") \(face ?? "-")")
            let availableFaces = UIFont.fontNames(forFamilyName: family!)
            print("Available faces: \(availableFaces)")
            return false
        }
    }
    
}
