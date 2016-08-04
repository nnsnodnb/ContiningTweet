//
//  UIColor+Hex.swift
//  ContiningTweet
//
//  Created by Oka Yuya on 2016/08/05.
//  Copyright © 2016年 nnsnodnb. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWithHex(hex: NSString, alpha: CGFloat) -> UIColor {
        let hex = hex.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hex as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.whiteColor();
        }
    }
}
