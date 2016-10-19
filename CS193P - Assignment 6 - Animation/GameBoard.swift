///////////////////////////////////////////////////////////////////////////////
//  GameBoard.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 04/10/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

protocol BoardDelegate: class {
	func willClear(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?)
	func didFill(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?)
	func viewFor(board: GameBoard, at slot: SquareView) -> UIView?
}

enum TypeOfBoard {
	case gameBoard
	case letterSourceBoard
	case scrabbleBoard
	case letterTargetBoard
}

class GameBoard: UIView, BoardDelegate {
	var typeOfBoard: TypeOfBoard { return .gameBoard }
	
	override func layoutSubviews() {
		let brickWide = squareSize.width + inset
		let brickHeight = squareSize.height + inset
		let baseCenter = CGPoint(x: inset + squareSize.width / 2, y: inset + squareSize.height / 2)
		for (index, view) in subviews.enumerated() {
			let centerV = CGPoint(x: baseCenter.x + CGFloat(index % squaresPerRow) * brickWide,
			                      y: baseCenter.y + CGFloat(index / squaresPerRow) * brickHeight)
			view.frame = CGRect(center: centerV, size: squareSize)
			paths[((view as? SquareView)?.id)!] = (view as? SquareView)
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
	
	private lazy var key: String = {
		let key = Int.random(max: 100000)
		return String(key)  + "_"
	}()
	
	weak var dataSource: GameBoardDataSource? {
		didSet {
			backgroundColor = boardColors["backGround"]
			cellValues = boardDimension(numberOfRows: numberOfRows, numberOfColumns: squaresPerRow)
			for index in 1...numberOfRows * squaresPerRow {
				let squareView = SquareView()
				squareView.typeOfSquare = cellValues?[index] ?? .regular
				squareView.id = "squareView_" + key + String(index - 1)
				if let contentView = viewFor(board: self, at: squareView) {
					squareView.letterView = contentView as? LetterView
					squareView.addSubview(contentView)
				}
				addSubview(squareView)
			}
		}
	}
	
	var squareSize: CGSize	{ return dataSource!.squareSize }
	var inset: CGFloat		{ return dataSource!.inset }
	var squaresPerRow: Int	{ return dataSource!.squaresPerRow }
	var numberOfRows: Int	{ return dataSource!.numberOfRows }

	weak var delegate: BoardDelegate?

	func willClear(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?) {
		delegate?.willClear(slot: slot, with: subview, onGameBoard: self)
		print("willClear is called", typeOfBoard, delegate)
	}
	
	func didFill(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?) {
		delegate?.didFill(slot: slot, with: subview, onGameBoard: self)
		print("didFill is called", typeOfBoard, delegate)
	}
	
	func viewFor(board: GameBoard, at slot: SquareView) -> UIView? {
		print(board.typeOfBoard, " id: ", slot.id)
		return delegate?.viewFor(board: self, at: slot)
	}
	
	var cellValues: CellValues?
	
	func score() -> Int {
		return 0
	}
	
	var paths: [String: SquareView] = [:]
}

class DynamicBehaviorGameBoard: GameBoard {
	
	var dynamicBehavior: DynamicBehavior?

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if let dataSource = dataSource as? DynamicBehaviorDelegate
		{
			dynamicBehavior = dataSource.dynamicBehavior
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		for (name, squareView) in paths {
			if squareView.letterView != nil {
				let frameInSuperView = self.convert(squareView.frame, to: superview)
				dynamicBehavior?.addBarrier(path: UIBezierPath(rect: frameInSuperView), name: name)
				print("layoutSubviews ", squareView.id!, "  ",frameInSuperView)
			}
		}
	}
	
	override func willClear(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?) {
		super.willClear(slot: slot, with: subview, onGameBoard: onGameBoard)
		dynamicBehavior?.collider.removeBoundary(withIdentifier: slot.id! as NSCopying)
		paths[slot.id!] = nil
	}
	
	override func didFill(slot: SquareView, with subview: UIView, onGameBoard: GameBoard?) {
		super.didFill(slot: slot, with: subview, onGameBoard: self)
		let frameInSuperView = self.convert(slot.frame, to: superview)
		dynamicBehavior?.addBarrier(path: UIBezierPath(rect: frameInSuperView), name: slot.id!)
		print("didFill ", slot.id!)
	}
	
	override func removeFromSuperview() {
		for (_, slot) in paths {
			dynamicBehavior?.collider.removeBoundary(withIdentifier: slot.id! as NSCopying)
		}
		super.removeFromSuperview()
	}
}

class LetterSourceBoard: DynamicBehaviorGameBoard {
	override var typeOfBoard: TypeOfBoard { return .letterSourceBoard }

	override var numberOfRows: Int { return dataSource?.topBoardNumberOfRows ?? 0 }
	
	override func viewFor(board: GameBoard, at slot: SquareView) -> UIView? {
		return LetterView()
	}
}

class ScrabbleBoard: DynamicBehaviorGameBoard {
	override var typeOfBoard: TypeOfBoard { return .scrabbleBoard }
	

	 override func score() -> Int {
		var filledSquares: [Int: Int] = [:]
		guard let cellValues = cellValues else { return 0 }
		for (index, view) in self.subviews.enumerated() {
			for letterView in view.subviews {
				if let letterView = letterView as? LetterView {
					let squareView = letterView.superview as! SquareView
					filledSquares[index + 1] = letterValues[letterView.letter!]
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

class LetterTargetBoard: GameBoard {
	override var typeOfBoard: TypeOfBoard { return .letterTargetBoard }
	
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
	
	func firstEmptySlot(isFor view: LetterView) -> SquareView? {
		for key in keysForSlots {
			if let slot = board.paths[key] , slot.isEmpty()
			{	slot.letterView = view
				return slot
			}
		}
		return nil
	}
}





















