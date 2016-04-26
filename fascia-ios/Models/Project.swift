//
//  Project.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/26.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class Project: Mappable {
    var ID: Int64?
    var UserID: Int64?
    var Title: String?
    var Description: String?
    var ShowIssues: Bool?
    var ShowPullRequests: Bool?
    var RepositoryID: Int64?

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

    func mapping(map: Map) {
        ID                  <- map["ID"]
        UserID              <- map["UserID"]
        Title               <- map["Title"]
        Description         <- map["Description"]
        ShowIssues          <- map["ShowIssues"]
        ShowPullRequests    <- map["ShowPullRequests"]
        RepositoryID        <- map["RepositoryID"]
    }
}
