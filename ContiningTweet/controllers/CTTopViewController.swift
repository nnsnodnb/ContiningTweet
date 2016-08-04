//
//  CTTopViewController.swift
//  ContiningTweet
//
//  Created by Oka Yuya on 2016/08/04.
//  Copyright © 2016年 nnsnodnb. All rights reserved.
//

import UIKit
import JKNotificationPanel

class CTTopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tweet(sender: AnyObject) {
        let panel = JKNotificationPanel()
        panel.show
    }
}

extension CTTopViewController: JKNotificationPanelDelegate {
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.panel.transitionToSize(self.view.frame.size)
            }, completion: nil)
    }
}