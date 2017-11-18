//
//  Lists.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum ListsError: Error {
    case parserError
    case mappingError
}

class Lists: Mappable {
    var lists: [List] = []
    var noneList: List?

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        lists       <- map["Lists"]
        noneList    <- map["NoneList"]
    }
}
