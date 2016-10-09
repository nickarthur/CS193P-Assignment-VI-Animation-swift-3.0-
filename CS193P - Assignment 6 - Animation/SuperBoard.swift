//
//  SuperBoard.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 04/10/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

protocol BoardDelegate: class {
	func willClear(slot: BoardSquareView, with subview: UIView)
	func didFill(slot: BoardSquareView, with subview: UIView)
}

class SuperBoard: UIView, BoardDelegate {
	
	override func layoutSubviews() {
		let brickWide = squareSize.width + inset
		let brickHeight = squareSize.height + inset
		let baseCenter = CGPoint(x: inset + squareSize.width / 2, y: inset + squareSize.height / 2)
		for (index, view) in subviews.enumerated() {
			let centerV = CGPoint(x: baseCenter.x + CGFloat(index % squaresPerRow) * brickWide,
			                      y: baseCenter.y + CGFloat(index / squaresPerRow) * brickHeight)
			view.frame = CGRect(center: centerV, size: squareSize)
			paths["squareView_" + String(index)] = (view as? SquareView)
		}
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if let superview = newSuperview as? GameBoardDataSource, dataSource == nil
		{	dataSource = superview
		}
	}
	
	override var intrinsicContentSize: CGSize {
		guard dataSource != nil else { return frame.size }
		let width = squareSize.width * CGFloat(squaresPerRow) + CGFloat(squaresPerRow + 1) * inset
		let height = CGFloat(numberOfRows) * squareSize.height + CGFloat(numberOfRows + 1) * inset
		return CGSize(width: width, height: height)
	}
	
	weak var dataSource: GameBoardDataSource? {
		didSet {
			backgroundColor = boardColors["backGround"]
			cellValues = boardDimension(numberOfRows: numberOfRows, numberOfColumns: squaresPerRow)
			for index in 1...numberOfRows * squaresPerRow {
				let squareView = SquareView()
				squareView.typeOfSquare = cellValues == nil ? .source : cellValues![index] ?? .regular
				addSubview(squareView)
			}
		}
	}
	
	var squareSize: CGSize	{ return dataSource!.squareSize }
	var inset: CGFloat		{ return dataSource!.inset }
	var squaresPerRow: Int	{ return dataSource!.squaresPerRow }
	var numberOfRows: Int	{ return dataSource!.numberOfRows }

	weak var delegate: BoardDelegate?

	func willClear(slot: SquareView, with subview: UIView) {
		delegate?.willClear(slot: slot, with: subview)
	}
	
	func didFill(slot: SquareView, with subview: UIView) {
		delegate?.didFill(slot: slot, with: subview)
	}
	
	var cellValues: CellValues?
	
	func score() -> Int {
		return 0
	}
	
	var paths: [String: BoardSquareView] = [:]
}

class LetterSourceBoard: SuperBoard {

	override func willMove(toSuperview newSuperview: UIView?) {
		if let superView = newSuperview as? DynamicBehaviorDelegate, dataSource == nil
		{	dataSource = superView
			dynamicBehavior = superView.dynamicBehavior
		}
	}
	
	override var numberOfRows: Int {
		return dataSource?.topBoardNumberOfRows ?? 0
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		for (name, squareView) in paths {
			dynamicBehavior?.addBarrier(path: UIBezierPath(rect: squareView.frame), name: name)
		}
	}
	
	override func removeFromSuperview() {
		for (_, squareView) in paths {
			dynamicBehavior?.remove(item: squareView)
		}
		super.removeFromSuperview()
	}

	private var dynamicBehavior: DynamicBehavior?
}

class ScrabbleSuperBoard: SuperBoard {
		
