//
//  Lists.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum ListsError: ErrorType {
    case ParserError
    case MappingError
}

class Lists: Mappable {
    var lists: Array<List> = []
    var noneList: List?

    required init?(_ map: Map) {
        mapping(map)
    }

    func mapping(map: Map) {
        lists       <- map["Lists"]
        noneList    <- map["NoneList"]
    }
}
