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

enum TweetStyle: Int {
    case text = 0
    case cameraRoll
    case photo
}

class CTTopViewController: UIViewController {
    
    var selectedImage : UIImage?
    var twitterPostView = SLComposeViewController()
    
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var popupAdvertisementView: GADBannerView!
    @IBOutlet weak var advertisementBackgruondView: UIView!
    @IBOutlet weak var advertisementCloseButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    let adUnitID = "ca-app-pub-3417597686353524/5064687299"
    
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
        tweetButton.isHidden = true
        view.backgroundColor = UIColor.themeColor()
        userDefaults.set(0, forKey: "numberOfTweet")
    }
    
    private func bannerSetup() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        popupAdvertisementView.adSize = kGADAdSizeMediumRectangle
        popupAdvertisementView.adUnitID = adUnitID
        popupAdvertisementView.rootViewController = self
        popupAdvertisementView.load(GADRequest())
        offPopupAdvertisementView()
    }
    
    private func splashSetup() {
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "twitterLogo")!,
                                                iconInitialSize: CGSize(width: 100, height: 100),
                                                backgroundColor: UIColor.themeColor())
        
        view.addSubview(revealingSplashView)
        
        revealingSplashView.animationType = SplashAnimationType.Twitter
        revealingSplashView.startAnimation() {
            self.twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            if !self.userDefaults.bool(forKey: "enabled_preference") {
                // Only Text
                self.twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.done:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            guard let wself = self else {
                                return
                            }
                            wself.showTweetViewDialogWithImageFalse()
                        }
                    case SLComposeViewControllerResult.cancelled:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            guard let wself = self else {
                                return
                            }
                            wself.showTweetViewDialogWithImageFalse()
                        }
                    }
                }
                self.bannerView.isHidden = true
                self.present(self.twitterPostView, animated: true, completion: nil)
            } else {
                // Enable With Image
                self.tweetButton.isHidden = false
            }
        }
    }
    
    private func firebaseSetup() {
        FIRAnalytics.logEvent(withName: kFIREventSelectContent,
                              parameters: [
                                kFIRParameterContentType:"cont" as NSObject,
                                kFIRParameterItemID:"1" as NSObject
            ])
        FIRAnalytics.setUserPropertyString("TopScreen", forName: "boot_application")
    }
    
    private func advertisementSetup() {
        if !userDefaults.bool(forKey: "isFirstLaunch") {
            userDefaults.set(true, forKey: "isFirstLaunch")
            userDefaults.set(0, forKey: "numberOfTweet")
        }
    }
    
    private func outletSetup() {
        tweetButton.isExclusiveTouch = true
        bannerView.isExclusiveTouch = true
        popupAdvertisementView.isExclusiveTouch = true
        advertisementBackgruondView.isExclusiveTouch = true
        advertisementCloseButton.isExclusiveTouch = true
    }
    
    // MARK: - IBAction
    @IBAction func tweet(_ sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "選択方法を選択",
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: tweetButton.frame.origin.x + tweetButton.frame.size.width,
                                                                     y: tweetButton.frame.origin.y + tweetButton.frame.size.height / 2 - UIApplication.shared.statusBarFrame.height / 2,
                                                                     width: 20,
                                                                     height: 20)
        alert.popoverPresentationController?.sourceView = self.view
        
        weak var wself = self
        let onlyText = UIAlertAction(title: "テキストのみ",
                                     style: .default) { action in
                                        wself?.showTweetViewDialogWithImageTrue(.text)
        }
        
        let cameraRollImage = UIAlertAction(title: "カメラロールから選択",
                                            style: .default) { action in
                                                wself?.showTweetViewDialogWithImageTrue(.cameraRoll)
        }
        
        let cameraTakeImage = UIAlertAction(title: "カメラで撮影",
                                            style: .default) { action in
                                                wself?.showTweetViewDialogWithImageTrue(.photo)
        }
        
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .cancel) { action in }
        
        alert.addAction(onlyText)
        alert.addAction(cameraRollImage)
        alert.addAction(cameraTakeImage)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func advertisementClose(_ sender: AnyObject) {
        offPopupAdvertisementView()
        if !userDefaults.bool(forKey: "enabled_preference") {
            showTweetViewDialogWithImageFalse()
        }
    }
    
    // MARK: - Private funtion
    fileprivate func onPopupAdvertisementView() {
        advertisementBackgruondView.isHidden = false
        popupAdvertisementView.isHidden = false
        advertisementCloseButton.isHidden = false
    }
    
    fileprivate func offPopupAdvertisementView() {
        advertisementBackgruondView.isHidden = true
        popupAdvertisementView.isHidden = true
        advertisementCloseButton.isHidden = true
    }
    
    fileprivate func showTweetViewDialogWithImageTrue(_ type:TweetStyle) {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        switch type {
        case .text:
            weak var wself = self
            twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.done:
                    wself?.countUpNumberOfTweet()
                    if let delayTime = wself?.delayTime {
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            if wself?.userDefaults.integer(forKey: "numberOfTweet") == 5 {
                                wself?.userDefaultsWithAdvertisement()
                            }
                        }
                    }
                case SLComposeViewControllerResult.cancelled:
                    break
                }
            }
            if let postView = wself?.twitterPostView {
                wself?.present(postView, animated: true, completion: nil)
            }
        case .cameraRoll:
            pickImageFromLibrary(.cameraRoll)
        case .photo:
            pickImageFromLibrary(.photo)
        }
    }
    
    fileprivate func showTweetViewDialogWithImageFalse() {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        weak var wself = self
        twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
            switch result {
            case SLComposeViewControllerResult.done:
                DispatchQueue.main.asyncAfter(deadline: self.delayTime) {
                    wself?.countUpNumberOfTweet()
                    if let numberOfTweet = wself?.userDefaults.integer(forKey: "numberOfTweet") {
                        if Float(numberOfTweet) - 0.5 > 2.5 {
                            wself?.userDefaultsWithAdvertisement()
                        } else {
                            wself?.showTweetViewDialogWithImageFalse()
                        }
                    }
                }
            case SLComposeViewControllerResult.cancelled:
                if let delayTime = wself?.delayTime {
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        wself?.showTweetViewDialogWithImageFalse()
                    }
                }
            }
        }
        present(twitterPostView, animated: true, completion: nil)
    }
    
    fileprivate func userDefaultsWithAdvertisement() {
        userDefaults.set(0, forKey: "numberOfTweet")
        onPopupAdvertisementView()
    }
    
    fileprivate func countUpNumberOfTweet() {
        let numberOfTweet = userDefaults.integer(forKey: "numberOfTweet") + 1
        userDefaults.set(numberOfTweet, forKey: "numberOfTweet")
    }
}

// MARK: - UINavigationControllerDelegate
extension CTTopViewController: UINavigationControllerDelegate {
    func pickImageFromLibrary(_ pickType: TweetStyle) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let controller = UIImagePickerController()
            controller.delegate = self
            if pickType == .cameraRoll {
                controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            } else {
                controller.sourceType = UIImagePickerControllerSourceType.camera
            }
            
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CTTopViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originImage = info[UIImagePickerControllerOriginalImage] {
            if let image = originImage as? UIImage {
                selectedImage = image
                twitterPostView.add(selectedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
        weak var wself = self
        twitterPostView.completionHandler = {
            (result:SLComposeViewControllerResult) -> Void in
            switch result {
            case SLComposeViewControllerResult.done:
                wself?.twitterPostView.removeAllImages()
                wself?.userDefaultsWithAdvertisement()
            case SLComposeViewControllerResult.cancelled:
                wself?.twitterPostView.removeAllImages()
            }
        }
        present(twitterPostView, animated: true, completion: nil)
    }
}
