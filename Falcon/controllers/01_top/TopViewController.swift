//
//  TopViewController.swift
//  Falcon
//
//  Created by Oka Yuya on 2016/10/17.
//  Copyright © 2016年 nnsnodnb.moe. All rights reserved.
//

import UIKit
import Social
import Firebase
import GoogleMobileAds

enum TweetStyle: Int {
    case Text = 0
    case CameraRoll
    case Photo
}

class TopViewController: UIViewController {

    var selectedImage : UIImage?
    var twitterPostView = SLComposeViewController()
    
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let adUnitID = "ca-app-pub-3417597686353524/5064687299"
    let delay  = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
    
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
        outletSetup()
//        tweetButton.hidden = true
        userDefaults.setInteger(0, forKey: "numberOfTweet")
    }
    
    private func bannerSetup() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        offPopupAdvertisementView()
    }
    
    private func splashSetup() {
//        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//        if !self.userDefaults.boolForKey("enabled_preference") {
//            // Only Text
//            self.twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
//                switch result {
//                case SLComposeViewControllerResult.Done:
//                    guard let wself = self else {
//                        return
//                    }
//                    dispatch_after(wself.delay, dispatch_get_main_queue(), {
//                        wself.showTweetViewDialogWithImageFalse()
//                    })
//                case SLComposeViewControllerResult.Cancelled:
//                    guard let wself = self else {
//                        return
//                    }
//                    dispatch_after(wself.delay, dispatch_get_main_queue(), {
//                        wself.showTweetViewDialogWithImageFalse()
//                    })
//                }
//            }
//            bannerView.hidden = true
//            presentViewController(twitterPostView, animated: true, completion: nil)
//        } else {
//            // Enable With Image
//            tweetButton.hidden = false
//        }
    }
    
    private func firebaseSetup() {
        FIRAnalytics.logEventWithName(kFIREventSelectContent,
                                      parameters: [
                                        kFIRParameterContentType:"cont" as NSObject,
                                        kFIRParameterItemID:"1" as NSObject
            ])
        FIRAnalytics.setUserPropertyString("TopScreen", forName: "boot_application")
    }
    
    private func advertisementSetup() {
        if !userDefaults.boolForKey("isFirstLaunch") {
            userDefaults.setBool(true, forKey: "isFirstLaunch")
            userDefaults.setInteger(0, forKey: "numberOfTweet")
        }
    }
    
    private func outletSetup() {
//        tweetButton.exclusiveTouch = true
//        bannerView.exclusiveTouch = true
        
    }

    // MARK: - Private funtion
    private func onPopupAdvertisementView() {

    }
    
    private func offPopupAdvertisementView() {

    }
    
    private func showTweetViewDialogWithImageTrue(type: TweetStyle) {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        switch type {
        case .Text:
                twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
                    guard let wself = self else {
                        return
                    }
                    switch result {
                    case .Done:
                        dispatch_after(wself.delay, dispatch_get_main_queue(), {
                            if wself.userDefaults.integerForKey("numberOfTweet") == 5 {
                                wself.userDefaultsWithAdvertisement()
                            }
                        })
                    case .Cancelled:
                        break
                    }
                }
                presentViewController(twitterPostView, animated: true, completion: nil)
        case .CameraRoll:
            pickImageFromLibrary(.CameraRoll)
        case .Photo:
            pickImageFromLibrary(.Photo)
        }
    }
    
    private func showTweetViewDialogWithImageFalse() {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
            guard let wself = self else {
                return
            }
            switch result {
            case .Done:
                dispatch_after(wself.delay, dispatch_get_main_queue(), {
                    wself.countUpNumberOfTweet()
                    let numberOfTweet = wself.userDefaults.integerForKey("numberOfTweet")
                    if Float(numberOfTweet) - 0.5 > 2.5 {
                        wself.userDefaultsWithAdvertisement()
                    } else {
                        wself.showTweetViewDialogWithImageFalse()
                    }
                })
            case .Cancelled:
                dispatch_after(wself.delay, dispatch_get_main_queue(), {
                    wself.showTweetViewDialogWithImageFalse()
                })
            }
        }
        presentViewController(twitterPostView, animated: true, completion: nil)
    }
    
    private func userDefaultsWithAdvertisement() {
        userDefaults.setInteger(0, forKey: "numberOfTweet")
        onPopupAdvertisementView()
    }
    
    private func countUpNumberOfTweet() {
        let numberOfTweet = userDefaults.integerForKey("numberOfTweet") + 1
        userDefaults.setInteger(numberOfTweet, forKey: "numberOfTweet")
    }
    
    // MARK: - IBAction
    @IBAction func tweet(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "選択方法を選択",
                                                         message: nil,
                                                         preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: tweetButton.frame.origin.x + tweetButton.frame.size.width,
                                                                 y: tweetButton.frame.origin.y + tweetButton.frame.size.height / 2 - UIApplication.sharedApplication().statusBarFrame.height / 2,
                                                                 width: 20,
                                                                 height: 20)
        alert.popoverPresentationController?.sourceView = self.view
        
        let onlyText = UIAlertAction(title: "テキストのみ",
                                     style: .Default) { [weak self] action in
                                        guard let wself = self else {
                                            return
                                        }
                                        wself.showTweetViewDialogWithImageTrue(.Text)
        }
        
        let cameraRollImage = UIAlertAction(title: "カメラロールから選択",
                                            style: .Default) { [weak self] action in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.showTweetViewDialogWithImageTrue(.CameraRoll)
        }
        
        let cameraTakeImage = UIAlertAction(title: "カメラで撮影",
                                            style: .Default) { [weak self] action in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.showTweetViewDialogWithImageTrue(.Photo)
        }
        
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .Cancel) { action in }
        
        alert.addAction(onlyText)
        alert.addAction(cameraRollImage)
        alert.addAction(cameraTakeImage)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension TopViewController: UINavigationControllerDelegate {
    func pickImageFromLibrary(pickType: TweetStyle) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            let controller = UIImagePickerController()
            controller.delegate = self
            if pickType == .CameraRoll {
                controller.sourceType = .PhotoLibrary
            } else {
                controller.sourceType = .Camera
            }
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension TopViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let originImage = info[UIImagePickerControllerOriginalImage] {
            if let image = originImage as? UIImage {
                selectedImage = image
                twitterPostView.addImage(selectedImage)
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        twitterPostView.completionHandler = { [weak self]
            (result:SLComposeViewControllerResult) -> Void in
            guard let wself = self else {
                return
            }
            switch result {
            case .Done:
                wself.twitterPostView.removeAllImages()
                wself.userDefaultsWithAdvertisement()
            case .Cancelled:
                wself.twitterPostView.removeAllImages()
            }
        }
        presentViewController(twitterPostView, animated: true, completion: nil)
    }
}
