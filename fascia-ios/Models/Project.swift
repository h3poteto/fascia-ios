//
//  Project.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/26.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum ProjectError: ErrorType {
    case MappingError
    case PaserError
}

class Project: Mappable {
    var id: Int64?
    var userID: Int64?
    var title: String?
    var description: String?
    var showIssues: Bool?
    var showPullRequests: Bool?
    var repositoryID: Int64?

    class func buildWithArray(projects: [[String: AnyObject]]) -> [Project] {
        var arr: [Project] = []
        for dict in projects {
            if let project = Mapper<Project>().map(dict) {
                arr.append(project)
            }
        }
        return arr
    }

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        id                  <- map["ID"]
        userID              <- map["UserID"]
        title               <- map["Title"]
        description         <- map["Description"]
        showIssues          <- map["ShowIssues"]
        showPullRequests    <- map["ShowPullRequests"]
        repositoryID        <- map["RepositoryID"]
    }
}
