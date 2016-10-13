///////////////////////////////////////////////////////////////////////////////
//  GameViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 29/09/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

protocol ControllerWithSettingsData: class {
	var density: CGFloat { get set }
	var maxPushMagnitude: CGFloat { get set }
	var gravityDirection: CGVector { get set }
}

class GameViewController: UIViewController, GameViewDelegate, UIViewControllerTransitioningDelegate, UITabBarControllerDelegate, ControllerWithSettingsData, GameViewDataSource {
	
	private let customTabBarAnimationController = CustomTabBarAnimationController()
	func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{	return customTabBarAnimationController
	}
	
	var gravityDirection: CGVector {
		set {
			gameView.dynamicBehavior.gravity.gravityDirection = newValue
			userdefaults.set(Float(newValue.dx), forKey: Keys.gravityDirectionX)
			userdefaults.set(Float(newValue.dy), forKey: Keys.gravityDirectionY)
		}
		get {
			let dx = CGFloat(userdefaults.float(forKey: Keys.gravityDirectionX))
			let dy = CGFloat(userdefaults.float(forKey: Keys.gravityDirectionY))
			return CGVector(dx: dx, dy: dy)
		}
	}
	
	var density: CGFloat {
		set {
			gameView.dynamicBehavior.itemBehavior.density = min(max(newValue, 0), Constants.maxDensity)
			userdefaults.set(Float(newValue), forKey: Keys.density)
		}
		get { return CGFloat(userdefaults.float(forKey: Keys.density)) }
	}
	
	var maxPushMagnitude: CGFloat {
		set {
			gameView.maxPushMagnitude = newValue
			userdefaults.set(Float(newValue), forKey: Keys.maxPushMagnitude)
		}
		get { return CGFloat(userdefaults.float(forKey: Keys.maxPushMagnitude)) }
	}

	weak var tabBar: UITabBar?
	var heigthOfTabBar: CGFloat {
		return tabBar != nil ? gameView.bounds.height - tabBar!.frame.minY : 0
	}

    @IBOutlet weak var launchView: UIView!
    
    @IBOutlet weak var gameView: GameView! {
        didSet {
            var selector = #selector(gameView.movePaddle(recognizer:))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: selector))
            selector = #selector(gameView.handleTap(recognizer:))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: selector))
			fetchGameViewDynamicsParameters()
            gameView.delegate = self
			gameView.dataSource = self
        }
    }
	
	func onLeftButton(button: UIButton)
	{   gameView.animating = false
		let ppc = actionSheet.popoverPresentationController
		ppc?.sourceView = button
		present(actionSheet, animated: true, completion: nil)
	}
	
	func onPauseGame(button: UIButton) {
		tabBar?.animateTo(isVisible: true)
		gameView.compensateForToolBar()
		gameView.animating = false
	}
	
	func onResume() {
		tabBar?.animateTo(isVisible: false,
		                  duration: ToolBarAnimation.duration,
		                  delay: ToolBarAnimation.delay,
		                  completion: { self.gameView.animating = true })
		gameView.compensateForToolBar()
	}

    private lazy var actionSheet:  UIAlertController = {
        let alert = UIAlertController(
            title: "Scrabble board",
            message: "Set parameters for Scrabble Board.",
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(
            title: "Board: 7 x 7",
            style: .default,
            handler: { (action: UIAlertAction) -> Void in self.set(squaresPerRow: 7) })
        )
        alert.addAction(UIAlertAction(
            title: "Board: 9 x 9",
            style: .default,
            handler: { (action: UIAlertAction) -> Void in self.set(squaresPerRow: 9) })
        )
        alert.addAction(UIAlertAction(
            title: "Reset Letters",
            style: .default,
            handler: { (action: UIAlertAction) -> Void in
                self.gameView.resetTopBoard() })
        )
        alert.addAction(UIAlertAction(
            title: "Reset All",
            style: .destructive,
            handler: { (action: UIAlertAction) -> Void in self.set(squaresPerRow: 0) })
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: UIAlertAction) -> Void in self.set(squaresPerRow: -1) })
        )
        alert.modalPresentationStyle = .popover
        
        return alert
    }()
    
    private func set(squaresPerRow: Int) {
        var n: Int?
        switch squaresPerRow {
        case 7: n = gameView.squaresPerRow == 9 ? 7 : nil
        case 9: n = gameView.squaresPerRow == 7 ? 9 : nil
        case 0: n = gameView.squaresPerRow
        default: n = nil
        }
        if let squaresPerRow = n {
			UIView.transition(
				with: gameView,
				duration: 1.5,
				options: .transitionFlipFromLeft,
				animations: { [unowned self] in
					self.gameView.squaresPerRow = squaresPerRow
					self.gameView.resetAllBoards()
				},
				completion: { if $0 { self.gameView.animating = true }} )
		} else {
			gameView.animating = true
		}

    }
	
	private let userdefaults = UserDefaults.standard
	private func fetchGameViewDynamicsParameters() {
		let deviceHasStoredData: Bool = userdefaults.bool(forKey: Keys.deviceHasStoredData)
		if !deviceHasStoredData {
			density = Constants.maxDensity
			maxPushMagnitude = Constants.maxPushMagnitude / 2
			gravityDirection = Constants.gravityDirection
			userdefaults.set(true, forKey: Keys.deviceHasStoredData)
		}
	}
	
    override func viewDidLoad() {
		tabBar = tabBarController?.tabBar
		tabBarController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		self.gameView.animating = true
        tabBar?.animateTo(isVisible: false,
                          duration: ToolBarAnimation.duration,
                          delay: ToolBarAnimation.delay,
                          completion: { self.gameView.animating = true })
        gameView.compensateForToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
        tabBar?.isHidden = false
    }
	
    
}
