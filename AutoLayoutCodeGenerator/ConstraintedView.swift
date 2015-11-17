//
//  ConstraintedView.swift
//  XibToSwift
//
//  Created by George Wu on 7/4/15.
//  Copyright © 2015 George Wu. All rights reserved.
//

import Foundation

class ConstraintedView {
	
	/// Variable name for code.
	var variableName: String
	
	init(attributeDict: [String: String]) {
		
		variableName = attributeDict["key"] ?? attributeDict["userLabel"] ?? {
			
			if let layoutType: String = attributeDict["type"] {
				return layoutType + "LayoutGuide"
			} else {
				return "UnNamedVariable"
			}
			}()
	}
}
