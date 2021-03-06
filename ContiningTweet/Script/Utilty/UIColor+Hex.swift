//
//  UIColor+Hex.swift
//  ContiningTweet
//
//  Created by Oka Yuya on 2016/08/05.
//  Copyright © 2016年 nnsnodnb. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWithHex(_ hex: NSString, alpha: CGFloat) -> UIColor {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white;
        }
    }
    
    class func themeColor() -> UIColor {
        return self.colorWithHex("#3D3D3D", alpha: 1.0)
    }
}
