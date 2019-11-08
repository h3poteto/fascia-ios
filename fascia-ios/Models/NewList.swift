//
//  NewList.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper
import ChameleonFramework

class NewList: Mappable {
    var title: String?
    var color: String? = (UIColor.flatSkyBlue().hexValue() as NSString).substring(from: 1)

    required init?(map: Map) {
        mapping(map: map)
    }

    init() {
    }

    func mapping(map: Map) {
        title <- map["title"]
        color <- map["color"]
    }
}

extension NewList: CustomStringConvertible {
    var description: String {
        return "{title: \(String(describing: title)), color: \(String(describing: color))}"
    }
}
