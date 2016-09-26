//
//  SettingsViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 20/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {


	@IBOutlet weak var ColorSegmentedControl: UISegmentedControl!
	
	@IBAction func onColorSegmentedControl(_ sender: UISegmentedControl)
	{
	}
	
	
	@IBAction func setColor(_ sender: UIButton)
	{
		
	}

	@IBOutlet weak var pinchImageView: UIImageView!
	@IBOutlet weak var outletView: UIView!
	{
		didSet {
			let selector = #selector(SettingsViewController.handlePinch(recognizer:))
			outletView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: selector))
		}
	}

	func handlePinch(recognizer: UIPinchGestureRecognizer) {
	
	}
	
	
	@IBAction func setBricksPerRow(_ sender: UISegmentedControl) {
	}

	@IBAction func setNumberOfRows(_ sender: UISegmentedControl) {
	}
	
	@IBOutlet weak var numberOfRowsCtrl: UISegmentedControl!
	@IBOutlet weak var bricksPerRowCtrl: UISegmentedControl!

	
    override func viewDidLoad() {
        super.viewDidLoad()
		

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }



}
