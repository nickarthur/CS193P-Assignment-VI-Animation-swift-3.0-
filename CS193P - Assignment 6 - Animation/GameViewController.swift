///////////////////////////////////////////////////////////////////////////////
//  GameViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 29/09/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

class GameViewController: UIViewController, GameViewDelegate, UIViewControllerTransitioningDelegate, UITabBarControllerDelegate {
    
    
    let customTabBarAnimationController = CustomTabBarAnimationController()
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return customTabBarAnimationController
    }

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
    {   gameView.animating = false
        UIView.transition(with: gameView,
                          duration: 1.5,
                          options: .transitionFlipFromLeft,
                          animations: { [unowned self] in
                            self.gameView.squaresPerRow = self.gameView.squaresPerRow == 7 ? 9: 7
        },
                          completion: { if $0 { self.gameView.animating = true }} )
    }
    
    func endGame() {
    }
    
    func pauseGame() {
    }
    
    func onPauseGame(button: UIButton) {
        tabBar?.animateTo(isVisible: true)
        gameView.compensateForToolBar(heigth: tabBar!.bounds.height)
        gameView.animating = false
    }
    
    func resumeGame() {
    }
    
    func onResume() {
        tabBar?.animateTo(isVisible: false, duration: 1, delay: 0,
                          completion: { self.gameView.animating = true })
        gameView.compensateForToolBar(heigth: 0)
    }
    
    override func viewDidLoad() {
        tabBar = tabBarController?.tabBar
        tabBarController?.delegate = self
        
        gameView.initialToolBarCompensation = tabBar?.frame.height ?? 0
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
        tabBar?.animateTo(isVisible: false, duration: 1, delay: 0.5, completion: { self.gameView.animating = true })
        gameView.compensateForToolBar(heigth: 0, duration: 1, delay: 0.5)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
        tabBar?.isHidden = false
    }
    
}
