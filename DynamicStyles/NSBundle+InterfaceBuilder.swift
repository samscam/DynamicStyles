//
//  DynamicStyles.swift
//  DynamicStyles
//
//  Created by Sam Easterby-Smith on 29/03/2015.
//  Copyright (c) 2015 Spotlight Kid. All rights reserved.
//

import Foundation
import UIKit


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
