//
//  ListsViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import Colours

class ListsViewModel {
    final private let action = ListsAction()
    final var lists: Lists?
    final private var project: Project!
    final private(set) var listsUpdated: Driver<Lists?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()
    var contextMenuVisible = false

    init(project: Project) {
        self.project = project
        listsUpdated = Driver
            .combineLatest(
                action.lists.asDriver(),
                action.error.asDriver().map({
                    $0 != nil
                }), resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        error = action.error.asDriver()
    }

    func fetch() {
        action.request(project.id!)
    }

    func contextItems() -> [ContextItem] {
        var items: [ContextItem] = []
        guard let noneList = self.lists?.noneList else {
            return []
        }
        let noneListColor = UIColor(hex: noneList.color!)
        items.append(ContextItem(
            title: noneList.title!,
            image: UIImage.imageWithString(
                String(noneList.title![noneList.title!.startIndex]),
                foregroundColor: noneListColor.blackOrWhiteContrastingColor(),
                backgroundColor: noneListColor,
                shadowColor: noneListColor.complementaryColor())!,
            highlightedImage: UIImage.imageWithString(
                String(noneList.title![noneList.title!.startIndex]),
                foregroundColor: noneListColor.blackOrWhiteContrastingColor(),
                backgroundColor: noneListColor.darkenedColor(0.25),
                shadowColor: noneListColor.complementaryColor())!))

        guard let lists = self.lists?.lists else {
            return []
        }
        for list in lists {
            let listColor = UIColor(hex: list.color!)
            let contrastColor = listColor.blackOrWhiteContrastingColor()
            items.append(ContextItem(
                title: list.title!,
                image: UIImage.imageWithString(
                    String(list.title![list.title!.startIndex]),
                    foregroundColor: contrastColor,
                    backgroundColor: listColor,
                    shadowColor: listColor.complementaryColor())!,
                highlightedImage: UIImage.imageWithString(
                    String(list.title![list.title!.startIndex]),
                    foregroundColor: contrastColor,
                    backgroundColor: listColor.darkenedColor(0.25),
                    shadowColor: listColor.complementaryColor())!))
        }
        return items
    }
}
