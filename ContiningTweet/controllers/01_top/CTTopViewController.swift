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

enum TweetStyle {
    case Text
    case CameraRoll
    case Photo
}

class CTTopViewController: UIViewController {

    var selectedImage : UIImage?
    var twitterPostView = SLComposeViewController()
    
    @IBOutlet weak var tweetButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweetButton.hidden = true
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "twitterLogo")!,
                                                      iconInitialSize: CGSizeMake(100, 100),
                                                      backgroundColor: UIColor.colorWithHex("#3D3D3D", alpha: 1.0))
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.animationType = SplashAnimationType.Twitter
        revealingSplashView.startAnimation() {
            if !self.userDefaults.boolForKey("enabled_preference") {
                self.showTweetViewDialog(.Text)
            } else {
                self.tweetButton.hidden = false
            }
        }
        
        self.view.backgroundColor = UIColor.colorWithHex("#3D3D3D", alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tweet(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "選択方法を選択",
                                                         message: nil,
                                                         preferredStyle: .ActionSheet)
        
        let onlyText = UIAlertAction(title: "テキストのみ",
                                     style: .Default) { action in
                                        self.showTweetViewDialog(.Text)
        }
        
        let cameraRollImage = UIAlertAction(title: "カメラロールから選択",
                                            style: .Default) { action in
                                                self.showTweetViewDialog(.CameraRoll)
        }
        
        let cameraTakeImage = UIAlertAction(title: "カメラで撮影",
                                            style: .Default) { action in
                                                self.showTweetViewDialog(.Photo)
        }
        
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .Cancel) { action in }
        
        alert.addAction(onlyText)
        alert.addAction(cameraRollImage)
        alert.addAction(cameraTakeImage)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showTweetViewDialog(type:TweetStyle) {
        twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        switch type {
        case .Text:
            if !self.userDefaults.boolForKey("enabled_preference") {
                twitterPostView.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.Done:
                        dispatch_after(self.delayTime, dispatch_get_main_queue()) {
                            self.showTweetViewDialog(.Text)
                        }
                    case SLComposeViewControllerResult.Cancelled:
                        dispatch_after(self.delayTime, dispatch_get_main_queue()) {
                            self.showTweetViewDialog(.Text)
                        }
                    }
                }
            }
            self.presentViewController(twitterPostView, animated: true, completion: nil)
        case .CameraRoll:
            pickImageFromLibrary(.CameraRoll)
        case .Photo:
            pickImageFromLibrary(.Photo)
        }
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
            case SLComposeViewControllerResult.Cancelled:
                self.twitterPostView.removeAllImages()
            }
        }
        
        self.presentViewController(twitterPostView, animated: true, completion: nil)
    }
}
