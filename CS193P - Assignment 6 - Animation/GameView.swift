///////////////////////////////////////////////////////////////////////////////
//  GameView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 19/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

protocol GameViewDelegate: class {
	func pauseGame()
	func onPauseGame(button: UIButton)
	func resumeGame()
	func onResume()
	func endGame()
}

@IBDesignable
class GameView: UIView, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, TranslatePaddle {

	weak var delegate: GameViewDelegate?
	
	@IBInspectable var bricksPerRow: Int = 9 { didSet { setNeedsDisplay() } }
	@IBInspectable var numberOfRows: Int {
		get { return bricksPerRow }
		set { bricksPerRow = newValue}
	}
	let topBoardNumberOfRows: Int = 2
	let letterBoardNumberOfRows: Int = 1
	let letterBoardBricksPerRow: Int = 5
	
	@IBInspectable var mortar: CGFloat =  1.5 { didSet { setNeedsDisplay() } }
	
	@IBInspectable var ballRadius: CGFloat = 15 { didSet { setNeedsDisplay() } }
	lazy var ballMaxRadius: CGFloat = self.bounds.width * 0.25
	lazy var ballMinRadius: CGFloat = self.bounds.width * 0.025

	let maxPushMagnitude: CGFloat = 2
	let minPushMagnitude: CGFloat = 1
	
	lazy var squareSize: CGSize = { [unowned self] in
		let sumOfMortar = CGFloat(self.bricksPerRow + 1) * self.mortar
		let brickWidth: CGFloat = (self.bounds.width - sumOfMortar) / CGFloat(self.bricksPerRow)
		let totalNumberOfRows = self.numberOfRows + self.topBoardNumberOfRows + self.letterBoardNumberOfRows
		let brickHeigth = self.bounds.height / CGFloat(totalNumberOfRows + 2)
	 	return CGSize(width: brickWidth, height: min(brickHeigth, brickWidth))
	}()
	

