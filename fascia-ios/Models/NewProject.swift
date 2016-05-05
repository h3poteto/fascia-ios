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
    var description: String?
    var repositoryID: Int?
    var repositoryOwner: String?
    var repositoryName: String?

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        title               <- map["title"]
        description         <- map["description"]
        repositoryID        <- map["repositoryID"]
        repositoryOwner     <- map["repositoryOwner"]
        repositoryName      <- map["repositoryName"]
    }
}
