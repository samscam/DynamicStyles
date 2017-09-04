## Overview
**DynamicStyles**, the missing stylesheet manager for iOS apps.

* Write a single stylesheet to manage all the typography in your iOS app
* WYSIWYG styles in InterfaceBuilder...
* ... or apply styles in code
* Currently covers: **fonts, weights, sizes, line and paragraph spacing**
* Works with: **UILabel and UIButton** (more to come there)
* Optionally uses Apple's DynamicType font scaling for full accessible joy
* Written in **Swift**
* Compatible with iOS **> 8.0**
* Contributions welcome

## Installation

### Requirements

* Xcode 8
* Swift 3.0
* iOS 8

### CocoaPods

You're probably best using [CocoaPods](http://cocoapods.org)

Add `pod 'DynamicStyles', '~>0.3'` to your podfile.

Run `pod install`

### Carthage

It sorta works with Carthage too - BUT things won't render in Interface Builder and you'll have to use User Defined Runtime Attributes to set the styleName for any DynamicStyleLabel or DynamicStyleButton you create. If you still want to use Carthage, add `github "Samscam/DynamicStyles" ~>0.3` to your Cartfile and build and link the framework as usual.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


### Alternatively

Clone the repository if you want to integrate the framework manually or play with the example project.

### ... and then

Create a property list called `Stylesheet.plist` somwehere in your project. There is one in the example project in the repo which you could use as a starting point. See the syntax section below for details.

You can theoretically tell it to use a custom named plist from code but you won't get IB rendering if you do that.

## Usage

### Interface Builder

* Select a UILabel in your nib/storyboard
* From the **identity inspector** set the custom class to `DynamicStyleLabel`. The module should update by itself (if it doesn't, make sure it says `DynamicStyles`)
* In the **attributes inspector** there's a box called `Style Name` – type the name of one of your defined styles in there and watch the label update!

The same goes for buttons. The custom class for them is `DynamicStyleButton`. Plan is to extend this to other UIView variants sometime.

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
family | string | SF Pro Text
face | string | Regular
size | number | 17
shouldScale | boolean | NO | Enables dynamic type scaling (including larger accessibility sizes)
parent | string | | reference to a parent style name - must not be circular
paragraphSpacing | number | 0 | the spacing _between_ paragraphs in points
lineSpacing | number | 0 | the spacing _between_ consecutive lines of text in points
alignment | string | left | can be left, center, right, justified or natural
minimumLineHeight | number | nil
maximumLineHeight | number | nil


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
			* paragraphSpacing : 5