	func movePaddle(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began: break
		case .changed:
			paddle.translationX = recognizer.translation(in: self)
			recognizer.setTranslation(CGPoint.zero, in: self)
		default: break
		}
	}
	
	func dimensionsHaveChanged(paddle: PaddleView) {
		let path = UIBezierPath(rect: paddle.frame)
		ballBehavior.addBarrier(path: path, name: "paddle")
	}
	
	func handleTap(recognizer: UITapGestureRecognizer) {
		let location = recognizer.location(in: self)
		let vector = CGVector(dx: location.x - ball.center.x,
		                      dy: location.y - self.bounds.height)
		print("you tapped dx: ", vector.dx, " dy: ", vector.dy)
		let instantaneousPush: UIPushBehavior = {
			let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
			push.pushDirection = vector // CGVector(dx: 1, dy: -10)
			push.magnitude = max(min(vector.dy / -120, maxPushMagnitude), minPushMagnitude)
			push.action = { [unowned push] in
				push.dynamicAnimator!.removeBehavior(push)
			}
			return push
		}()
		self.animator.addBehavior(instantaneousPush)
		delegate?.onResume()

	}
	
	private lazy var animator: UIDynamicAnimator = {
		[unowned self] in
		let animator = UIDynamicAnimator(referenceView: self)
		animator.delegate = self
		return animator
	}()
	
	var animating: Bool = false {
		didSet {
			if animating {
				animator.addBehavior(ballBehavior)
			} else {
				animator.removeBehavior(ballBehavior)
			}
		}
	}
	
	private lazy var ballBehavior: DynamicBehavior = {
		[unowned self] in
		let dynamicBehavior = DynamicBehavior()
		dynamicBehavior.collider.collisionDelegate = self
		return dynamicBehavior
	}()
	

	private lazy var topBoard: Board = {
		[unowned self] in
		let board = Board(frame: self.frame)
		board.squareSize = self.squareSize
		board.bricksPerRow = self.bricksPerRow
		board.numberOfRows = self.topBoardNumberOfRows
		board.mortar = self.mortar
		return board
	}()
	
	private lazy var mainBoard: Board = {
		[unowned self] in
		let origin: CGPoint = self.topBoard.frame.lowerLeft
		let height = self.bounds.height - self.topBoard.bounds.height
		let board = Board(frame: CGRect(origin: origin,
		                                size: CGSize(width: self.bounds.width, height: height)))
		board.squareSize = self.squareSize
		board.bricksPerRow = self.bricksPerRow
		board.numberOfRows = self.numberOfRows
		board.mortar = self.mortar
		return board
	}()
	
	private lazy var letterBoard: LetterBoard = {
		[unowned self, unowned paddle = self.paddle] in
		let letterBoard = LetterBoard()
		let height = self.squareSize.height
		let originX: CGFloat = height / 2 + self.mortar
		let board = Board(frame: CGRect(origin: CGPoint(x: originX, y:  2) ,
		                                size: CGSize(width: 0, height: height)))
		board.squareSize = self.squareSize
		board.bricksPerRow = self.letterBoardBricksPerRow
		board.numberOfRows = self.letterBoardNumberOfRows
		board.mortar = self.mortar
		letterBoard.board = board
		let centerY: CGFloat = self.bounds.height - height / 2 - 5
		letterBoard.center = CGPoint(x: self.center.x, y: centerY)
		paddle.fromBottom += letterBoard.frame.height
		return letterBoard
	}()
	
	private lazy var pauseButton: UIButton = {
		[unowned self] in
		let height = self.letterBoard.board!.frame.height
		let centerX = self.letterBoard.bounds.width - self.letterBoard.bounds.height / 2
		let centerY = self.letterBoard.bounds.height / 2
		let button = UIButton(frame: CGRect(center: CGPoint(x: centerX, y: centerY),
		                                    size: CGSize(width: height, height: height)))
		button.layer.cornerRadius = height / 2
		button.backgroundColor = #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1)
		button.setImage(UIImage(named: "pause"), for: [])
		let selector = #selector(self.handlePauseButton(button:))
		button.addTarget(self, action: selector, for: .touchUpInside)
		return button
	}()

	func handlePauseButton(button: UIButton) {
		delegate?.onPauseGame(button: button)
	}
	
	
	private lazy var paddle: PaddleView = {
		[unowned self] in
		let paddle = PaddleView(frame: self.bounds)
		paddle.delegate = self
		return paddle
	}()
	
	
	private var ball: BallImageView! {
		willSet {
			if let ball = ball {
				ballBehavior.remove(item: ball)
				ball.removeFromSuperview()
			}
		}
		didSet {
			addSubview(ball)
			ballBehavior.add(item: ball)
			
//			addSubview(attachedBall)
//			animator.addBehavior(UIAttachmentBehavior.pinAttachment(with: ball, attachedTo: attachedBall, attachmentAnchor: CGPoint(x: ball.frame.origin.x, y:  ball.frame.origin.y + 120)))
//			animator.addBehavior( {
//				let attachment = UIAttachmentBehavior(item: attachedBall, attachedToAnchor: self.center)
//				attachment.length = 10
//				attachment.damping = 5
//				return attachment
//				}()
//			)
//			animator.addBehavior( {
//				let snap = UISnapBehavior(item: attachedBall, snapTo: self.center)
//				snap.damping = 0.1
//				return snap
//			}() )
		}
	}
//	
//	private lazy var attachedBall: BallImageView = {
//		var p: CGPoint = self.center
//		let ball = BallImageView(center: p, radius: 15)
//		return ball
//	}()
	
    override func draw(_ rect: CGRect) {
		for view in subviews {
			if view is BoardSquareView {
				view.removeFromSuperview()
			}
		}
		addSubview(topBoard)
		for (name, view) in topBoard.paths {
			ballBehavior.addBarrier(path: UIBezierPath(rect: view.frame), name: name)
		}
		addSubview(mainBoard)
		addSubview(letterBoard)
		letterBoard.addSubview(pauseButton)
		addSubview(paddle)
		ball = BallImageView(center: self.center)
		
    }
	
	

	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
		print("BEGAN item contact at", p)
		
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
		print("END item contact")
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
		print("BEGAN boundery contact", p)
		if let name = identifier as? String {
			if name.hasPrefix("view_") {
				ballBehavior.collider.removeBoundary(withIdentifier: identifier!)
				if let view = topBoard.paths[identifier! as! String],
				let letterView = view.letterView,
				let slot = letterBoard.firstEmptySlot(isFor: letterView)
				{
					var centerInSuperView = letterView.convert(letterView.center, to: self)
					letterView.removeFromSuperview()
					letterView.center = centerInSuperView
					self.addSubview(letterView)
					centerInSuperView = slot.superview!.convert(slot.center, to: self)
					UIView.animate(withDuration: 3, delay: 0.5, options: .curveEaseIn, animations:
					{
						letterView.center = centerInSuperView
					})
					{	(completed) in
						if completed {
							letterView.removeFromSuperview()
							letterView.center = slot.bounds.mid
							slot.addSubview(letterView)
						}
					}
					topBoard.paths[identifier! as! String] = nil
				}
			}
		}
		
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
		print("END boundery contact")
	}

}
