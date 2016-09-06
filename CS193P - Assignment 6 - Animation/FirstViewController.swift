//
//  FirstViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 15/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//


import UIKit



class FirstViewController: UIViewController, GameViewDelegate {

	@IBOutlet weak var tabBar: UITabBar!
	
	@IBOutlet weak var gameView: GameView! {
		didSet {
			var selector = #selector(gameView.movePaddle(recognizer:))
			gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: selector))
			selector = #selector(gameView.handleTap(recognizer:))
			gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: selector))
			gameView.delegate = self
		}
	}
	

	func endGame() {
	}

	func pauseGame() {
	}
	
	func onPauseGame(button: UIButton) {
		if let tabBarController = self.tabBarController
		where tabBarController.tabBar.isHidden == true {
			tabBarController.setTabBar(isVisible: true, animated: true)
			tabBarController.tabBar.isHidden = false
		}
	}
	
	func resumeGame() {
	}

	
	func onResume() {
		if let tabBarController = self.tabBarController
		where tabBarController.tabBar.isHidden == false {
			tabBarController.setTabBar(isVisible: false, animated: true)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		gameView.animating = true		
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		gameView.animating = false
	}
	
}

extension UITabBarController {
	
	func setTabBar(isVisible: Bool, animated: Bool) {
		guard self.tabBar.isHidden == isVisible else { return }
		
		let frame = self.tabBar.frame
		let height = frame.size.height
		let offsetY = (isVisible ? -height : height)
		let tabBarWasHidden = self.tabBar.isHidden
		
		UIView.animate(withDuration: animated ? 1 : 0.0, animations:
		{	[unowned self] in
			self.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
			if tabBarWasHidden {
				self.tabBar.isHidden = !self.tabBar.isHidden
			}
//			self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,
//			                         height: self.view.frame.height + offsetY)
		})
		{ (finished) in
			if finished {
				if !tabBarWasHidden {
					self.tabBar.isHidden = !self.tabBar.isHidden
				}

				self.view.setNeedsDisplay()
				self.view.layoutIfNeeded()
			}
		}
	}
}

