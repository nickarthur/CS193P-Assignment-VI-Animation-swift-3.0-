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

enum PaddleConstants {
	static var WidthToHeightFactor: CGFloat = 12
	static var WidthPercentage: CGFloat = 40
	static let MaxWidthPercentage: CGFloat = 50
	static let MinWidthPercentage: CGFloat = 10
	static var FromBottom: CGFloat = 5
	static var Color: UIColor = UIColor.blue
}

protocol TranslatePaddle {
	func dimensionsHaveChanged(paddle: PaddleView)
}

class PaddleView: UIView {
	override func willMove(toSuperview newSuperview: UIView?) {
		if let superview = newSuperview {
			resetFrame(in: superview.bounds)
			referenceFrame = nil
		}
	}
	
	var delegate: TranslatePaddle?

	var WidthToHeightFactor: CGFloat = PaddleConstants.WidthToHeightFactor
	{	didSet { resetFrame() } }

	var widthPercentage: CGFloat = PaddleConstants.WidthPercentage
	{	didSet {
			widthPercentage = max(min(widthPercentage, maxWidth), minWidth)
			resetFrame()
		}
	}
	
	private func resetFrame() {
		guard let frame = self.superview?.frame ?? referenceFrame else { return }
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
				                       y: center.y)
				
			} else {
				super.center = newValue
			}
			delegate?.dimensionsHaveChanged(paddle: self)
		}
	}
	
	var translationX: CGPoint? {
		didSet {
			guard translationX != nil else { return }
			center = CGPoint(x: center.x + translationX!.x,
			                 y: center.y)
		}
	}
	
	private var referenceFrame: CGRect?
	
	override init(frame: CGRect)
	{	super.init(frame: frame)
		self.backgroundColor = color
		referenceFrame = frame
		resetFrame()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = color
	}
}










