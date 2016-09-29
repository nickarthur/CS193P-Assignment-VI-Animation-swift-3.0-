///////////////////////////////////////////////////////////////////////////////
//  GameViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 29/09/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

class GameViewController: UIViewController, GameViewDelegate  {
    
    weak var tabBar: UITabBar?
    
    @IBOutlet weak var launchView: UIView!
    
    @IBOutlet weak var gameView: GameView! {
        didSet {
            var selector = #selector(gameView.movePaddle(recognizer:))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: selector))
            selector = #selector(gameView.handleTap(recognizer:))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: selector))
            gameView.delegate = self
        }
    }
    
    
    func onLeftButton(button: UIButton)
    {   UIView.transition(with: gameView,
                          duration: 1.5,
                          options: .transitionFlipFromLeft,
                          animations: { [unowned self] in
                            self.gameView.squaresPerRow = self.gameView.squaresPerRow == 7 ? 9: 7
        },
                          completion: nil)
    }
    
    func endGame() {
    }
    
    func pauseGame() {
    }
    
    func onPauseGame(button: UIButton) {
        tabBar?.animateTo(isVisible: true)
        gameView.animating = false
    }
    
    func resumeGame() {
    }
    
    func onResume() {
        tabBar?.animateTo(isVisible: false)
        gameView.animating = true
    }
    
    override func viewDidLoad() {
        tabBar = tabBarController?.tabBar
    }
    
    var tabBarSnapShot: UIView? {
        willSet {
            tabBarSnapShot?.removeFromSuperview()
            if let tabBar = newValue {
                tabBar.center.y = gameView.bounds.height - tabBar.frame.height / 2
                gameView.addSubview(tabBar)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBar?.animateTo(isVisible: false, duration: 1, delay: 1, completion: { self.gameView.animating = true })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
        tabBar?.isHidden = false
    }
    
}
