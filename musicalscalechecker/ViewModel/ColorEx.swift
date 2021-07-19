//
//  ColorEx.swift
//  MemoUI
//
//  Created by 松中誉生 on 2020/09/04.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
   init(hex: String) {
       let scanner = Scanner(string: hex)
       scanner.scanLocation = 0
       var rgbValue: UInt64 = 0
       scanner.scanHexInt64(&rgbValue)

       let r = (rgbValue & 0xff0000) >> 16
       let g = (rgbValue & 0xff00) >> 8
       let b = rgbValue & 0xff


       self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)

   }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }

    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    /// 四角
    func rectImage(width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(self.cgColor)
        contextRef?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /// 丸
    func circleImage(width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(self.cgColor)
        contextRef?.fillEllipse(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

