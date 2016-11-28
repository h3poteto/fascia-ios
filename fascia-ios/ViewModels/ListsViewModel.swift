//
//  ListsViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ChameleonFramework

class ListsViewModel {
    final fileprivate let action = ListsAction()
    final var lists: Lists?
    var project: Project!
    final fileprivate(set) var listsUpdated: Driver<Lists?> = Driver.never()
    final fileprivate(set) var isLoading: Driver<Bool> = Driver.never()
    final fileprivate(set) var err: Driver<Error?> = Driver.never()
    var contextMenuVisible = false

    init(project: Project) {
        self.project = project
        listsUpdated = Driver
            .combineLatest(
                action.lists.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }), resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
    }

    func fetch() {
        action.request(projectID: project.id!)
    }

    func contextItems() -> [ContextItem] {
        var items: [ContextItem] = []
        guard let noneList = self.lists?.noneList else {
            return []
        }
        let noneListColor = UIColor(hexString: noneList.color!)!
        items.append(ContextItem(
            title: noneList.title!,
            image: UIImage.imageWithString(
                text: String(noneList.title![noneList.title!.startIndex]),
                foregroundColor: ContrastColorOf(noneListColor, returnFlat: false),
                backgroundColor: noneListColor,
                shadowColor: ComplementaryFlatColorOf(noneListColor))!,
            highlightedImage: UIImage.imageWithString(
                text: String(noneList.title![noneList.title!.startIndex]),
                foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: noneListColor, isFlat: false),
                backgroundColor: noneListColor.darken(byPercentage: 0.25)!,
                shadowColor: ComplementaryFlatColorOf(noneListColor))!,
            object: noneList
            )
        )

        guard let lists = self.lists?.lists else {
            return []
        }
        for list in lists {
            let listColor = UIColor(hexString: list.color!)!
            let contrastColor = ContrastColorOf(listColor, returnFlat: false)
            items.append(ContextItem(
                title: list.title!,
                image: UIImage.imageWithString(
                    text: String(list.title![list.title!.startIndex]),
                    foregroundColor: contrastColor,
                    backgroundColor: listColor,
                    shadowColor: ComplementaryFlatColorOf(listColor))!,
                highlightedImage: UIImage.imageWithString(
                    text: String(list.title![list.title!.startIndex]),
                    foregroundColor: contrastColor,
                    backgroundColor: listColor.darken(byPercentage: 0.25)!,
                    shadowColor: ComplementaryFlatColorOf(listColor))!,
                object: list
                )
            )
        }
        return items
    }

    func moveRequest(_ item: ContextItem, task: Task) {
        guard let list = item.object as? List else {
            return
        }
        action.moveRequest(projectID: project.id!, taskID: task.id!, listID: task.listID!, toListID: list.id!)
    }
}
