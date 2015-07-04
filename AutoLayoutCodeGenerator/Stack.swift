//
//  Stack.swift
//  XibToSwift
//
//  Created by George Wu on 7/4/15.
//  Copyright © 2015 George Wu. All rights reserved.
//

import Foundation

struct Stack<ElementT> {
	
	var items = [ElementT]()
	
	mutating func push(item: ElementT) {
		items.append(item)
	}
	
	mutating func pop() -> ElementT? {
		if items.count > 0 {
			return items.removeLast()
		} else {
			return nil
		}
	}
	
	func top() -> ElementT? {
		if items.count > 0 {
			return items.last
		} else {
			return nil
		}
	}
	
	///	Peek the second-top item without doing any change to stack.
	///
	///	- returns: second-top item
	func second() -> ElementT? {
		if items.count > 1 {
			return items[items.count - 2]
		} else {
			return nil
		}
	}
}

