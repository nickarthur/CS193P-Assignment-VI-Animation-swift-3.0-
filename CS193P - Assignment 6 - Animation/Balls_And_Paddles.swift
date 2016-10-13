///////////////////////////////////////////////////////////////////////////////
//  Balls_And_Paddles.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 23/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

//@IBDesignable
class BallImageView: UIImageView {
	override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
		return .ellipse
	}
	
	override func willMove(toSuperview newSuperview: UIView?)
	{	super.willMove(toSuperview: newSuperview)
		if let superview = newSuperview as? BallDataSource
		{
			dataSource = superview
		}
	}
	
	var dynamicBehaviorIsActive = false {
		didSet {
			if dynamicBehaviorIsActive && !oldValue {
				dataSource?.dynamicBehavior.add(item: self)
			} else if !dynamicBehaviorIsActive && oldValue {
				dataSource?.dynamicBehavior.remove(item: self)
			}
		}
	}
	
	override func removeFromSuperview() {
		if dynamicBehaviorIsActive {
			dataSource?.dynamicBehavior.remove(item: self)
			dynamicBehaviorIsActive = false
		}
		super.removeFromSuperview()
	}
	
	private var radius: CGFloat! { return dataSource?.ballRadius ?? 0 }
	weak var dataSource: BallDataSource?

	var contentSize: CGSize {
		self.layer.cornerRadius = radius
		return CGSize(width: radius * 2, height: radius * 2)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	override init(image: UIImage?) {
		super.init(image: image)
	}
}

protocol TranslationPaddle {
	func dimensionsHaveChanged(paddle: PaddleView)
}

class PaddleView: UIView {
	override func willMove(toSuperview newSuperview: UIView?) {
		backgroundColor = color
		if let superview = newSuperview as? TranslationPaddle {
			delegate = superview
		}
	}
	
	var delegate: TranslationPaddle?

	var heigthPercentage: CGFloat = PaddleConstants.HeigthPercentage

	var widthPercentage: CGFloat = PaddleConstants.WidthPercentage
	{	didSet {
			widthPercentage = max(min(widthPercentage, maxWidth), minWidth)
		}
	}
	
	override var intrinsicContentSize: CGSize {
		guard let superview = superview else { return frame.size }
		let width = superview.frame.width * widthPercentage / 100
		let height = superview.frame.height * heigthPercentage / 100
		return CGSize(width: width, height: height)
	}
	
	var fullContentSize: CGSize {
		guard let superview = superview else { return frame.size }
		let width = superview.frame.width
		let height = superview.frame.height * heigthPercentage / 100
		return CGSize(width: width, height: height)
	}
	
	private let maxWidth: CGFloat = PaddleConstants.MaxWidthPercentage
	private let minWidth: CGFloat = PaddleConstants.MinWidthPercentage
		
	var fromBottom: CGFloat = PaddleConstants.FromBottom {
		didSet {
			fromBottom += PaddleConstants.FromBottom
		}
	}
	
	var centerY: CGFloat {
		return superview!.bounds.height - fromBottom - intrinsicContentSize.height / 2
	}
	
	var color: UIColor = PaddleConstants.Color
	{	didSet { self.backgroundColor = color } }
	
	
	override func layoutSubviews() {
		delegate?.dimensionsHaveChanged(paddle: self)
	}
	
	var storedRalativeXPosition: CGFloat? 
	
    var translationX: CGFloat = 0 {
        didSet {
			if let superview = self.superview {
				let minX = bounds.width / 2
				let maxX = superview.bounds.width - bounds.width / 2
				center.x = max(min(center.x + translationX, maxX), minX)
				delegate?.dimensionsHaveChanged(paddle: self)
				storedRalativeXPosition = center.x / superview.bounds.width
			}
		}
    }
}










