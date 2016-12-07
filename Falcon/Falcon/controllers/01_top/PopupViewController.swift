//
//  PopupViewController.swift
//  Falcon
//
//  Created by Oka Yuya on 2016/10/17.
//  Copyright © 2016年 nnsnodnb.moe. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class PopupViewController: UIViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    let adUnitID = "ca-app-pub-3417597686353524/5064687299"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    fileprivate func setup() {
        bannerSetup()
    }
    
    fileprivate func bannerSetup() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissPopupView(_ sender: AnyObject) {
        dismiss(animated: false, completion: nil)
    }
}
