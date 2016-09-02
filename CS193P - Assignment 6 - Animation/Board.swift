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
	
	var paths: [String: BoardSquareView] = [:]
	
	
	override func willRemoveSubview(_ subview: UIView) {
		super.willRemoveSubview(subview)
		
	}
}

class LetterBoard: UIView {
	
	var board: Board! {
		didSet {
			guard let board = self.board else { return }
			let letterBoardHeigth = board.frame.height + 4
			let LetterBoardWidth = board.frame.width + 1.5 * letterBoardHeigth
			let rect = CGRect(origin: self.frame.origin,
			                  size: CGSize(width: LetterBoardWidth, height: letterBoardHeigth))
			self.frame = rect
			self.layer.cornerRadius = board.frame.height / 2
			self.backgroundColor = #colorLiteral(red: 0.4, green: 0.2, blue: 0, alpha: 1)
			self.addSubview(board)
		}
	}
	
	lazy var slots: [Int: BoardSquareView] = {
		[unowned self] in
		var slots = [Int: BoardSquareView]()
		var index: Int = 1
		for squareView in self.board.paths.values {
			slots[index] = squareView
			index += 1
		}
		return slots
	}()
	
	func firstEmptySlot(isFor view: LetterView) -> BoardSquareView? {
		for (_, square) in slots {
			if square.isEmpty() {
				square.letterView = view
				return square
			}
		}
		return nil
	}
	
}

















