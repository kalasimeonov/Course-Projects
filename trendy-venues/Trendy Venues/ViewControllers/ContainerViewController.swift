//
//  ViewController.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5) {
                self.viewContainer.subviews[0].alpha = 1
                self.viewContainer.subviews[1].alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.viewContainer.subviews[0].alpha = 0
                self.viewContainer.subviews[1].alpha = 1
            }
        }
    }
}

