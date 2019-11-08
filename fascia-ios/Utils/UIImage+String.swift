//
//  UIImage+String.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/11.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithString(text: String, foregroundColor: UIColor, backgroundColor: UIColor, shadowColor: UIColor) -> UIImage? {
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0.0, height: -0.5)
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = 0.0

        let font = UIFont(name: "Avenir-Light", size: 16.0)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping

        let attributes = [
            NSAttributedString.Key.font: font!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.shadow: shadow,
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.backgroundColor: backgroundColor
        ]

        text.draw(in: CGRect(x: 0, y: 2, width: size.width, height: size.height), withAttributes: attributes)
        var image: UIImage? = nil
        image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
