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
    func animateTo(isVisible: Bool,
                   duration: TimeInterval = ToolBarAnimation.duration,
                   delay: TimeInterval = ToolBarAnimation.delay,
                   completion: (() -> Void)? = nil)
    {
        struct Busy {
            static var animating: Bool = false
        }

        guard isHidden == isVisible, !Busy.animating else { return }
        Busy.animating = !isVisible
        let translationY = isVisible ? -frame.height  : frame.height
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {   [unowned self] in
                            self.center.y += translationY
                            if isVisible {
                                self.isHidden = !isVisible
                            }},
                       completion: { [unowned self] in
                            if $0 {
                                if !isVisible {
                                    self.isHidden = !isVisible
                                }
                                completion?()
                                Busy.animating = false
                                self.setNeedsDisplay()
                                self.layoutIfNeeded()
                            }
                        })
    }
}

extension UIView {
    func shakeN(times: Int, degrees: CGFloat, duration: TimeInterval, delay: TimeInterval = 0, completion: (() -> Void)? = nil)
    {
        var rotationAngle = CGFloat(M_PI * 2) * degrees / 360
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: [], animations:
            {
                let interval = 1 / Double((times - 1))
                var relativeDuration = interval / 2
                var relativeStartTime: Double = 0.0
                var TimeLeftFromDuration = 1.0
                for n in 1...times {
                    
                    UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                                       relativeDuration: relativeDuration,
                                       animations: {
                        self.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    })
                    relativeStartTime += relativeDuration
                    TimeLeftFromDuration -= relativeDuration
                    relativeDuration = min(TimeLeftFromDuration, interval)
                    rotationAngle = n == times - 1 ? 0 : rotationAngle * -1

                }
            }, completion: { if $0 { completion?() } })
    }
}

extension UIViewController
{
    var contentViewController: UIViewController? {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        } else {
            return self
        }
    }
}















