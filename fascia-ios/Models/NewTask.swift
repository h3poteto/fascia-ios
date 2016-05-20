//
//  NewTask.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class NewTask: Mappable {
    var title: String?
    var taskDescription: String?

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        title <- map["title"]
        taskDescription <- map["description"]
    }
}

extension NewTask: CustomStringConvertible {
    var description: String {
        return "{title: \(title), description: \(taskDescription)}"
    }
}
