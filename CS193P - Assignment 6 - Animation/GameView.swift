///////////////////////////////////////////////////////////////////////////////
//  GameView.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 19/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

protocol GameViewDelegate: ControllerWithSettingsData {
	func onPauseGame(button: UIButton)
	func onResume()
    func onLeftButton(button: UIButton)
	var heigthOfTabBar: CGFloat { get }
}

protocol GameViewDataSource: class {
}

protocol GameBoardDataSource: class {
	var squaresPerRow: Int				{ get }
	var numberOfRows: Int				{ get }
	var topBoardNumberOfRows: Int		{ get }
	var letterBoardNumberOfRows: Int	{ get }
	var letterBoardSquaresPerRow: Int	{ get }
	var inset: CGFloat		{ get }
	var squareSize: CGSize!	{ get }
}

protocol DynamicBehaviorDelegate: GameBoardDataSource {
	var dynamicBehavior: DynamicBehavior { get }
}

protocol BallDataSource: class {
	var ballRadius: CGFloat { get }
	var dynamicBehavior: DynamicBehavior { get }
}

class GameView: UIView, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, TranslationPaddle, GameBoardDataSource, DynamicBehaviorDelegate, BallDataSource
{
	
	weak var dataSource: GameViewDataSource?
	weak var delegate: GameViewDelegate? {
		didSet {
			dynamicBehavior.itemBehavior.density = self.delegate!.density
			dynamicBehavior.gravity.gravityDirection = self.delegate!.gravityDirection
		}
	}
	

	var squaresPerRow: Int = 9 
	var numberOfRows: Int { return squaresPerRow }

	var topBoardNumberOfRows: Int = 2
	var letterBoardNumberOfRows: Int = 1
	var letterBoardSquaresPerRow: Int  { return squaresPerRow - 2 }
	
	var inset: CGFloat =  1.5 	{ didSet { setNeedsLayout() } }
	var squareWidthToBallRatio: CGFloat = 1 { didSet{ setNeedsLayout() } }
	
	var ballRadius: CGFloat  {
		return self.squareSize.width / (self.squareWidthToBallRatio * 2)
	}

	lazy var maxPushMagnitude: CGFloat = {
		return self.delegate?.maxPushMagnitude ?? Constants.maxPushMagnitude / 2
	}()
	
	var squareSize: CGSize! {
		didSet {
			var sumOfInsets = CGFloat(squaresPerRow + 1) * inset
			let squareWidth: CGFloat = (bounds.width - sumOfInsets) / CGFloat(squaresPerRow)
            
			let totalNumberOfRows = CGFloat(numberOfRows + topBoardNumberOfRows + letterBoardNumberOfRows)
            sumOfInsets = (totalNumberOfRows + 1) * inset
			let maxSquareHeigth = (bounds.height - sumOfInsets) / (totalNumberOfRows + 2)
			squareSize = CGSize(width: squareWidth, height: min(maxSquareHeigth, squareWidth))
		}
	}
	
	
    private var movingLetter: (view: UIView, superView: UIView)?
	
	func movePaddle(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			if let letterView = self.hitTest(p: recognizer.location(in: self)) as? LetterView
			{	movingLetter = (view: letterView, superView: letterView.superview!)
				let locationInSuperView = letterView.convert(letterView.center, to: self)
				letterView.removeFromSuperview()
				letterView.center = locationInSuperView
				self.addSubview(letterView)
			}
		case .changed:
			if let movingLetter = movingLetter {
				movingLetter.view.center.translate(p: recognizer.translation(in: self))
			} else {
				paddle.translationX = recognizer.translation(in: self).x
			}
			recognizer.setTranslation(CGPoint.zero, in: self)
		default:
			if let movingLetter = movingLetter {
				let letterView = movingLetter.view
				letterView.removeFromSuperview()
				if let slot = self.hitTest(p: recognizer.location(in: self)) as? SquareView
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
				score = mainBoard.score()
			}
		}
	}
	
