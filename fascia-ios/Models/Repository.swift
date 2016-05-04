//
//  Repository.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/03.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum RepositoryError: ErrorType {
    case ParserError
}

class Repository: Mappable {
    var id: Int64?
    var name: String?
    var fullName: String?
    var ownerName: String?

    class func buildWithArray(repositories: [[String: AnyObject]]) -> [Repository] {
        var arr: [Repository] = []
        for dict in repositories {
            if let repository = Mapper<Repository>().map(dict) {
                arr.append(repository)
            }
        }
        return arr
    }

    required init?(_ map: Map) {
        mapping(map)
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        fullName <- map["full_name"]
        ownerName <- map["owner"]["login"]
    }
}
