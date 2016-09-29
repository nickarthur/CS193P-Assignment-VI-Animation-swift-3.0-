///////////////////////////////////////////////////////////////////////////////
//  UIKit Extensions.swift
//  DropIt Lecture 14 - Swift 3.0
//
//  Created by Michel Deiman on 25/07/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

extension CGPoint {
	mutating func translate(p: CGPoint) {
		self.x += p.x
		self.y += p.y
	}
}

extension CGFloat {
	static func random(max: Int) -> CGFloat {
		return CGFloat(arc4random() % UInt32(max))
	}
}

extension Int {
	static func random(max: Int) -> Int {
		return Int(arc4random() % UInt32(max))
	}
}

extension UIColor {
	class var random: UIColor {
		switch arc4random()%5 {
		case 0: return UIColor.green
		case 1: return UIColor.blue
		case 2: return UIColor.orange
		case 3: return UIColor.red
		case 4: return UIColor.purple
		default: return UIColor.black
		}
	}
}

extension CGRect {
	var mid			: CGPoint { return CGPoint(x: midX, y: midY) }
	var upperLeft	: CGPoint { return CGPoint(x: minX, y: minY) }
	var lowerLeft	: CGPoint { return CGPoint(x: minX, y: maxY) }
	var upperRight	: CGPoint { return CGPoint(x: maxX, y: minY) }
	var lowerRight	: CGPoint { return CGPoint(x: maxX, y: maxY) }

	init(center: CGPoint, size: CGSize) {
		let upperLeft = CGPoint(x: center.x - size.width/2, y: center.y - size.height/2)
		self.init(origin: upperLeft, size: size)
	}
}

extension UIView {
	func hitTest(p: CGPoint) -> UIView? {
		return hitTest(p, with: nil)
	}
}

extension UIBezierPath {
	class func line(from: CGPoint, to: CGPoint) -> UIBezierPath {
		let path = UIBezierPath()
		path.move(to: from)
		path.addLine(to: to)
		return path
	}
}

extension UITabBar {
    func animateTo(isVisible: Bool, duration: TimeInterval = 1, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        guard isHidden == isVisible else { return }
        
        let basisY = superview!.frame.height
        let offsetY = isVisible ? -frame.size.height / 2 : frame.size.height / 2
        let centerY = basisY + offsetY
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: [],
                       animations: {   [unowned self] in
                            self.center.y = centerY
                            if isVisible {
                                self.isHidden = !isVisible
                            }},
                       completion: { (finished) in
                            if finished {
                                if !isVisible {
                                    self.isHidden = !isVisible
                                }
                                completion?()
                                self.setNeedsDisplay()
                                self.layoutIfNeeded()
                            }
                        }
        )
        
    }
    
}















