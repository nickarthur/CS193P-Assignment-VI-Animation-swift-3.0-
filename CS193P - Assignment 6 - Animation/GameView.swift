///////////////////////////////////////////////////////////////////////////////
//  GameView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 19/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

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
	var letterBoardBricksPerRow: Int  {
		return self.bricksPerRow - 2
	}
	
	@IBInspectable var mortar: CGFloat =  1.5 	{ didSet { setNeedsDisplay() } }
	@IBInspectable var ballRadius: CGFloat = 15	{ didSet { setNeedsDisplay() } }
	lazy var ballMaxRadius: CGFloat = self.bounds.width * 0.25
	lazy var ballMinRadius: CGFloat = self.bounds.width * 0.025

	let maxPushMagnitude: CGFloat = 2
	let minPushMagnitude: CGFloat = 1
	
	var squareSize: CGSize! {
		didSet {
			let sumOfMortar = CGFloat(self.bricksPerRow + 1) * self.mortar
			let brickWidth: CGFloat = (self.bounds.width - sumOfMortar) / CGFloat(self.bricksPerRow)
			let totalNumberOfRows = self.numberOfRows + self.topBoardNumberOfRows + self.letterBoardNumberOfRows
			let brickHeigth = self.bounds.height / CGFloat(totalNumberOfRows + 2)
			squareSize = CGSize(width: brickWidth, height: min(brickHeigth, brickWidth))
		}
	}
	
	struct LetterInTransit {
		var view: UIView
		var superView: UIView
	}
	private var movingLetter: LetterInTransit?
	
	func movePaddle(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			if let letterView = self.hitTest(p: recognizer.location(in: self)) as? LetterView
			{	movingLetter = LetterInTransit(view: letterView, superView: letterView.superview!)
				let locationInSuperView = letterView.convert(letterView.center, to: self)
				letterView.removeFromSuperview()
				letterView.center = locationInSuperView
				self.addSubview(letterView)
			}
		case .changed:
			if let movingLetter = movingLetter {
				movingLetter.view.center.translate(p: recognizer.translation(in: self))
			} else {
				paddle?.translationX = recognizer.translation(in: self)
			}
			recognizer.setTranslation(CGPoint.zero, in: self)
		default:
			if let movingLetter = movingLetter {
				let letterView = movingLetter.view
				letterView.removeFromSuperview()
				if let slot = self.hitTest(p: recognizer.location(in: self)) as? BoardSquareView
				, slot.isEmpty()  {
					letterView.center = slot.bounds.mid
					slot.addSubview(letterView)
				} else {
					self.addSubview(letterView)
					let slot = movingLetter.superView
					let locationInSuperView = slot.superview!.convert(slot.center, to: self)
					UIView.animate(withDuration: 1, delay: 0.25, options: .curveEaseIn, animations:
						{	[unowned letterView] in
							letterView.center = locationInSuperView
						})
					{ (completed) in
						if completed {
							letterView.removeFromSuperview()
							letterView.center = slot.bounds.mid
							slot.addSubview(letterView)
						}
					}
				}
				self.movingLetter = nil
				print(mainBoard.score())
			}
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
		let instantaneousPush: UIPushBehavior = {
			let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
			push.pushDirection = vector
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

	
	var topBoard: Board! {
		didSet {
			topBoard?.frame = frame
			topBoard?.squareSize = squareSize
			topBoard?.bricksPerRow = bricksPerRow
			topBoard?.numberOfRows = topBoardNumberOfRows
			topBoard?.mortar = mortar
		}
	}

	
	var mainBoard: ScrabbleBoard! {
		didSet {
			let origin: CGPoint = topBoard.frame.lowerLeft
			let height = bounds.height - (topBoard?.bounds.height ?? 0)
			mainBoard?.frame = CGRect(origin: origin,
			                          size: CGSize(width: bounds.width, height: height))
			mainBoard?.squareSize = squareSize
			mainBoard?.bricksPerRow = bricksPerRow
			mainBoard?.numberOfRows = numberOfRows
			mainBoard?.mortar = mortar
		}
	}
	
	var letterBoard: LetterBoard! {
		didSet {
			guard letterBoard != nil else { return }
			let height = self.squareSize.height
			let originX: CGFloat = self.squareSize.width + self.mortar
			let board = Board(frame: CGRect(origin: CGPoint(x: originX, y:  2) ,
			                                size: CGSize(width: 0, height: height)))
			board.squareSize = self.squareSize
			board.bricksPerRow = self.letterBoardBricksPerRow
			board.numberOfRows = self.letterBoardNumberOfRows
			board.mortar = self.mortar
			letterBoard.board = board
			let centerY: CGFloat = self.bounds.height - height / 2 - 5
			letterBoard.center = CGPoint(x: self.center.x, y: centerY)
			letterBoard.buttons?.right.addTarget(self, action: self.selectorRightButton,
			                                     for: .touchUpInside)
			letterBoard.buttons?.left.addTarget(self, action: self.selectorLeftButton,
			                                     for: .touchUpInside)
			paddle?.fromBottom += letterBoard.frame.height
		}
	}
	
	
	let selectorRightButton = #selector(handlePauseButton(button:))
	let selectorLeftButton = #selector(handleLeftButton(button:))
	
	func handlePauseButton(button: UIButton) {
		delegate?.onPauseGame(button: button)
	}
	
	func handleLeftButton(button: UIButton) {
		switch bricksPerRow {
		case 7: bricksPerRow = 9
		case 9: bricksPerRow = 7
		default: break
		}
	}
	
	
	var paddle: PaddleView! {
		didSet {
			paddle?.resetFrame(in: self.bounds)
			paddle?.delegate = self
		}
	}
	
	
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
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func InitializeBoard() {
		topBoard?.removeFromSuperview()
		mainBoard?.removeFromSuperview()
		letterBoard?.removeFromSuperview()
		paddle?.removeFromSuperview()
		
		paddle = PaddleView()
		addSubview(paddle)
		squareSize = CGSize()
		topBoard = Board()
		addSubview(topBoard)
		for (name, view) in topBoard.paths {
			ballBehavior.addBarrier(path: UIBezierPath(rect: view.frame), name: name)
		}
		
		mainBoard = ScrabbleBoard()
		addSubview(mainBoard)
		letterBoard = LetterBoard()
		addSubview(letterBoard)
		let ballRadius = squareSize.width / 3
		ball = BallImageView(center: self.center, radius: ballRadius)
	}
	
	override func layoutSubviews() {
	}
	
    override func draw(_ rect: CGRect) {
		InitializeBoard()
    }
	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
//		print("BEGAN item contact at", p)
		
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
//		print("END item contact")
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
//		print("BEGAN boundery contact", p)
		if 	let name = identifier as? String , name.hasPrefix("view_"),
			let view = topBoard.paths[identifier! as! String],
			let letterView = view.letterView,
			let slot = letterBoard.firstEmptySlot(isFor: letterView)
		{
			var locationInSuperView = letterView.convert(letterView.center, to: self)
			letterView.removeFromSuperview()
			letterView.center = locationInSuperView
			self.addSubview(letterView)
			locationInSuperView = slot.superview!.convert(slot.center, to: self)
			UIView.animate(withDuration: 1.5, delay: 0.2, options: .curveEaseIn, animations:
			{
				letterView.center = locationInSuperView
			})
			{	(completed) in
				if completed {
					letterView.removeFromSuperview()
					letterView.center = slot.bounds.mid
					slot.addSubview(letterView)
				}
			}
			topBoard.paths[identifier! as! String] = nil
			ballBehavior.collider.removeBoundary(withIdentifier: identifier!)
		}
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
//		print("END boundery contact")
	}

}
