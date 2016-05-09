//
//  ContextMenuViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/09.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum CircleMenu {
    case UpSemicircle
    case DownSemicircle
    case LeftSemicircle
    case RightSemicircle
    case LeftUpQuadrant
    case RightUpQuadrant
    case LeftDownQuadrant
    case RightDownQuadrant
}

class ContextItem {
    var title: String!
    var image: UIImage!
    var highlightedImage: UIImage!

    init(title: String, image: UIImage, highlightedImage: UIImage) {
        self.title = title
        self.image = image
        self.highlightedImage = highlightedImage
    }
}

class ContextMenuViewController: UIViewController {
    var parent: UITableViewController?
    var items: [ContextItem] = []
    private let circleRadius = CGFloat(80.0)
    private let itemRadius = CGFloat(30.0)
    private let margin = CGFloat(20.0)
    final private let pi = CGFloat(3.14159265359)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(items: [ContextItem], inViewController: UITableViewController) {
        self.init()
        self.parent = inViewController
        self.items = items
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "000000", alpha: 0.5)
        bindViewModel()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }

    func start(recognizer: UIGestureRecognizer) {
        guard let parentView = parent else {
            return
        }
        var offset = parentView.tableView.contentOffset.y
        if let navigationHeight = self.navigationController?.navigationBar.frame.size.height {
            offset += navigationHeight
        }
        parentView.view.addSubview(self.view)
        self.view.frame = CGRect.init(x: 0, y: offset, width: parentView.view.frame.size.width, height: parentView.view.frame.size.height)
        parentView.addChildViewController(self)
        parentView.didMoveToParentViewController(parentView)
        parentView.tableView.scrollEnabled = false

        let touchPoint = recognizer.locationInView(self.view)
        var windowRect = self.view.bounds
        windowRect.origin.y += self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height

        var circle = CircleMenu.UpSemicircle
        if touchPoint.x - windowRect.origin.x < self.circleRadius {
            // 右向きの円しか使えない
            if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
                // 右下向きの円しか使えない
                circle = CircleMenu.RightDownQuadrant
            } else if windowRect.height - touchPoint.x < self.circleRadius {
                // 右上向きの円しか使えない
                circle = CircleMenu.RightUpQuadrant
            } else {
                circle = CircleMenu.RightSemicircle
            }
        } else if windowRect.width - touchPoint.x < self.circleRadius {
            // 左向きの円しか使えない
            if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
                // 左下向きの円しか使えない
                circle = CircleMenu.LeftDownQuadrant
            } else if windowRect.height - touchPoint.x < self.circleRadius {
                // 左上向きの円しか使えない
                circle = CircleMenu.LeftUpQuadrant
            } else {
                circle = CircleMenu.LeftSemicircle
            }
        } else if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
            // 下向きの円しか使えない
            circle = CircleMenu.DownSemicircle
        } else {
            // 他のパターンでは全て上半円を使う
            circle = CircleMenu.UpSemicircle
        }

        showItems(circle, point: touchPoint)
    }

    private func showItems(menu: CircleMenu, point: CGPoint) {
        let itemCount = items.count

        switch menu {
        case .UpSemicircle:
            let singleRadius = pi / CGFloat(itemCount + 1)
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .DownSemicircle:
            let singleRadius = pi / CGFloat(itemCount + 1)
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius - pi)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius - pi)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .RightSemicircle:
            let singleRadius = pi / CGFloat(itemCount + 1)
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius - pi / 2.0)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius - pi / 2.0)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .LeftSemicircle:
            let singleRadius = pi / CGFloat(itemCount + 1)
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius + pi / 2.0)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius + pi / 2.0)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .RightUpQuadrant:
            let singleRadius = pi / (2.0 * CGFloat(itemCount + 1))
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .RightDownQuadrant:
            let singleRadius = pi / (2.0 * CGFloat(itemCount + 1))
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius - pi / 2.0)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius - pi / 2.0)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .LeftUpQuadrant:
            let singleRadius = pi / (2.0 * CGFloat(itemCount + 1))
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius + pi / 2.0)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius + pi / 2.0)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        case .LeftDownQuadrant:
            let singleRadius = pi / (2.0 * CGFloat(itemCount + 1))
            for (index, item) in items.enumerate() {
                let delta_x = circleRadius * cos(CGFloat(index + 1) * singleRadius - pi)
                let delta_y = circleRadius * sin(CGFloat(index + 1) * singleRadius - pi)
                displayItem(item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y))
            }
            break
        }
    }

    // TODO: これらのitemにタップイベントを登録する
    // TODO: できればラベルも表示したい
    // TODO: アニメーションをつけて表示したい
    private func displayItem(item: ContextItem, point: CGPoint) {
        let circleImageView = UIImageView(image: item.image, highlightedImage: item.highlightedImage)
        circleImageView.frame = CGRect.init(x: point.x - itemRadius / 2.0, y: point.y - itemRadius / 2.0, width: itemRadius, height: itemRadius)
        circleImageView.layer.cornerRadius = circleImageView.frame.size.width * 0.5
        circleImageView.clipsToBounds = true
        self.view.addSubview(circleImageView)
    }

    func end() {
        self.view.removeFromSuperview()
        self.parent?.tableView.scrollEnabled = true
    }

    func tapped(sender: UIGestureRecognizer) {
        end()
    }

    private func bindViewModel() {
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContextMenuViewController.tapped(_:))))
    }
}
