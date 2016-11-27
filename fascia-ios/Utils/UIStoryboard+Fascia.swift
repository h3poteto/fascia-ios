//
//  UIStoryboard+Fascia.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateViewController(_ identifier: String, storyboardName: String) -> AnyObject! {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
