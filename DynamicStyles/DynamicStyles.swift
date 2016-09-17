//
//  DynamicStyles.swift
//  DynamicStyles
//
//  Created by Sam Easterby-Smith on 29/03/2015.
//  Copyright (c) 2015 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit


// MARK: - DynamicStyles

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
        for (_, style): (String, Style) in styles{
            if (style.parentName != nil){
                style.parent=self.style(style.parentName!)
            }
        }
        
        // Check for cyclicity. This will throw an error at runtime if styles are inbred ;-)
        for (_, style): (String, Style) in styles{
            assert(!style.parentIsCyclical(),"Styles must not be cyclical")
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

/**
    `Style` is the main model object for styles!
*/

open class Style{
    
    
    /// The name of the style
    open var name: String
    
    /// The name of the parent style - used internally to resolve the hierarchy
    fileprivate var parentName: String?
    
    /// The parent style object - populated by the stylesheet after creation. Properties of the parent will be reflected unless overriden by the child...
    open var parent: Style?

    /// UIFont object based on this style
    open var font: UIFont? {
        get{
            let fontDescriptor = self.fontDescriptor
            let size=fontDescriptor.pointSize
            return UIFont(descriptor: fontDescriptor, size: size)
        }
    }
    
    
    /// Returns a UIFontDescriptor
    open var fontDescriptor: UIFontDescriptor {
        get{
            var fontAttributes: [String:AnyObject] = [:]
            
            fontAttributes[UIFontDescriptorSizeAttribute] = scaledSize as AnyObject?
            fontAttributes[UIFontDescriptorFamilyAttribute] = family as AnyObject?
            fontAttributes[UIFontDescriptorFaceAttribute] = face as AnyObject?

            return UIFontDescriptor(fontAttributes: fontAttributes)
        }
    }
    
    open var paragraphStyle: NSParagraphStyle? {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            
            if (self.minimumLineHeight != nil){
                paragraphStyle.minimumLineHeight = self.minimumLineHeight!
            }
            
            if (self.maximumLineHeight != nil){
                paragraphStyle.maximumLineHeight = self.maximumLineHeight!
            }
            
            paragraphStyle.lineSpacing = self.lineSpacing
            
            paragraphStyle.paragraphSpacing = self.paragraphSpacing
            
            paragraphStyle.paragraphSpacingBefore = self.paragraphSpacingBefore

            if (self.alignment != nil){
                paragraphStyle.alignment = self.alignment!
            }
            
            paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            return paragraphStyle
        }
    }
    

    // MARK: - Primitive getters and setters for the various attributes
    
    /// Family name as a string - if nothing is set, will resolve to the parent's family, or default to Helvetica Neue
    open var family: String?{
        get{
            if ( _family != nil ){
                return _family
            } else if (parent != nil){
                return parent!.family
            } else {
                return "Helvetica Neue"
            }
        }
        set{
            _family=newValue
        }
    }
    
    /// Private variable to back family name
    fileprivate var _family: String?
    
    
    /// Face as a string
    open var face: String{
        get{
            if ( _face != nil ){
                return _face!
            } else if (parent != nil) {
                return parent!.face
            } else {
                return "Regular"
            }
        }
        set{
            _face=newValue
        }
    }
    
    /// Private variable to back face name
    fileprivate var _face: String?
    
    /// RAW size of the font (prior to any dynamic scaling)
    open var size: CGFloat{
        get{
            if ( _size != nil ){
                return _size!
            } else if ( parent != nil ) {
                return parent!.size
            } else {
                return 17
            }
        }
        set{
            _size=newValue
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
            if ( _minimumLineHeight != nil ){
                return _minimumLineHeight!
            } else if ( parent != nil ) {
                return parent!.minimumLineHeight
            } else {
                return nil
            }
        }
        set {
            _minimumLineHeight = newValue
        }
    }
    fileprivate var _minimumLineHeight: CGFloat?
    
    open var maximumLineHeight: CGFloat? {
        get{
            if ( _maximumLineHeight != nil ){
                return _maximumLineHeight!
            } else if ( parent != nil ) {
                return parent!.maximumLineHeight
            } else {
                return nil
            }
        }
        set {
            _maximumLineHeight = newValue
        }
    }
    fileprivate var _maximumLineHeight: CGFloat?
    
    /// Spacing between lines
    
    open var lineSpacing: CGFloat {
        get{
            if ( _lineSpacing != nil ){
                return _lineSpacing!
            } else if ( parent != nil ) {
                return parent!.lineSpacing
            } else {
                return 0
            }
        }
        set {
            _lineSpacing = newValue
        }
    }
    fileprivate var _lineSpacing: CGFloat?
    
    /// Spacing between paragraphs
    
    open var paragraphSpacing: CGFloat {
        get{
            if ( _paragraphSpacing != nil ){
                return _paragraphSpacing!
            } else if ( parent != nil ) {
                return parent!.paragraphSpacing
            } else {
                return 0
            }
        }
        set {
            _paragraphSpacing = newValue
        }
    }
    fileprivate var _paragraphSpacing: CGFloat?
    
    
    /// Spacing before paragraphs
    
    open var paragraphSpacingBefore: CGFloat {
        get{
            if ( _paragraphSpacingBefore != nil ){
                return _paragraphSpacingBefore!
            } else if ( parent != nil ) {
                return parent!.paragraphSpacingBefore
            } else {
                return 0
            }
        }
        set {
            _paragraphSpacingBefore = newValue
        }
    }
    fileprivate var _paragraphSpacingBefore: CGFloat?
    
    
    /// Text alignment
    
    open var alignment: NSTextAlignment? {
        get{
            if ( _alignment != nil ){
                return _alignment!
            } else if ( parent != nil ) {
                return parent!.alignment
            } else {
                return nil
            }
        }
        set {
            _alignment = newValue
        }
    }
    fileprivate var _alignment: NSTextAlignment?
    
    /// Set to true if the
    
    open var shouldScale: Bool{
        get{
            if (_shouldScale != nil){
                return _shouldScale!
            } else if (parent != nil){
                return parent!.shouldScale
            } else {
                return false
            }
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
        
        if let val = definition["face"] as? String {
            self.face=val
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
            let attributes: [String : AnyObject] = [ NSFontAttributeName : font , NSParagraphStyleAttributeName : paragraphStyle ]
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
    open func parentIsCyclical()->Bool{

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
            if (self.parent == nil){
                return self
            } else {
                return self.parent!.rootStyle
            }
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

}

// MARK: - UIView subclasses

/**
    `DynamicStyleLabel` is a UILabel subclass which supports styling
*/

@IBDesignable open class DynamicStyleLabel: UILabel{
    
    /// The active stylesheet (defaults to the default one)
    
    var stylesheet: Stylesheet? = Stylesheet.defaultStylesheet
    
    /// The *name* of the style to be applied. Setting this (in code or from Interface Builder) will cause the style with said name from the active stylesheet to be applied to the label.
    
    @IBInspectable open var styleName: NSString? {
        didSet{
            if (styleName != nil) {
                style=stylesheet?.style(styleName! as String)
            } else {
                style=nil
            }
        }
    }
    
    /// The *style* - setting this sets the font of the label to match the font defined by the style
    
    open var style: Style? {
        didSet{
            updateDisplay()
        }
    }
    
    /// Provides @IBDesignable functionality
    
    override open func prepareForInterfaceBuilder() {
        
        let bundle = Bundle.projectBundleForInterfaceBuilder()
        self.stylesheet=Stylesheet(named: "Stylesheet", inBundle: bundle)

        // Force the style to be updated
        if let sn=self.styleName {
            self.style=self.stylesheet?.style(sn as String)
        }
    }
    
    override open var text: String?{
        didSet{
            updateDisplay()
        }
    }
    
    fileprivate func updateDisplay(){
        #if !TARGET_INTERFACE_BUILDER
            if (self.text != nil){
                let attributedString = style?.attributedString(self.text)
                self.attributedText = attributedString
            }
        #else
            self.font=self.style?.font
        #endif
        
    }
    
    open var gutter: UIEdgeInsets = UIEdgeInsetsMake(2, 0, 2, 0) {
        didSet{
            self.setNeedsUpdateConstraints()
        }
    }
    
    override open var intrinsicContentSize : CGSize {
        var superSize = super.intrinsicContentSize
        superSize.height += gutter.bottom + gutter.top
        superSize.width += gutter.left + gutter.right
        return superSize
    }
    

}

/**
`DynamicStyleButton` is a UIButton subclass which supports styling
*/

@IBDesignable open class DynamicStyleButton: UIButton{
    
    /// The active stylesheet (defaults to the default one).
    
    var stylesheet: Stylesheet? = Stylesheet.defaultStylesheet
    
    /// The *name* of the style to be applied. Setting this (in code or from Interface Builder) will cause the style with said name from the active stylesheet to be applied to the label.
    
    @IBInspectable open var styleName: NSString? {
        didSet{
            if (styleName != nil) {
                style=stylesheet?.style(styleName! as String)
            } else {
                style=nil
            }
        }
    }
    
    /// The *style* - setting this sets the font of the label to match the font defined by the style
    
    open var style: Style? {
        didSet{
            updateDisplay()
        }
    }
    
    fileprivate func updateDisplay(){
        self.titleLabel?.font=style?.font
    }
    
    /// Provides @IBDesignable functionality
    
    override open func prepareForInterfaceBuilder() {
        
        let bundle = Bundle.projectBundleForInterfaceBuilder()
        self.stylesheet=Stylesheet(named: "Stylesheet", inBundle: bundle)
        
        // Force the style to be updated
        if let sn=self.styleName {
            self.style=self.stylesheet?.style(sn as String)
        }
    }
    
}

// MARK: - NSBundle extension


public extension Bundle{
    
    /// Returns an NSBundle based on the project's root directory. In the context of Interface Builder, asking for NSBundle.mainBundle() will provide a bundle for some internal part of XCode. This instead gives us something from which we can find project-specific resources like the `Stylesheet.plist`
    
    public class func projectBundleForInterfaceBuilder() -> Bundle? {

        let processInfo = ProcessInfo.processInfo
        let environment = processInfo.environment 
        let projectSourceDirectories : String = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        let directories = projectSourceDirectories.components(separatedBy: ":")
        
        let path = directories[0] as String
        var url = URL(fileURLWithPath: path)
        // Remove pods from the path components (assuming we are in a cocoapods environment)
        if (url.lastPathComponent == "Pods"){
            url=url.deletingLastPathComponent()
        }
        
        // Create and a bundle based on the project path
        return Bundle(url: url)
        
    }
}
