//
//  DynamicStyleLabel.swift
//  DynamicStyles
//
//  Created by Easterby-Smith, Sam (Developer) on 04/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit

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
        super.prepareForInterfaceBuilder()
        
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
