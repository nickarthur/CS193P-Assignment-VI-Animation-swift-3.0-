//
//  SettingsViewController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 20/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

//	weak var gameView: GameView?
//
//	@IBOutlet weak var ColorSegmentedControl: UISegmentedControl!
//	
//	@IBAction func onColorSegmentedControl(_ sender: UISegmentedControl)
//	{
//		for subView in outletView.subviews {
//			if subView != pinchImageView {
//				subView.removeFromSuperview()
//			}
//		}
//		
//		let index = sender.selectedSegmentIndex
//		switch sender.titleForSegment(at: index)! {
//		case "Bricks":
//			pinchImageView.isHidden = true
//			gameView?.drawBoard(onView: outletView)
//		case "Paddle":
//			pinchImageView.isHidden = false
//			let paddle = PaddleView(in: outletView.bounds)
//			outletView.addSubview(paddle)
//			paddle.useReferenceFrame = gameView!.bounds
//		case "Ball":
//			pinchImageView.isHidden = false
//			let ball = BallImageView(center: outletView.center)
//			outletView.addSubview(ball)
//		default: break
//		}
//	}
//	
//	
//	@IBAction func setColor(_ sender: UIButton)
//	{	let index = ColorSegmentedControl.selectedSegmentIndex
//		switch ColorSegmentedControl.titleForSegment(at: index)! {
//		case "Bricks":
//			gameView?.brickColor = sender.backgroundColor!
//			onColorSegmentedControl(ColorSegmentedControl)
//		case "Paddle":
//			PaddleConstants.Color = sender.backgroundColor!
//			if let paddle = outletView.subviews.last as? PaddleView
//			{	paddle.color = PaddleConstants.Color
//			}
//		default: break
//		}
//		gameView?.setNeedsDisplay()
//	}
//
//	@IBOutlet weak var pinchImageView: UIImageView!
//	@IBOutlet weak var outletView: UIView!
//	{
//		didSet {
//			let selector = #selector(SettingsViewController.handlePinch(recognizer:))
//			outletView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: selector))
//		}
//	}
//
//	func handlePinch(recognizer: UIPinchGestureRecognizer) {
//	
//		let index = ColorSegmentedControl.selectedSegmentIndex
//		switch ColorSegmentedControl.titleForSegment(at: index)! {
//		case "Paddle":
//			switch recognizer.state {
//			case .began: break
//			case .changed:
//				if let paddle = outletView.subviews.last as? PaddleView {
//					paddle.widthPercentage *= recognizer.scale
//					recognizer.scale = 1
//				}
//			default:
//					gameView?.setNeedsDisplay()
//			}
//		case "Ball":
//			switch recognizer.state {
//			case .began: break
//			case .changed:
//				if let ball = outletView.subviews.last as? BallImageView {
////					let maxScale = ball.maxRadius / ball.radius
////					let minScale = ball.minRadius / ball.radius
////					recognizer.scale = max(min(recognizer.scale, maxScale), minScale)
////					ball.transform = CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale)
//					let scale = (recognizer.scale - 1) / 2 + 1
//					ball.radius *= scale
//					recognizer.scale = 1
//				}
//			default:
//				break
////				if let ball = outletView.subviews.last as? BallImageView {
////					BallConstants.Radius = ball.radius
////					gameView?.setNeedsDisplay()
////				}
//			}
//		default: break
//		}
//	}
//	
//	
//	@IBAction func setBricksPerRow(_ sender: UISegmentedControl) {
//		let index = sender.selectedSegmentIndex
//		if let value = Int(sender.titleForSegment(at: index)!) {
//			gameView?.bricksPerRow = value
//		}
//		ColorSegmentedControl.selectedSegmentIndex = 0
//		onColorSegmentedControl(ColorSegmentedControl)
//	}
//
//	@IBAction func setNumberOfRows(_ sender: UISegmentedControl) {
//		let index = sender.selectedSegmentIndex
//		if let value = Int(sender.titleForSegment(at: index)!) {
//			gameView?.numberOfRows = value
//		}
//		ColorSegmentedControl.selectedSegmentIndex = 0
//		onColorSegmentedControl(ColorSegmentedControl)
//	}
//	
//	@IBOutlet weak var numberOfRowsCtrl: UISegmentedControl!
//	@IBOutlet weak var bricksPerRowCtrl: UISegmentedControl!
//
//	
//    override func viewDidLoad() {
//        super.viewDidLoad()
//		
//		let viewControllers = tabBarController?.viewControllers
//		for vc in viewControllers! {
//			if let firstVC = vc as? FirstViewController {
//				gameView = firstVC.gameView
//				numberOfRowsCtrl.selectedSegmentIndex = gameView!.numberOfRows - 2
//				bricksPerRowCtrl.selectedSegmentIndex = gameView!.bricksPerRow - 4
//			}
//		}
//		onColorSegmentedControl(ColorSegmentedControl)
//    }
//
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }



}
