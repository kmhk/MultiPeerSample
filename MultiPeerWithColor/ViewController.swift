//
//  ViewController.swift
//  MultiPeerWithColor
//
//  Created by Com on 12/01/2017.
//  Copyright © 2017 Com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var connectionsLabel: UILabel!
	
	let colorService = ColorServiceManager()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		colorService.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func greenTapped(_ sender: AnyObject) {
		self.changeColor(UIColor.green)
		colorService.sendColor("green")
	}
	
	@IBAction func yellowTapped(_ sender: AnyObject) {
		self.changeColor(UIColor.yellow)
		colorService.sendColor("yellow")
	}
	
	func changeColor(_ color : UIColor) {
		UIView.animate(withDuration: 0.2, animations: {
			self.view.backgroundColor = color
		})
	}
}

extension ViewController : ColorServiceManagerDelegate {
	
	func connectedDevicesChanged(_ manager: ColorServiceManager, connectedDevices: [String]) {
		OperationQueue.main.addOperation { () -> Void in
			self.connectionsLabel.text = "Connections: \(connectedDevices)"
		}
	}
	
	func colorChanged(_ manager: ColorServiceManager, colorString: String) {
		OperationQueue.main.addOperation { () -> Void in
			switch colorString {
			case "green":
				self.changeColor(UIColor.green)
			case "yellow":
				self.changeColor(UIColor.yellow)
			default:
				NSLog("%@", "Unknown color value received: \(colorString)")
			}
		}
	}
	
}
