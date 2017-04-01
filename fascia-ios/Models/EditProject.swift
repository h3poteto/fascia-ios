//
//  EditProject.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/23.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class EditProject: Mappable {
    var title: String?
    var projectDescription: String?

    required init?(map: Map) {
        mapping(map: map)
    }

    init() {
    }

    func mapping(map: Map) {
        title <- map["title"]
        projectDescription <- map["description"]
    }
}

extension EditProject: CustomStringConvertible {
    var description: String {
        return "{title: \(String(describing: title)), description: \(String(describing: projectDescription))}"
    }
}
