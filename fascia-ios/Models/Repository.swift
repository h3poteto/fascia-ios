//
//  Repository.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/03.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum RepositoryError: Error {
    case parserError
}

class Repository: Mappable {
    var id: Int?
    var name: String?
    var fullName: String?
    var ownerName: String?
    var privateRepository: Bool?

    class func buildWithArray(repositories: [[String: AnyObject]]) -> [Repository] {
        var arr: [Repository] = []
        for dict in repositories {
            if let repository = Mapper<Repository>().map(JSON: dict) {
                arr.append(repository)
            }
        }
        return arr
    }

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        fullName            <- map["full_name"]
        ownerName           <- map["owner.login"]
        privateRepository   <- map["private"]
    }
}

extension Repository: CustomStringConvertible {
    internal var description: String {
        return "{id:\(id), name:\(name), full_name:\(fullName), owner:\(ownerName), private:\(privateRepository)}"
    }
}
