//
//  DynamicStyleButton.swift
//  DynamicStyles
//
//  Created by Easterby-Smith, Sam (Developer) on 04/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit

/**
 `DynamicStyleButton` is a UIButton subclass which supports styling
 */

@IBDesignable open class DynamicStyleButton: UIButton{
    
    /// The active stylesheet (defaults to the default one).
    
    var stylesheet: Stylesheet? = DynamicStyles.defaultStylesheet
    
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
        self.stylesheet = try! Stylesheet.with(name: "Stylesheet", inBundle: bundle)
        
        // Force the style to be updated
        if let sn=self.styleName {
            self.style=self.stylesheet?.style(sn as String)
        }
    }
    
    // Catch size changes on-the-fly (only works for iOS 10+)
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 10.0, *) {
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                // content size has changed
                self.updateDisplay()
            }
        }
    }
}
