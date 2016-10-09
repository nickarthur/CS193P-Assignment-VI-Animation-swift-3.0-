///////////////////////////////////////////////////////////////////////////////
//  BoardSquareView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 20/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit


typealias SquareView = BoardSquareView

class BoardSquareView: UIView {
	
	var typeOfSquare: BoardSquareType? {
		didSet {
			guard let sguareType = typeOfSquare else { return }
			self.backgroundColor = boardColors[sguareType.rawValue]
			switch sguareType {
			case .source:
				letterView = LetterView()
				self.addSubview(letterView!)
			case .regular: break
			default:
				label.text = sguareType.rawValue
				addSubview(label)
				setContraintsForLabel()
			}
		}
	}
	
	private func setContraintsForLabel() {
		label.widthAnchor.constraint(equalTo: widthAnchor,
		                             multiplier: 0.9, constant: 0).isActive = true
		label.heightAnchor.constraint(equalTo: heightAnchor,
		                              multiplier: 0.9, constant: 0).isActive = true
		label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
	
	var letterView: LetterView?
	var column: Int = 0		// no need for these
	var row: Int = 0		// no  "	"	 "
	
	lazy var label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = letterColors["tekst"]
		return label
	}()
	
	override func layoutSubviews() {
		label.font = UIFont(name: label.font.fontName,
		                    size: self.bounds.height * 0.45)
		// set letterView...
		letterView?.frame = CGRect(center: CGPoint(x: bounds.midX, y: bounds.midY), size: frame.size)
	}
	
	func isEmpty () -> Bool {
		return letterView == nil
	}
	
	override func willRemoveSubview(_ subview: UIView) {
		super.willRemoveSubview(subview)
		if let letterView = self.letterView , letterView === subview,
		let superview = self.superview as? BoardDelegate
		{	superview.willClear(slot: self, with: letterView)
			self.letterView = nil
		}
	}
	
	override func didAddSubview(_ subview: UIView) {
		super.didAddSubview(subview)
		if let letterView = subview as? LetterView,
			let superview = self.superview as? BoardDelegate
		{
			self.letterView = letterView
			superview.didFill(slot: self, with: letterView)
		}
	}
}


class LetterView: UIView {

	let letter: String? = {
		let letters = [String](letterValues.keys)
		return letters[Int.random(max: 26)]
	}()
	
	var letterValue: Int?  {
		guard self.letter != nil else { return nil }
		return letterValues[self.letter!]
	}
	
	private lazy var letterLabel: UILabel! = {
		let letterLabel = UILabel()
		letterLabel.translatesAutoresizingMaskIntoConstraints = false
		letterLabel.textAlignment = .center
		letterLabel.text = self.letter
		letterLabel.textColor = letterColors["tekst"]

		return letterLabel
	}()
	
	private lazy var letterValueLabel: UILabel! = {
		let letterLabel = UILabel()
		letterLabel.translatesAutoresizingMaskIntoConstraints = false
		letterLabel.textAlignment = .center
		letterLabel.text = String((self.letterValue ?? 0)!)
		letterLabel.textColor = letterColors["tekstValue"]
		letterLabel.font = UIFont(name: letterLabel.font.fontName,
		                          size: self.bounds.height * 0.26)
		return letterLabel
	}()
	
	override func layoutSubviews() {
		letterLabel.font = UIFont(name: letterLabel.font.fontName,
		                          size: self.bounds.height * 0.5)
		letterValueLabel.font = UIFont(name: letterLabel.font.fontName,
		                               size: self.bounds.height * 0.26)
		layer.cornerRadius = frame.width * 0.1
	}
	
	private func layoutConstraint(item: AnyObject, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(
			item: item,
			attribute: attribute,
			relatedBy: .equal,
			toItem: self,
			attribute: attribute,
			multiplier: multiplier,
			constant: constant
		)
	}
	
	override func willMove(toSuperview newSuperview: UIView?)  {
		localInit()
	}
	
	private func localInit() {
		layer.borderWidth = 2
		layer.borderColor = letterColors["border"]?.cgColor
		backgroundColor = letterColors["backGround"]
		
		self.addSubview(letterLabel)
		self.addSubview(letterValueLabel)
		setConstraintsForLabels()
	}
	
	private func setConstraintsForLabels() {
		self.addConstraints([
			layoutConstraint(item: letterLabel, attribute: .width, multiplier: 0.7, constant: 0),
			layoutConstraint(item: letterLabel, attribute: .height, multiplier: 0.8, constant: 0),
			layoutConstraint(item: letterLabel, attribute: .centerX, multiplier: 0.8, constant: 0),
			layoutConstraint(item: letterLabel, attribute: .centerY, multiplier: 1, constant: 0)
		])
		self.addConstraints([
			layoutConstraint(item: letterValueLabel, attribute: .width, multiplier: 0.3, constant: 0),
			layoutConstraint(item: letterValueLabel, attribute: .height, multiplier: 0.3, constant: 0),
			layoutConstraint(item: letterValueLabel, attribute: .centerX, multiplier: 1.5, constant: 0),
			layoutConstraint(item: letterValueLabel, attribute: .centerY, multiplier: 1.5, constant: 0)
		])
	}
	
}











