///////////////////////////////////////////////////////////////////////////////
//  DynamicBehavior.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 21/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

class DynamicBehavior: UIDynamicBehavior {
	
	private let gravity = UIGravityBehavior()
	
	let collider: UICollisionBehavior = {
		let collider = UICollisionBehavior()
		collider.translatesReferenceBoundsIntoBoundary = true
		return collider
	}()
	
	private let itemBehavior: UIDynamicItemBehavior = {
		let itemBehavior = UIDynamicItemBehavior()
		itemBehavior.allowsRotation = true
		itemBehavior.elasticity = 0.75
		return itemBehavior
	}()
	
	private let pushBehavior: UIPushBehavior = {
		let push = UIPushBehavior()
		
		return push
	}()

	func addBarrier(path: UIBezierPath, name: String) {
		collider.removeBoundary(withIdentifier: name as NSCopying)
		collider.addBoundary(withIdentifier: name as NSCopying, for: path)
	}
	
	override init() {
		super.init()
		addChildBehavior(gravity)
		addChildBehavior(collider)
		addChildBehavior(itemBehavior)
	}
	
	func add(item: UIDynamicItem) {
		gravity.addItem(item)
		collider.addItem(item)
		itemBehavior.addItem(item)
	}
	
	func remove(item: UIDynamicItem) {
		gravity.removeItem(item)
		collider.removeItem(item)
		itemBehavior.removeItem(item)
	}

}
