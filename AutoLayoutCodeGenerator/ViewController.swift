//
//  ViewController.swift
//  XibToSwift
//
//  Created by George Wu on 7/4/15.
//  Copyright © 2015 George Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSXMLParserDelegate {
	
	// MARK: - Properties
	
	/// A dictionary for view items for a quick search of id.
	var viewItemDict: [String: ConstraintedView] = [:]
	
	/// Stack that keeps track of element infos when serializing nib.
	var elementInfoStack = Stack< (elementName: String, attributeDict: [String: String]) >()
	
	var constraintsFlag: Int = 0
	
	var constraintsCode: String = "\n"
	
	var currentViewItemName: String = ""
	
	
	// MARK: - Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Place storyboard path here.
		let path = "/Volumes/Warehouse/Main.storyboard"
		
		if !NSFileManager().fileExistsAtPath(path) {
			fatalError("Error: File doesn't exsit.");
		}
		
		// nib serialization
		guard let xmlParser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path)) else {
			fatalError("Error: File format may be incorrect.");
		}
		
		xmlParser.delegate = self
		xmlParser.parse()
	}
	
	// MARK: - NSXMLParserDelegate methods
	
	func parserDidStartDocument(parser: NSXMLParser) {
		
		print("---parserDidStartDocument---")
	}
	
	func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		
		// record id and the corresponding view item in dictionary if it has one
		if let viewItemId = attributeDict["id"] {
			let viewItem = ConstraintedView(attributeDict: attributeDict)
			viewItemDict[viewItemId] = viewItem
			
			if "NO" == attributeDict["translatesAutoresizingMaskIntoConstraints"] {
				
				constraintsCode += "\(viewItem.variableName).translatesAutoresizingMaskIntoConstraints = false\n"
			}
		}
		
		// prepare when enter <constraints>
		if elementName == "constraints" {
			constraintsFlag++
			currentViewItemName = elementInfoStack.top()!.attributeDict["id"]!
		}
		
		// add constraint code if the node is <constraint>
		if constraintsFlag > 0 && elementName == "constraint" {
			
			let firstItemValue: String? = attributeDict["firstItem"]		// id
			let firstAttributeValue: String? = attributeDict["firstAttribute"]
			let secondItemValue: String? = attributeDict["secondItem"]
			let secondAttributeValue: String? = attributeDict["secondAttribute"]
			let constantValue: String? = attributeDict["constant"]
			let multiplierValue: String? = attributeDict["multiplier"]
			
			let firstItemCode: String
			let firstAttributeCode: String
			let secondItemCode: String
			let secondAttributeCode: String
			let constantCode: String = constantValue ?? "0"
			let multiplierCode: String = multiplierValue ?? "1.0"
			
			// view on which the constraint's been added
			let onView = ConstraintedView(attributeDict: elementInfoStack.second()!.attributeDict).variableName
			
			if (firstItemValue == nil) {	// unilateral constraint
				
				firstItemCode = viewItemDict[currentViewItemName]!.variableName
				firstAttributeCode =  layoutAttributeDict[firstAttributeValue!]!
				secondItemCode = "nil"
				secondAttributeCode = "NotAnAttribute"
				
				// concat comment
				constraintsCode += "// \(firstItemCode) constriants\n"
				constraintsCode += onView
				constraintsCode +=
				".addConstraint(NSLayoutConstraint(item: \(firstItemCode), attribute: NSLayoutAttribute.\(firstAttributeCode), relatedBy: NSLayoutRelation.Equal, toItem: \(secondItemCode), attribute: NSLayoutAttribute.\(secondAttributeCode), multiplier: \(multiplierCode), constant: \(constantCode)))\n"
				
				
			} else {	// bilateral constraint
				
				firstItemCode = viewItemDict[firstItemValue!]!.variableName
				firstAttributeCode =  layoutAttributeDict[firstAttributeValue!]!
				secondItemCode = viewItemDict[secondItemValue!]!.variableName
				secondAttributeCode = layoutAttributeDict[secondAttributeValue!]!
				
				constraintsCode += "// \(firstItemCode) constriants\n"
				constraintsCode += onView
				constraintsCode +=
					".addConstraint(NSLayoutConstraint(item: \(firstItemCode), attribute: NSLayoutAttribute.\(firstAttributeCode), relatedBy: NSLayoutRelation.Equal, toItem: \(secondItemCode), attribute: NSLayoutAttribute.\(secondAttributeCode), multiplier: \(multiplierCode), constant: \(constantCode)))\n"
			}
			
		}
		
		// push element info into info stack
		elementInfoStack.push( (elementName, attributeDict) )
	}
	
	func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		
		// decrease constraintsFlag when getting out of "constraints" element
		if elementName == "constraints" {
			constraintsFlag--
			currentViewItemName = ""
		}
		
		// pop element from element info stack
		elementInfoStack.pop()
	}
	
	func parserDidEndDocument(parser: NSXMLParser) {
		
		print(constraintsCode)
		print("---parserDidEndDocument---")
	}
}

let layoutAttributeDict: [String: String] =
	["left": "Left",
	"right": "Right",
	"top": "Top",
	"bottom": "Bottom",
	"leading": "Leading",
	"trailing": "Trailing",
	"width": "Width",
	"height": "Height",
	"centerX": "CenterX",
	"centerY": "CenterY",
	"baseline": "Baseline",
	"lastBaseline": "LastBaseline",
	"firstBaseline": "FirstBaseline",
	"leftMargin": "LeftMargin",
	"rightMargin": "RightMargin",
	"topMargin": "TopMargin",
	"bottomMargin": "BottomMargin",
	"leadingMargin": "LeadingMargin",
	"trailingMargin": "TrailingMargin",
	"centerXWithinMargins": "CenterXWithinMargins",
	"centerYWithinMargins": "CenterYWithinMargins",
	"notAnAttribute": "NotAnAttribute"]
