//
//  TestViewController.swift
//  KSNavigationControllerExampleSwift
//
//  Created by Alex on 8/4/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Cocoa

class TestViewController: NSViewController, KSNavigationControllerCompatible {
    weak var navigationController: KSNavigationController?

    @IBOutlet weak var textField: NSTextField!
    
    @IBAction func pushAction(_ sender: AnyObject) {
        self.navigationController?.pushViewController(TestViewController(), animated: true)
    }

    @IBAction func popAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(red: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, green: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, blue: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, alpha: 1).cgColor
        
        if let count = self.navigationController?.viewControllersCount {
            self.textField.stringValue = String(count)
        }
    }
}
