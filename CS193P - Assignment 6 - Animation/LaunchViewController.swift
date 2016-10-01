///////////////////////////////////////////////////////////////////////////////
//  LaunchViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 15/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

class LaunchViewController: UIViewController, UIViewControllerTransitioningDelegate  {

    private enum constants: String {
        case segueToGameView = "toGameView"
    }
    
    @IBOutlet weak var ball: BallImageView!

    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.addTarget(self, action: selectorStartButton, for: .touchUpInside)
        }
    }
    
    let selectorStartButton = #selector(onStartButton)
    
    func onStartButton() {
        timer.invalidate()
        performSegue(withIdentifier: constants.segueToGameView.rawValue, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private lazy var timer: Timer =  { [unowned self] in
        return Timer.init( timeInterval: 1.5,
                           target: self,
                           selector: self.selectorStartButton,
                           userInfo: nil,
                           repeats: false)
    }()
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
    
    private let customTabBarAnimationController = CustomTabBarAnimationController()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customTabBarAnimationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.segueToGameView.rawValue {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self
        }
    }
}

