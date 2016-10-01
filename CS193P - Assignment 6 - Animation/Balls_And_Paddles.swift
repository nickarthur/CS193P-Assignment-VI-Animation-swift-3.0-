///////////////////////////////////////////////////////////////////////////////
//  Balls_And_Paddles.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 23/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

@IBDesignable
class BallImageView: UIImageView {
	override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
		return .ellipse
	}
	
    @IBInspectable var imageName: String? {
        didSet {
            if let imageName = imageName, let image = UIImage(named: imageName) {
                let radius = self.frame.size.width / 2
                self.image = image
                self.layer.cornerRadius = radius
            }
        }
    }
    
    convenience init(center: CGPoint, radius: CGFloat, imageName: String = "ball")
	{	let rect = CGRect(center: center,
	 	                  size: CGSize(width: radius * 2, height: radius * 2))
		self.init(frame: rect)
		self.image = UIImage(named: imageName)
		self.layer.cornerRadius = radius
	}
}

protocol TranslationPaddle {
	func dimensionsHaveChanged(paddle: PaddleView)
}

class PaddleView: UIView {
	override func willMove(toSuperview newSuperview: UIView?) {
		if let superview = newSuperview {
			resetFrame(in: superview.bounds)
		}
	}
	
	var delegate: TranslationPaddle?

	var WidthToHeightFactor: CGFloat = PaddleConstants.WidthToHeightFactor
	{	didSet { resetFrame() } }

	var widthPercentage: CGFloat = PaddleConstants.WidthPercentage
	{	didSet {
			widthPercentage = max(min(widthPercentage, maxWidth), minWidth)
			resetFrame()
		}
	}
	
	private func resetFrame() {
		guard let frame = self.superview?.frame else { return }
		resetFrame(in: frame)
	}
	
	func resetFrame(in frame: CGRect)
	{	let width = frame.width * widthPercentage / 100
		let height = width / WidthToHeightFactor
		let origin = CGPoint(x: frame.width / 2 - width / 2,
		                     y: frame.height - height - fromBottom)
		let cgRect = CGRect(origin: origin, size: CGSize(width: width, height: height))
		self.frame = cgRect
		delegate?.dimensionsHaveChanged(paddle: self)
	}
	
	private let maxWidth: CGFloat = PaddleConstants.MaxWidthPercentage
	private let minWidth: CGFloat = PaddleConstants.MinWidthPercentage
		
	var fromBottom: CGFloat = PaddleConstants.FromBottom {
		didSet { resetFrame() }
	}
	
	var color: UIColor = PaddleConstants.Color
	{	didSet { self.backgroundColor = color } }
	
	override var center: CGPoint
	{	get {	return super.center  }
		set
		{	if let superview = self.superview {
				let minX = bounds.width / 2
				let maxX = superview.bounds.width - bounds.width / 2
				super.center = CGPoint(x: max(min(newValue.x, maxX), minX),
				                       y: newValue.y)
				
			} else {
				super.center = newValue
			}
			delegate?.dimensionsHaveChanged(paddle: self)
		}
	}
    
    var translationX: CGFloat = 0 {
        didSet {  center = CGPoint(x: center.x + translationX, y: center.y) }
    }
    	
	override init(frame: CGRect)
	{	super.init(frame: frame)
		self.backgroundColor = color
        resetFrame(in: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = color
	}
}