	override func score() -> Int {
		var filledSquares: [Int: Int] = [:]
		guard let cellValues = cellValues else { return 0 }
		for view in self.subviews {
			for letterView in view.subviews {
				if let letterView = letterView as? LetterView {
					let squareView = letterView.superview as! BoardSquareView
					let index = (squareView.row-1) * squaresPerRow + squareView.column
					filledSquares[index] = letterValues[letterView.letter!]
				}
			}
		}
		var totalScore: Int = 0
		var wordMultiplier = 1
		var wordValue: [Int] = []
			{	willSet {
				if newValue == [] && wordValue.count > 1 {
					for letterValue in wordValue {
						totalScore += letterValue * wordMultiplier
					}
				}
				if newValue == [] { wordMultiplier = 1 }
			}
		}
		
		for direction in ["horizontal", "vertical"] {
			for row in 1...numberOfRows {
				for col in 1...squaresPerRow {
					let index = direction == "horizontal" ? (row-1) * squaresPerRow + col :
						(col-1) * numberOfRows + row
					if let letterValue = filledSquares[index] {
						let typeOfSquare = cellValues[index] ?? .regular
						switch typeOfSquare {
						case .dw, .tw:
							wordMultiplier = wordMultiplier == 1 ? typeOfSquare.value() :
								wordMultiplier + typeOfSquare.value()
							wordValue.append(letterValue)
						case .dl, .tl:
							wordValue.append(letterValue * typeOfSquare.value())
						default:
							wordValue.append(letterValue)
						}
					} else { wordValue = [] }
				}
				wordValue = []
			}
		}
		return totalScore
	}
}

class LetterTargetBoard: SuperBoard {
	
	override var squaresPerRow: Int	{ return dataSource!.letterBoardSquaresPerRow }
	override var numberOfRows: Int	{ return dataSource!.letterBoardNumberOfRows }
}

class ContainerForLetterTargetBoard: UIView {
	
	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if let superView = newSuperview as? GameBoardDataSource
		{
			board.dataSource = superView
			addSubview(board)
			addSubview(buttons.left)
			addSubview(buttons.right)
		}
	}
	
	override func layoutSubviews() {
		let centerBoard = CGPoint(x: bounds.midX, y: bounds.midY)
		board.frame = CGRect(center: centerBoard, size: board.intrinsicContentSize)
		layer.cornerRadius = frame.height / 2
		backgroundColor = letterBoardColors["backGround"]
		
		let leftButtonCenter = CGPoint(x: bounds.height / 2, y: bounds.height / 2)
		let rightButtonCenter = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
		let buttonSize = CGSize(width: bounds.height * 0.9, height: bounds.height * 0.9)
		buttons.left.layer.cornerRadius = buttonSize.height / 2
		buttons.right.layer.cornerRadius = buttonSize.height / 2
		buttons.left.frame = CGRect(center: leftButtonCenter, size: buttonSize)
		buttons.right.frame = CGRect(center: rightButtonCenter, size: buttonSize)
		print("ContainerForLetterTargetBoard: override func layoutSubviews() ")
	}
	
	override var intrinsicContentSize: CGSize {
		guard board.dataSource != nil else { return frame.size }
		let width = board.intrinsicContentSize.width + 2 * board.squareSize.width + 3 * board.inset
		let height = board.intrinsicContentSize.height + 2 * board.inset
		return CGSize(width: width, height: height)
	}
	
	var centerY: CGFloat { return superview!.bounds.height - intrinsicContentSize.height / 2 }
	
	var board = LetterTargetBoard()
	var buttons = Buttons()
	
	struct Buttons {
		var left = UIButton()
		var right = UIButton()
		
		init() {
			left.backgroundColor = letterBoardColors["leftButtonBG"]
			left.setImage(UIImage(named: "menu"), for: [])
			left.imageView?.clipsToBounds = true
			left.layer.masksToBounds = true
			right.backgroundColor = letterBoardColors["rightButtonBG"]
			right.setImage(UIImage(named: "pause"), for: [])
			right.imageView?.clipsToBounds = true
			right.layer.masksToBounds = true
		}
	}
	
	lazy var keysForSlots: [String] = {
		[unowned self] in
		let keys = self.board.paths.keys.sorted()
		return keys
		}()
	
	func firstEmptySlot(isFor view: LetterView) -> BoardSquareView? {
		for key in keysForSlots {
			if let slot = board.paths[key] , slot.isEmpty()
			{	slot.letterView = view
				return slot
			}
		}
		return nil
	}
}





















