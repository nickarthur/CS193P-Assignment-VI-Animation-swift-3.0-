//
//  BrickView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 20/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class BoardSquareView: UIView {
	
	var typeOfSquare: BoardSquareType? {
		didSet {
			guard let sguareType = typeOfSquare else { return }
			self.backgroundColor = boardColors[sguareType.rawValue]
			switch sguareType {
			case .source:
				letterView = LetterView(frame: self.bounds)
				self.addSubview(letterView!)
			case .regular: break
			default:
				label.text = sguareType.rawValue
				addSubview(label)
				label.widthAnchor.constraint(equalTo: self.widthAnchor,
				                             multiplier: 0.9, constant: 0).isActive = true
				label.heightAnchor.constraint(equalTo: self.heightAnchor,
				                              multiplier: 0.9, constant: 0).isActive = true
				label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
			}
		}
	}
	var letterView: LetterView?
	
	lazy var label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		label.font = UIFont(name: label.font.fontName,
		                    size: self.bounds.height * 0.45)
		return label
	}()
	
	func isEmpty () -> Bool {
		return letterView == nil
	}
	
	override func willRemoveSubview(_ subview: UIView) {
		super.willRemoveSubview(subview) // ??
		if let letterView = self.letterView where letterView === subview {
			self.letterView = nil
			print("removed LetterView....")
		}
	}
	
	override func didAddSubview(_ subview: UIView) {
		if let letterView = subview as? LetterView {
			self.letterView = letterView
//			letterView.center = self.center
			print("added + CENTERED letterview")
		}
	}
}


class LetterView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		localInit(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		localInit(frame: frame)
	}
	
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
		letterLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		letterLabel.font = UIFont(name: letterLabel.font.fontName,
		                          size: self.bounds.height * 0.5)
		return letterLabel
	}()
	
	private lazy var letterValueLabel: UILabel! = {
		let letterLabel = UILabel()
		letterLabel.translatesAutoresizingMaskIntoConstraints = false
		letterLabel.textAlignment = .center
		letterLabel.text = String((self.letterValue ?? 0)!)
		letterLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
		letterLabel.font = UIFont(name: letterLabel.font.fontName,
		                          size: self.bounds.height * 0.26)
		return letterLabel
	}()
	
	
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
	
	private func localInit(frame: CGRect) {
		layer.cornerRadius = frame.width * 0.1
		layer.borderWidth = 2
		layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
		backgroundColor = #colorLiteral(red: 0.7978851795, green: 0.7254901961, blue: 0.5294117647, alpha: 1)
		
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











