///////////////////////////////////////////////////////////////////////////////
//  LaunchViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 15/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////

import UIKit

class LaunchViewController: UIViewController  {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ball: BallImageView!
    
    @IBAction func onStartButton(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
}

