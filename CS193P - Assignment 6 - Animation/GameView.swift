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
    func onLeftButton(button: UIButton)
}

@IBDesignable
class GameView: UIView, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, TranslationPaddle
{
	weak var delegate: GameViewDelegate?
    
    
	@IBInspectable var squaresPerRow: Int = 7 { didSet { setNeedsDisplay() } }
	var numberOfRows: Int { return squaresPerRow }

	let topBoardNumberOfRows: Int = 2
	let letterBoardNumberOfRows: Int = 1
	var letterBoardSquaresPerRow: Int  { return squaresPerRow - 2 }
	
	@IBInspectable var inset: CGFloat =  1.5 	{ didSet { setNeedsDisplay() } }
	@IBInspectable var squareWidthToBallRatio: CGFloat = 1 { didSet{ setNeedsDisplay() } }

	let maxPushMagnitude: CGFloat = 2
	let minPushMagnitude: CGFloat = 1
	
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
				paddle?.translationX = recognizer.translation(in: self).x
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
	
//  protocol TranslationPaddle
	func dimensionsHaveChanged(paddle: PaddleView) {
		let path = UIBezierPath(rect: paddle.frame)
		ballBehavior.addBarrier(path: path, name: "paddle")
	}
	
	func handleTap(recognizer: UITapGestureRecognizer) {
        if animating {
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
			topBoard?.squaresPerRow = squaresPerRow
			topBoard?.numberOfRows = topBoardNumberOfRows
			topBoard?.inset = inset
		}
	}
	
	var mainBoard: ScrabbleBoard! {
		didSet {
			let origin: CGPoint = topBoard.frame.lowerLeft
			let height = bounds.height - (topBoard?.bounds.height ?? 0)
			mainBoard?.frame = CGRect(origin: origin,
			                          size: CGSize(width: bounds.width, height: height))
			mainBoard?.squareSize = squareSize
			mainBoard?.squaresPerRow = squaresPerRow
			mainBoard?.numberOfRows = numberOfRows
			mainBoard?.inset = inset
		}
	}
	
	var letterBoard: LetterBoard! {
		didSet {
			guard letterBoard != nil else { return }
			let height = self.squareSize.height
			let originX: CGFloat = self.squareSize.width + self.inset
			let board = Board(frame: CGRect(origin: CGPoint(x: originX, y:  2) ,
			                                size: CGSize(width: 0, height: height)))
			board.squareSize = self.squareSize
			board.squaresPerRow = self.letterBoardSquaresPerRow
			board.numberOfRows = self.letterBoardNumberOfRows
			board.inset = self.inset
			letterBoard.board = board
			let centerY: CGFloat = self.bounds.height - height / 2 - 5
			letterBoard.center = CGPoint(x: self.center.x, y: centerY)
			letterBoard.buttons?.right.addTarget(self, action: self.selectorRightButton,
			                                     for: .touchUpInside)
			letterBoard.buttons?.left.addTarget(self, action: self.selectorLeftButton,
			                                     for: .touchUpInside)
			paddle?.fromBottom += letterBoard.frame.height
            if initialToolBarCompensation != 0 {
                compensateForToolBar(heigth: initialToolBarCompensation, duration: 0.1)
            }
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
	
    private lazy var storedFrames: (paddle: CGRect, letterBoard: CGRect) = {
        return (self.paddle.frame, self.letterBoard.frame)
    }()
    
    var initialToolBarCompensation: CGFloat = -50
    func compensateForToolBar(heigth: CGFloat, duration: TimeInterval = 1, delay: TimeInterval = 0)
    {
        var translationY: CGFloat = 0
        if heigth != 0 {
            storedFrames = (paddle: paddle.frame, letterBoard: letterBoard.frame)
            translationY = self.bounds.height - paddle.center.y - heigth
        }
        UIView.animate(withDuration: duration, delay: delay, options: [], animations:
        {   if heigth != 0 {
                self.paddle.center.y += translationY
                self.letterBoard.center.y += translationY
                self.paddle.frame.size.width = self.bounds.width
                self.paddle.center.x = self.center.x
            } else {
                self.paddle.frame = self.storedFrames.paddle
                self.dimensionsHaveChanged(paddle: self.paddle)
                self.letterBoard.frame = self.storedFrames.letterBoard
            }
            }, completion: { if $0 { }})
    }

	private var paddle: PaddleView! {
		didSet {
			paddle?.resetFrame(in: self.bounds)
			paddle?.delegate = self
		}
	}
	
	private var ball: BallImageView! {
		willSet {
            guard let ball = ball else { return }
            ballBehavior.remove(item: ball)
            ball.removeFromSuperview()
        }
        didSet {
            guard let ball = ball else { return }
            addSubview(ball)
            ballBehavior.add(item: ball)
		}
	}

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
		ball = BallImageView(center: self.center,
		                     radius: squareSize.width / (squareWidthToBallRatio * 2),
		                     imageName: "Football")
        initialToolBarCompensation = 0
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
			topBoard.paths[identifier! as! String] = nil
			ballBehavior.collider.removeBoundary(withIdentifier: identifier!)
		}
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
//		print("END boundery contact")
	}

}
