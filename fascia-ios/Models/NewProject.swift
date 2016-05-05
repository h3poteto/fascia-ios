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

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        title               <- map["title"]
        projectDescription  <- map["description"]
        repositoryID        <- map["repositoryID"]
        repositoryOwner     <- map["repositoryOwner"]
        repositoryName      <- map["repositoryName"]
    }
}

extension NewProject: CustomStringConvertible {
    internal var description: String {
        return "{title:\(title), description:\(projectDescription), repositoryID:\(repositoryID), repositoryOwner:\(repositoryOwner), repositoryName:\(repositoryName)}"
    }
}
