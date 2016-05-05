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
    case ParserError
}

class Project: Mappable {
    var id: Int?
    var userID: Int?
    var title: String?
    var projectDescription: String?
    var showIssues: Bool?
    var showPullRequests: Bool?
    var repositoryID: Int?

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
        projectDescription  <- map["Description"]
        showIssues          <- map["ShowIssues"]
        showPullRequests    <- map["ShowPullRequests"]
        repositoryID        <- map["RepositoryID"]
    }
}

extension Project: CustomStringConvertible {
    internal var description: String {
        return "{id:\(id), userID:\(userID), title:\(title), description:\(projectDescription), showIssues:\(showIssues), showPullRequests:\(showPullRequests), repositoryID:\(repositoryID)}"
    }
}
