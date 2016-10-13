//
//  SettingsViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 20/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {


	weak var dataSource: ControllerWithSettingsData?
	
	@IBOutlet weak var ColorSegmentedControl: UISegmentedControl!
	
	@IBAction func onColorSegmentedControl(_ sender: UISegmentedControl)
	{
	}
	
	
	
	@IBAction func setColor(_ sender: UIButton)
	{
		
	}
	
	lazy var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.usesSignificantDigits = false
		formatter.minimumIntegerDigits = 1
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		return formatter
	}()
	
	@IBOutlet weak var densitySlider: UISlider!
	@IBOutlet weak var densityValueLabel: UILabel!
	@IBOutlet weak var pushMagnitudeSlider: UISlider! {
		didSet {
			pushMagnitudeSlider.minimumValue = Float(Constants.minPushMagnitude)
			pushMagnitudeSlider.maximumValue = Float(Constants.maxPushMagnitude)
		}
	}
	@IBOutlet weak var gravitySwitch: UISwitch!
	@IBOutlet weak var gravityXSlider: UISlider!
	@IBOutlet weak var gravityYSlider: UISlider!
	@IBOutlet weak var gravityXValueLabel: UILabel!
	@IBOutlet weak var gravityYValueLabel: UILabel!
	
	
	
	@IBOutlet weak var pushMagnitudeValueLabel: UILabel!
	
	@IBAction func onDensitySlider(_ sender: UISlider) {
		if let stringVal = formatter.string(from: NSNumber(value: sender.value))
		{	densityValueLabel.text = stringVal
			dataSource?.density = CGFloat(sender.value)
		}
	}
	
	@IBAction func onMaxPushMagnitudeSlider(_ sender: UISlider) {
		if let stringVal = formatter.string(from: NSNumber(value: sender.value))
		{	pushMagnitudeValueLabel.text = stringVal
			dataSource?.maxPushMagnitude = CGFloat(sender.value)
		}
	}
	
	@IBAction func onGravitySwitch(_ sender: UISwitch) {
		if sender.isOn {
			gravityXSlider.value = Float(Constants.gravityDirection.dx)
			gravityYSlider.value = Float(Constants.gravityDirection.dy)
			dataSource?.gravityDirection = Constants.gravityDirection
			gravityXValueLabel.text = formatter.string(from: NSNumber(value: gravityXSlider.value))
			gravityYValueLabel.text = formatter.string(from: NSNumber(value: gravityYSlider.value))
		}
	}
	
	@IBAction func onGravitySlider(_ sender: UISlider) {
		enum direction { case dx, dy }
		let gravityFor: direction = sender.tag == 0 ? .dx : .dy
		switch gravityFor {
		case .dx:
			dataSource?.gravityDirection.dx = CGFloat(sender.value)
			gravityXValueLabel.text = formatter.string(from: NSNumber(value: sender.value))
		case .dy:
			dataSource?.gravityDirection.dy = CGFloat(sender.value)
			gravityYValueLabel.text = formatter.string(from: NSNumber(value: sender.value))
		}
		gravitySwitch.isOn = false
	}
	
	
	@IBAction func setBricksPerRow(_ sender: UISegmentedControl) {
	}

	@IBAction func setNumberOfRows(_ sender: UISegmentedControl) {
	}
	
	@IBOutlet weak var numberOfRowsCtrl: UISegmentedControl!
	@IBOutlet weak var bricksPerRowCtrl: UISegmentedControl!

	
    override func viewDidLoad() {
        super.viewDidLoad()
		for vc in tabBarController!.viewControllers! {
			if let gameViewVC = vc as? ControllerWithSettingsData {
				dataSource = gameViewVC
				break
			}
		}
	
		if let dataSource = dataSource {
			let densityValue = Float(dataSource.density)
			densityValueLabel.text = formatter.string(from: NSNumber(value: densityValue))
			densitySlider.value = densityValue
			let pushMagnitude = Float(dataSource.maxPushMagnitude)
			pushMagnitudeValueLabel.text = formatter.string(from: NSNumber(value: pushMagnitude))
			pushMagnitudeSlider.value = pushMagnitude
			gravitySwitch.isOn = dataSource.gravityDirection == Constants.gravityDirection
			let gravityDX = Float(dataSource.gravityDirection.dx)
			let gravityDY = Float(dataSource.gravityDirection.dy)
			gravityXSlider.value = gravityDX
			gravityXValueLabel.text = formatter.string(from: NSNumber(value: gravityDX))
			gravityYSlider.value = gravityDY
			gravityYValueLabel.text = formatter.string(from: NSNumber(value: gravityDY))

		}
    }
		

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }



}
