//
//  NamedBezierPathsView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 21/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class Board: UIView {
	override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
		return .path
	}
	
	override var collisionBoundingPath: UIBezierPath {
		let path = UIBezierPath(rect: self.frame)
		return path
	}
	
	var squareSize: CGSize? { didSet { setupBoard() } }
	var mortar: CGFloat? { didSet { setupBoard() } }
	var bricksPerRow: Int? { didSet { setupBoard() } }
	var numberOfRows: Int? { didSet { setupBoard() } }
	
	private func setupBoard()
	{	guard
			let mortar = self.mortar,
			let bricksPerRow = self.bricksPerRow,
			let numberOfRows = self.numberOfRows,
			let squareSize = self.squareSize
		else 	{ return }
		
		var boardWidth = self.frame.width
		if boardWidth == 0 {
			boardWidth = squareSize.width * CGFloat(bricksPerRow) +
				CGFloat(bricksPerRow + 1) * mortar
		}
		let boardHeight: CGFloat = CGFloat(numberOfRows) * squareSize.height +
			CGFloat(numberOfRows + 1) * mortar
		let rect = CGRect(origin: self.frame.origin,
		                  size: CGSize(width: boardWidth, height: boardHeight))
		self.frame = rect
		self.backgroundColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
		cellValues = boardDimension(numberOfRows: numberOfRows, numberOfColumns: bricksPerRow)
		setupSquares()
	}
	
	private var cellValues: CellValues?
	
	private func setupSquares() {
		let brickWide = self.squareSize!.width + self.mortar!
		let brickHeight = self.squareSize!.height + self.mortar!
		var brickOrigin = CGPoint(x: self.mortar!, y: self.mortar!)
		
		for row in 1...numberOfRows! {
			for col in 1...bricksPerRow! {
				let frame = CGRect(origin: brickOrigin, size: squareSize!)
				let squareView = BoardSquareView(frame: frame)
				squareView.column = col
				squareView.row = row
				if cellValues != nil {
					squareView.typeOfSquare = cellValues![(row-1) * bricksPerRow! + col] ?? .regular
				} else {
					squareView.typeOfSquare = .source
				}
				self.addSubview(squareView)
				paths["view_" + String(col) + "_" + String(row)] = squareView
				brickOrigin.x += brickWide
			}
			brickOrigin.x = mortar!
			brickOrigin.y += brickHeight
		}
	}
	
	func score() -> Int {
		var filledSquares: [Int: Int] = [:]
		guard let cellValues = cellValues else { return 0 }
		for view in self.subviews {
			for letterView in view.subviews {
				if let letterView = letterView as? LetterView {
					let squareView = letterView.superview as! BoardSquareView
					let index = (squareView.row-1) * bricksPerRow! + squareView.column
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
					wordMultiplier = 1
				}
			}
		}
		
		for direction in ["horizontal", "vertical"] {
			for row in 1...numberOfRows! {
				for col in 1...bricksPerRow! {
					let index = direction == "horizontal" ? (row-1) * bricksPerRow! + col :
															(col-1) * numberOfRows! + row
					if let letterValue = filledSquares[index] {
						let typeOfSquare = cellValues[index] ?? .regular
							switch typeOfSquare {
							case .dw, .tw:
								wordMultiplier = typeOfSquare.value()
								wordValue.append(letterValue)
							case .dl, .tl:
								wordValue.append(letterValue * typeOfSquare.value())
							default:
								wordValue.append(letterValue)
							}
					} else { wordValue = [] }
				}
			}
			wordValue = []
		}
		return totalScore
	}
	
	var paths: [String: BoardSquareView] = [:]
	
	
	override func willRemoveSubview(_ subview: UIView) {
		super.willRemoveSubview(subview)
		
	}
}

class LetterBoard: UIView {
	
	var board: Board! {
		didSet {
			guard let board = self.board else { return }
			let letterBoardHeigth = board.frame.height + 2 * board.mortar!
			let LetterBoardWidth = board.frame.width + 2 * board.squareSize!.width + 3 * board.mortar! // letterBoardHeigth
			let rect = CGRect(origin: self.frame.origin,
			                  size: CGSize(width: LetterBoardWidth, height: letterBoardHeigth))
			self.frame = rect
			self.layer.cornerRadius = letterBoardHeigth / 2
			self.backgroundColor = #colorLiteral(red: 0.4, green: 0.2, blue: 0, alpha: 1)
			setupButtons()
			self.addSubview(board)
		}
	}
	
	struct Buttons {
		var left: UIButton
		var right: UIButton
		init(leftFrame: CGRect, rightFrame: CGRect) {
			left = UIButton(frame: leftFrame)
			right = UIButton(frame: rightFrame)
			left.layer.cornerRadius = leftFrame.height / 2
			right.layer.cornerRadius = rightFrame.height / 2
			left.backgroundColor = #colorLiteral(red: 0.1603052318, green: 0, blue: 0.8195188642, alpha: 1)
			right.backgroundColor = #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1)
			right.setImage(UIImage(named: "pause"), for: [])
		}
	}
	
	var buttons: Buttons?
	
	func setupButtons() {
		let leftCenter = CGPoint(x: bounds.height / 2, y: bounds.height / 2)
		let rightCenter = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
		let buttonSize = CGSize(width: board.frame.height * 0.9 , height: board.frame.height * 0.9 )
		let leftFrame = CGRect(center: leftCenter, size: buttonSize)
		let rightFrame = CGRect(center: rightCenter, size: buttonSize)
		self.buttons = Buttons(leftFrame: leftFrame, rightFrame: rightFrame)
		self.addSubview(buttons!.left)
		self.addSubview(buttons!.right)
	}
	
	
	lazy var keysForSlots: [String] = {
		[unowned self] in
		let keys = self.board.paths.keys.sorted()
		return keys
	}()
	
	func firstEmptySlot(isFor view: LetterView) -> BoardSquareView? {
		for key in keysForSlots {
			if let slot = self.board.paths[key] where slot.isEmpty()
			{	slot.letterView = view
				return slot
			}
		}
		return nil
	}
	
}

