//  protocol TranslationPaddle
	func dimensionsHaveChanged(paddle: PaddleView) {
		let path = UIBezierPath(rect: paddle.frame)
		dynamicBehavior.addBarrier(path: path, name: "paddle")
	}
	
	func handleTap(recognizer: UITapGestureRecognizer) {
        if animating {
            let location = recognizer.location(in: self)
            let vector = CGVector(dx: location.x - ball.center.x,
                                  dy: location.y - self.bounds.height)
            let instantaneousPush: UIPushBehavior = {
                let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
                push.pushDirection = vector
				let pushMagnitude = vector.dy * maxPushMagnitude / -bounds.height
                push.magnitude = max(pushMagnitude, Constants.minPushMagnitude)
                push.action = { [unowned push] in
                    push.dynamicAnimator!.removeBehavior(push)
                }
                return push
            }()
			self.animator.addBehavior(instantaneousPush)
        } else {
            delegate?.onResume()
        }
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
				animator.addBehavior(dynamicBehavior)
			} else {
				animator.removeBehavior(dynamicBehavior)
			}
		}
	}

	lazy var dynamicBehavior: DynamicBehavior = {
		[unowned self] in
		let dynamicBehavior = DynamicBehavior()
		dynamicBehavior.collider.collisionDelegate = self
		return dynamicBehavior
	}()
	
	
	private var score: Int = 0 {
		didSet {
			scoreLabel?.text = "Score: " + String(score)
		}
	}
	private var scoreLabel: UILabel! {
		didSet {
			scoreLabel.translatesAutoresizingMaskIntoConstraints = false
			scoreLabel.textAlignment = .center
			score = 0
			scoreLabel.textColor = letterColors["tekstValue"]
			scoreLabel.alpha = 0.3
			let maxHeight = paddle.frame.minY - mainBoard.frame.maxY
			scoreLabel.font = UIFont(name: scoreLabel.font.fontName, size: maxHeight * 0.3)
			let centerYConstant =  maxHeight * 0.5 + mainBoard.frame.maxY - center.y
			addSubview(scoreLabel)
			scoreLabel.widthAnchor.constraint(equalTo: widthAnchor , multiplier: 1, constant: 0).isActive = true
			scoreLabel.heightAnchor.constraint(equalTo: heightAnchor , multiplier: 0.2, constant: 0).isActive = true
			scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerYConstant).isActive = true
		}
	}
	
	let selectorRightButton = #selector(handlePauseButton(button:))
	let selectorLeftButton = #selector(handleLeftButton(button:))
	
	func handlePauseButton(button: UIButton) {
		delegate?.onPauseGame(button: button)
	}
	
	func handleLeftButton(button: UIButton) {
        delegate?.onLeftButton(button: button)
	}
	
    func compensateForToolBar(duration: TimeInterval = ToolBarAnimation.duration,
                              delay: TimeInterval = ToolBarAnimation.delay)
    {
        UIView.animate(withDuration: duration, delay: delay, options: [], animations:
		{	[unowned self] in
			self.layoutPaddleAndLetterBoard()
		}, completion: { if $0
			{
			}})
    }

	var topBoard: LetterSourceBoard! = LetterSourceBoard()
	var mainBoard: ScrabbleBoard! = ScrabbleBoard()
	var letterBoard: ContainerForLetterTargetBoard! = ContainerForLetterTargetBoard()
	var paddle: PaddleView! = PaddleView()
	var ball: BallImageView! = BallImageView(image: UIImage(named: "Football"))

	
	func resetAllBoards() {
		topBoard?.removeFromSuperview()
		mainBoard?.removeFromSuperview()
		letterBoard?.removeFromSuperview()
		ball?.removeFromSuperview()
		paddle?.removeFromSuperview()
		
		squareSize = CGSize()
		topBoard = LetterSourceBoard()
		mainBoard = ScrabbleBoard()
		letterBoard = ContainerForLetterTargetBoard()
		paddle = PaddleView()
		ball = BallImageView(image: UIImage(named: "Football"))
		
		addBoardSubViews()
	}
	
	func addBoardSubViews() {
		addSubview(topBoard)
		addSubview(mainBoard)
		addSubview(letterBoard)
		letterBoard.buttons.left.addTarget(self, action: self.selectorLeftButton,
		                                   for: .touchUpInside)
		letterBoard.buttons.right.addTarget(self, action: self.selectorRightButton,
		                                    for: .touchUpInside)
		addSubview(paddle)
		addSubview(ball)
		_ = changed(bounds: CGRect.zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		//		Need to call 'func setupSubViews()' manually
		//		set vars first: i.e. 'squaresPerRow' ...
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		backgroundColor = mainBoardColors["backGround"]
		addBoardSubViews()
	}
	
	// Dirty solution.... must find better one ...
	func changed(bounds: CGRect) -> Bool {
		struct oldValueFor {
			static var bounds: CGRect = CGRect.zero
		}
		let changed: Bool = oldValueFor.bounds != bounds
		oldValueFor.bounds = bounds
		return changed
	}
	
	override func layoutSubviews() {
		guard changed(bounds: bounds) == true else { return }
		squareSize = CGSize()
		topBoard.frame = CGRect(origin: CGPoint.zero, size: topBoard.intrinsicContentSize)
		mainBoard.frame = CGRect(origin: CGPoint(x: 0, y: topBoard.frame.maxY + 10) ,
		                             size: mainBoard.intrinsicContentSize)
		layoutPaddleAndLetterBoard()

		ball.dynamicBehaviorIsActive = false
		ball.frame = CGRect(center: CGPoint(x: bounds.midX, y: bounds.midY), size: ball.contentSize)
		ball.dynamicBehaviorIsActive = true
		animator.updateItem(usingCurrentState: ball)
		print("layoutSubs was executed...")
		scoreLabel?.removeFromSuperview()
		scoreLabel = UILabel()
		addSubview(scoreLabel)
	}
	
	private func layoutPaddleAndLetterBoard() {
		paddle.fromBottom = letterBoard.intrinsicContentSize.height
		if delegate != nil, delegate!.heigthOfTabBar > 0 {
			paddle.frame = CGRect(center: CGPoint(x: bounds.midX,
			                                      y: bounds.height - delegate!.heigthOfTabBar),
			                      size: paddle.fullContentSize)
			let offsetY = paddle.center.y - paddle.centerY
			letterBoard.frame = CGRect(center: CGPoint(x: center.x, y: letterBoard.centerY + offsetY),
			                           size: letterBoard.intrinsicContentSize)
		} else {
			
			paddle.frame = CGRect(center: CGPoint(x: (paddle.storedRalativeXPosition ?? 0.5) *  bounds.width,
			                                      y: paddle.centerY),size: paddle.intrinsicContentSize)
			letterBoard.frame = CGRect(center: CGPoint(x: center.x, y: letterBoard.centerY),
			                           size: letterBoard.intrinsicContentSize)
		}
		dynamicBehavior.addBarrier(path: UIBezierPath(rect: letterBoard.frame), name: "letterBoard")
	}

	func resetTopBoard()
	{	let oldBoard: LetterSourceBoard = topBoard
		topBoard = LetterSourceBoard()
		topBoard.frame = CGRect(origin: CGPoint.zero, size: oldBoard.intrinsicContentSize)
		topBoard.center.x += frame.width * 1.1
		insertSubview(topBoard, belowSubview: mainBoard)
		UIView.animate(withDuration: 1, animations: {   [unowned self] in
			self.topBoard.center.x = self.center.x
			oldBoard.center.x -= self.frame.width
			}, completion: { [unowned self] in if $0
			{   oldBoard.removeFromSuperview()
				self.animating = true
				}
			})
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
//		print("BEGAN item contact at", p)
		
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
//		print("END item contact")
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
		if 	let name = identifier as? String , name.hasPrefix("squareView_"),
			let view = topBoard.paths[name],
			let letterView = view.letterView,
			let slot = letterBoard.firstEmptySlot(isFor: letterView)
		{
			var locationInSuperView = letterView.convert(letterView.center, to: self)
			letterView.removeFromSuperview()
			letterView.center = locationInSuperView
			self.addSubview(letterView)
            locationInSuperView = slot.superview!.convert(slot.center, to: self)
            UIView.animate(withDuration: 0.5, delay: 0, options: .autoreverse,
                           animations: { letterView.backgroundColor =  letterColors["animationBG"]},
                           completion: { if $0 { letterView.backgroundColor = letterColors["backGround"] }})
            letterView.shakeN(times: 10, degrees: 20, duration: 0.5, delay: 0, completion:
            {

                UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseIn, animations:
                {
                    letterView.center = locationInSuperView
                })
                {	_ in
                        letterView.removeFromSuperview()
                        letterView.center = slot.bounds.mid
                        slot.addSubview(letterView)
                }
            })

		}
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
		if let name = identifier as? String {
			print("endedContactFor item: ", name)
		}
	}

}
