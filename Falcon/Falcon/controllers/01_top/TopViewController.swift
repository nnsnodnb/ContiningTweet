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
    case text = 0
    case cameraRoll
    case photo
}

class TopViewController: UIViewController {

    var selectedImage : UIImage?
    var twitterPostView = SLComposeViewController()
    
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let userDefaults = UserDefaults.standard
    let adUnitID = "ca-app-pub-3417597686353524/5064687299"
    let delay  = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        splashSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup
    fileprivate func setup() {
        bannerSetup()
        splashSetup()
        firebaseSetup()
        advertisementSetup()
        outletSetup()
        tweetButton.isHidden = true
        userDefaults.set(0, forKey: "numberOfTweet")
        userDefaults.synchronize()
    }
    
    fileprivate func bannerSetup() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    fileprivate func splashSetup() {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if !userDefaults.bool(forKey: "enabled_preference") {
            // Only Text
            twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.done:
                    guard let wself = self else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: wself.delay, execute: {
                        wself.showTweetViewDialogWithImageFalse()
                    })
                case SLComposeViewControllerResult.cancelled:
                    guard let wself = self else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: wself.delay, execute: {
                        wself.showTweetViewDialogWithImageFalse()
                    })
                }
            }
            bannerView.isHidden = true
            present(twitterPostView, animated: true, completion: nil)
        } else {
            // Enable With Image
            tweetButton.isHidden = false
            bannerView.isHidden = false
        }
    }
    
    fileprivate func firebaseSetup() {
        FIRAnalytics.logEvent(withName: kFIREventSelectContent,
                                      parameters: [
                                        kFIRParameterContentType:"cont" as NSObject,
                                        kFIRParameterItemID:"1" as NSObject
            ])
        FIRAnalytics.setUserPropertyString("TopScreen", forName: "boot_application")
    }
    
    fileprivate func advertisementSetup() {
        if !userDefaults.bool(forKey: "isFirstLaunch") {
            userDefaults.set(true, forKey: "isFirstLaunch")
            userDefaults.set(0, forKey: "numberOfTweet")
            userDefaults.synchronize()
        }
    }
    
    fileprivate func outletSetup() {
        tweetButton.isExclusiveTouch = true
        bannerView.isExclusiveTouch = true
    }

    // MARK: - Private function
    fileprivate func onPopupAdvertisementView() {
        let controller: PopupViewController = storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        present(controller, animated: false, completion: nil)
    }
    
    fileprivate func showTweetViewDialogWithImageTrue(_ type: TweetStyle) {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        switch type {
        case .text:
                twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
                    guard let wself = self else {
                        return
                    }
                    switch result {
                    case .done:
                        DispatchQueue.main.asyncAfter(deadline: wself.delay, execute: {
                            if wself.userDefaults.integer(forKey: "numberOfTweet") == 5 {
                                wself.userDefaultsWithAdvertisement()
                            }
                        })
                    case .cancelled:
                        break
                    }
                }
                present(twitterPostView, animated: true, completion: nil)
        case .cameraRoll:
            pickImageFromLibrary(.cameraRoll)
        case .photo:
            pickImageFromLibrary(.photo)
        }
    }
    
    fileprivate func showTweetViewDialogWithImageFalse() {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twitterPostView.completionHandler = { [weak self] (result:SLComposeViewControllerResult) -> Void in
            guard let wself = self else {
                return
            }
            switch result {
            case .done:
                DispatchQueue.main.asyncAfter(deadline: wself.delay, execute: {
                    wself.countUpNumberOfTweet()
                    if wself.userDefaults.integer(forKey: "numberOfTweet") == 4 {
                        wself.userDefaultsWithAdvertisement()
                    } else {
                        wself.showTweetViewDialogWithImageFalse()
                    }
                })
            case .cancelled:
                DispatchQueue.main.asyncAfter(deadline: wself.delay, execute: {
                    wself.showTweetViewDialogWithImageFalse()
                })
            }
        }
        present(twitterPostView, animated: true, completion: nil)
    }
    
    fileprivate func userDefaultsWithAdvertisement() {
        userDefaults.set(0, forKey: "numberOfTweet")
        userDefaults.synchronize()
        onPopupAdvertisementView()
    }
    
    fileprivate func countUpNumberOfTweet() {
        let numberOfTweet = userDefaults.integer(forKey: "numberOfTweet") + 1
        userDefaults.set(numberOfTweet, forKey: "numberOfTweet")
        userDefaults.synchronize()
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
        
        let onlyText = UIAlertAction(title: "テキストのみ",
                                     style: .default) { [weak self] action in
                                        guard let wself = self else {
                                            return
                                        }
                                        wself.showTweetViewDialogWithImageTrue(.text)
        }
        
        let cameraRollImage = UIAlertAction(title: "カメラロールから選択",
                                            style: .default) { [weak self] action in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.showTweetViewDialogWithImageTrue(.cameraRoll)
        }
        
        let cameraTakeImage = UIAlertAction(title: "カメラで撮影",
                                            style: .default) { [weak self] action in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.showTweetViewDialogWithImageTrue(.photo)
        }
        
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .cancel) { action in }
        
        alert.addAction(onlyText)
        alert.addAction(cameraRollImage)
        alert.addAction(cameraTakeImage)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension TopViewController: UINavigationControllerDelegate {
    func pickImageFromLibrary(_ pickType: TweetStyle) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let controller = UIImagePickerController()
            controller.delegate = self
            if pickType == .cameraRoll {
                controller.sourceType = .photoLibrary
            } else {
                controller.sourceType = .camera
            }
            
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension TopViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originImage = info[UIImagePickerControllerOriginalImage] {
            if let image = originImage as? UIImage {
                selectedImage = image
                twitterPostView.add(selectedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
        twitterPostView.completionHandler = { [weak self]
            (result:SLComposeViewControllerResult) -> Void in
            guard let wself = self else {
                return
            }
            switch result {
            case .done:
                wself.twitterPostView.removeAllImages()
                wself.userDefaultsWithAdvertisement()
            case .cancelled:
                wself.twitterPostView.removeAllImages()
            }
        }
        present(twitterPostView, animated: true, completion: nil)
    }
}
