//
//  CTTopViewController.swift
//  ContiningTweet
//
//  Created by Oka Yuya on 2016/08/04.
//  Copyright © 2016年 nnsnodnb. All rights reserved.
//

import UIKit
import Social
import RevealingSplashView
import Firebase
import FirebaseAnalytics
import GoogleMobileAds

enum TweetStyle {
    case Text
    case CameraRoll
    case Photo
}

class CTTopViewController: UIViewController {
    
    private var selectedImage : UIImage?
    private var twitterPostView = SLComposeViewController()
    
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
    private let adUnitID = "ca-app-pub-3417597686353524/5064687299"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup
    private func setup() {
        bannerSetup()
        splashSetup()
        firebaseSetup()
        advertisementSetup()
        self.tweetButton.hidden = true
        self.view.backgroundColor = UIColor.themeColor()
        userDefaults.setObject(0, forKey: "numberOfTweet")
    }
    
    private func bannerSetup() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
    }
    
    private func splashSetup() {
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "twitterLogo")!,
                                                iconInitialSize: CGSizeMake(100, 100),
                                                backgroundColor: UIColor.themeColor())
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.animationType = SplashAnimationType.Twitter
        revealingSplashView.startAnimation() {
            if !self.userDefaults.boolForKey("enabled_preference") {
                self.twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.Done:
                        self.showTweetViewDialogWithImageTrue(.Text)
                    case SLComposeViewControllerResult.Cancelled:
                        self.showTweetViewDialogWithImageFalse()
                    }
                }
                self.showTweetViewDialogWithImageTrue(.Text)
                self.bannerView.hidden = true
            } else {
                self.tweetButton.hidden = false
            }
        }
    }
    
    private func firebaseSetup() {
        FIRAnalytics.logEventWithName(kFIREventSelectContent,
                                      parameters: [
                                        kFIRParameterContentType:"cont",
                                        kFIRParameterItemID:"1"
            ])
        FIRAnalytics.setUserPropertyString("TopScreen", forName: "boot_application")
    }
    
    private func advertisementSetup() {
        if !userDefaults.boolForKey("isFirstLaunch") {
            userDefaults.setObject(true, forKey: "isFirstLaunch")
            userDefaults.setObject(0, forKey: "numberOfTweet")
        }
    }
    
    // MARK: - IBAction
    @IBAction func tweet(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "選択方法を選択",
                                                         message: nil,
                                                         preferredStyle: .ActionSheet)
        
        let onlyText = UIAlertAction(title: "テキストのみ",
                                     style: .Default) { action in
                                        if !self.userDefaults.boolForKey("enabled_preference") {
                                            self.showTweetViewDialogWithImageFalse()
                                        } else {
                                            self.showTweetViewDialogWithImageTrue(.Text)
                                        }
        }
        
        let cameraRollImage = UIAlertAction(title: "カメラロールから選択",
                                            style: .Default) { action in
                                                self.showTweetViewDialogWithImageTrue(.CameraRoll)
        }
        
        let cameraTakeImage = UIAlertAction(title: "カメラで撮影",
                                            style: .Default) { action in
                                                self.showTweetViewDialogWithImageTrue(.Photo)
        }
        
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .Cancel) { action in }
        
        alert.addAction(onlyText)
        alert.addAction(cameraRollImage)
        alert.addAction(cameraTakeImage)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private funtion
    private func showTweetViewDialogWithImageTrue(type:TweetStyle) {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        switch type {
        case .Text:
            self.presentViewController(self.twitterPostView, animated: true, completion: nil)
        case .CameraRoll:
            pickImageFromLibrary(.CameraRoll)
        case .Photo:
            pickImageFromLibrary(.Photo)
        }
    }
    
    private func showTweetViewDialogWithImageFalse() {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
            switch result {
            case SLComposeViewControllerResult.Done:
                let numberOfTweet = self.userDefaults.integerForKey("numberOfTweet") + 1
                self.userDefaults.setObject(numberOfTweet, forKey: "numberOfTweet")
                dispatch_after(self.delayTime, dispatch_get_main_queue()) {
                    if self.userDefaults.integerForKey("numberOfTweet") == 1 {
                        self.userDefaultsWithAdvertisement()
                    } else {
                        self.presentViewController(self.twitterPostView,
                                                   animated: true,
                                                   completion: nil)
                    }
                }
            case SLComposeViewControllerResult.Cancelled:
                dispatch_after(self.delayTime, dispatch_get_main_queue()) {
                    self.presentViewController(self.twitterPostView,
                                               animated: true,
                                               completion: nil)
                }
            }
        }
    }
    
    private func userDefaultsWithAdvertisement() {
        self.userDefaults.setObject(0, forKey: "numberOfTweet")
        let modalStoryboard = UIStoryboard(name: "CTAdvertisement", bundle: nil)
        let controller: CTAdvertisementViewController = modalStoryboard.instantiateViewControllerWithIdentifier("CTAdvertisement") as! CTAdvertisementViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(controller as UIViewController, animated: false, completion:nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension CTTopViewController: UINavigationControllerDelegate {
    func pickImageFromLibrary(pickType: TweetStyle) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            let controller = UIImagePickerController()
            controller.delegate = self
            if pickType == .CameraRoll {
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            } else {
                controller.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CTTopViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let originImage = info[UIImagePickerControllerOriginalImage] {
            if let image = originImage as? UIImage {
                selectedImage = image
                twitterPostView.addImage(selectedImage)
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
            switch result {
            case SLComposeViewControllerResult.Done:
                self.twitterPostView.removeAllImages()
                self.userDefaultsWithAdvertisement()
            case SLComposeViewControllerResult.Cancelled:
                self.twitterPostView.removeAllImages()
            }
        }
        
        self.presentViewController(twitterPostView, animated: true, completion: nil)
    }
}
