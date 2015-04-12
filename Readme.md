## Overview
**DynamicStyles**, the missing stylesheet manager for iOS apps.

* Write a single stylesheet to manage all the typography in your iOS app!
* WYSIWYG styles in InterfaceBuilder...
* ... or apply styles in code!
* ** ONLY COVERS: fonts, weights, and sizes at the moment! **
* Optionally uses Apple's DynamicType font scaling for full accessible joy!
* Written in **Swift** - (now Swift 1.2 and XCode 6.3).
* Compatible with iOS **8.0+**
* Contributions welcome!
* **Currently in rapid development! Expect frequent updates! Expect things to break!**

## Installation

### Cocoapods

You're best using [CocoaPods](http://cocoapods.org)

Add `pod 'DynamicStyles', '~>0.1.4'` to your podfile.

Run `pod install`

### ... and then

Create a property list called `Stylesheet.plist` somwehere in your project. There is one in the example project in the repo which you could use as a starting point. See the syntax section below for details.

You can theoretically tell it to use a custom named plist from code but you won't get IB rendering if you do that.

## Usage

### Interface Builder

* Select a UILabel in your nib/storyboard
* From the **identity inspector** set the custom class to `DynamicStyleLabel`. The module should update by itself (if it doesn't, make sure it says `DynamicStyles`)
* In the **attributes inspector** there's a box called `Style Name` – type the name of one of your defined styles in there and watch the label update!

The same goes for buttons. The custom class for them is `DynamicStyleButton`

** IMPORTANT NOTE: ** Due to a [bug in Xcode 6.3](http://stackoverflow.com/questions/29544738/xcode-6-3-freezes-hangs-after-opening-xib-file) (release) use of any @IBDesignable features will cause Xcode to hang when navigating away from a nib in the project navigator. It worked fine with the recent betas - so if you haven't deleted your betas, until Apple fixes the problem, use that.

### Code

	label.styleName="heading"

or in a more verbose way...

	let stylesheet = Stylesheet.defaultStylesheet
	let headingStyle = stylesheet.style("heading")
	label.style=headingStyle
	




## Stylesheet Syntax

The `Stylesheet.plist` should contain a dictionary of style definitions. Each definition is a dictionary with the name of the style as the key.

Definitions may use the following keys:

key | type | default | notes
--- | ---- | ------- | -----
family | string | Helvetica Neue
face | string | Regular
size | number | 17
shouldScale | boolean | NO | Enables dynamic type scaling (including larger accessibility sizes)
parent | string | | reference to a parent style name - must not be circular


_... so an example might look a bit like this_

	* root
		* baseStyle
			* family : Courier
		* headlineStyle
			* face : Bold
			* size : 24
			* parent : baseStyle
		* bigHeadlineStyle
			* size : 48
			* parent : headlineStyle
		* bodyStyle
			* shouldScale : true
			* parent : baseStyle

