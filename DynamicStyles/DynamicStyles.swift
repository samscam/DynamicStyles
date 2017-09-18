//
//  DynamicStyles.swift
//  DynamicStyles
//
//  Created by Sam Easterby-Smith on 06/09/2017.
//  Copyright © 2017 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit

public struct DynamicStyles {
    
    
    public static var defaultStylesheet: Stylesheet? = try! Stylesheet.with(name: "Stylesheet") ?? nil
    
    
    static func applyGlobalAppStyling(){
        // appearance proxy for things
        UINavigationBar.appearance().tintColor = .blue
        
    }
}
