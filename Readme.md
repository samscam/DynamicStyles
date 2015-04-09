# DynamicStyles


## Overview
**DynamicStyles**, the missing stylesheet manager for iOS apps.

* Write a single stylesheet to manage all the typography in your iOS app!
* WYSIWYG styles in InterfaceBuilder...
* ... or apply styles in code!
* Supports DynamicType font scaling for full accessible joy.
* Written in **Swift**.
* Compatible with iOS **8.0+**
* Contributions welcome!
* **Currently in rapid development! Expect frequent updates! Expect things to break!**

## Installation

### Cocoapods

You're best using [CocoaPods](http://cocoapods.org)

Add `pod 'DynamicStyles', '~>0.1.2'` to your podfile.

Run `pod install`

### ... and then

Create a property list called `Stylesheet.plist` somwehere in your project. There is one in the example project in the repo which you could use as a starting point.

You can theoretically tell it to use a custom named plist from code but you won't get IB rendering if you do that.

## Usage

### Interface Builder

* Select a UILabel in your nib/storyboard
* From the **identity inspector** set the custom class to `DynamicStyleLabel`. The module should update by itself (if it doesn't, make sure it says `DynamicStyles`)
* In the **attributes inspector** there's a box called `Style Name` – type the name of one of your defined styles in there and watch the label update!

The same goes for buttons. The custom class for them is `DynamicStyleButton`


### Code

	label.styleName="heading"

or...

	let stylesheet = Stylesheet.defaultStylesheet
	let headingStyle = stylesheet.style("heading")
	label.style=headingStyle
	


## Stylesheet Syntax

* root (dictionary)
	* styleName (dictionary)
		* family (string) default is Helvetica Neue
		* face (string) default is Regular
		* size (number) default is 17
		* parent (string - reference to another style name - may not be circular)
	* exampleBaseStyle
		* family : Courier
	* exampleHeadlineStyle
		* size : 48
		* parent : exampleBaseStyle
	* exampleHeadlineStyle
		* size : 48
		* parent : exampleBaseStyle

