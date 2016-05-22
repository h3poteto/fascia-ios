//
//  NewList.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class NewList: Mappable {
    var title: String?
    var color: String? = (UIColor.pastelBlueColor().hexString() as NSString).substringFromIndex(1)

    required init?(_ map: Map) {
        mapping(map)
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
        return "{title: \(title), color: \(color)}"
    }
}
