//
//  NewProject.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/30.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class NewProject: Mappable {
    var title: String?
    var projectDescription: String?
    var repositoryID: Int?
    var repositoryOwner: String?
    var repositoryName: String?

    required init?(map: Map) {
        mapping(map: map)
    }

    init() {
    }

    func mapping(map: Map) {
        title               <- map["title"]
        projectDescription  <- map["description"]
        repositoryID        <- map["repository_id"]
        repositoryOwner     <- map["repositoryOwner"]
        repositoryName      <- map["repositoryName"]
    }
}

extension NewProject: CustomStringConvertible {
    internal var description: String {
        return "{title:\(String(describing: title)), description:\(String(describing: projectDescription)), repositoryID:\(String(describing: repositoryID)), repositoryOwner:\(String(describing: repositoryOwner)), repositoryName:\(String(describing: repositoryName))}"
    }
}
