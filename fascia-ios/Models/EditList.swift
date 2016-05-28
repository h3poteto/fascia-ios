//
//  EditList.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class EditList: Mappable {
    var title: String?
    var color: String?
    var action: String?

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        title <- map["title"]
        color <- map["color"]
        action <- map["action"]

    }
}

extension EditList: CustomStringConvertible {
    var description: String {
        return "{title: \(title), color: \(color), action: \(action)}"
    }
}
