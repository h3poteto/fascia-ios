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

protocol ContextMenuDelegate {
    func itemTap(item: ContextItem, task: Task) -> Void
    func closeContextMenu() -> Void
}

enum CircleMenu {
    case upSemicircle
    case downSemicircle
    case leftSemicircle
    case rightSemicircle
    case leftUpQuadrant
    case rightUpQuadrant
    case leftDownQuadrant
    case rightDownQuadrant
}

class ContextItem {
    var object: AnyObject?
    var title: String!
    var image: UIImage!
    var highlightedImage: UIImage!

    init(title: String, image: UIImage, highlightedImage: UIImage, object: AnyObject?) {
        self.title = title
        self.image = image
        self.highlightedImage = highlightedImage
        self.object = object
    }
}

class ContextMenuViewController: UIViewController {
    var contextParent: UITableViewController?
    var items: [ContextItem] = []
    private let circleRadius = CGFloat(80.0)
    private let itemRadius = CGFloat(30.0)
    private let margin = CGFloat(20.0)
    private let disposeBag = DisposeBag()
    var delegate: ContextMenuDelegate!
    var selectedTask: Task?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(items: [ContextItem], task: Task, inViewController: UITableViewController) {
        self.init()
        self.contextParent = inViewController
        self.items = items
        self.selectedTask = task
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        bindViewModel()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    func start(_ recognizer: UIGestureRecognizer) {
        guard let parentView = contextParent else {
            return
        }
        var offset = parentView.tableView.contentOffset.y
        if let navigationHeight = self.navigationController?.navigationBar.frame.size.height {
            offset += navigationHeight
        }
        parentView.view.addSubview(self.view)
        self.view.frame = CGRect.init(x: 0, y: offset, width: parentView.view.frame.size.width, height: parentView.view.frame.size.height)
        parentView.addChildViewController(self)
        parentView.didMove(toParentViewController: parentView)
        parentView.tableView.isScrollEnabled = false

        let touchPoint = recognizer.location(in: self.view)
        var windowRect = self.view.bounds
        windowRect.origin.y += self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height

        var circle = CircleMenu.upSemicircle
        if touchPoint.x - windowRect.origin.x < self.circleRadius {
            // 右向きの円しか使えない
            if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
                // 右下向きの円しか使えない
                circle = CircleMenu.rightDownQuadrant
            } else if windowRect.height - touchPoint.y < self.circleRadius {
                // 右上向きの円しか使えない
                circle = CircleMenu.rightUpQuadrant
            } else {
                circle = CircleMenu.rightSemicircle
            }
        } else if windowRect.width - touchPoint.x < self.circleRadius {
            // 左向きの円しか使えない
            if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
                // 左下向きの円しか使えない
                circle = CircleMenu.leftDownQuadrant
            } else if windowRect.height - touchPoint.y < self.circleRadius {
                // 左上向きの円しか使えない
                circle = CircleMenu.leftUpQuadrant
            } else {
                circle = CircleMenu.leftSemicircle
            }
        } else if touchPoint.y - margin - windowRect.origin.y < self.circleRadius {
            // 下向きの円しか使えない
            circle = CircleMenu.downSemicircle
        } else {
            // 他のパターンでは全て上半円を使う
            circle = CircleMenu.upSemicircle
        }

        showItems(menu: circle, point: touchPoint)
        showSelectedCircle(point: touchPoint)
    }

    private func showSelectedCircle(point: CGPoint) {
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.flatPowderBlue.cgColor
        circleLayer.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0).cgColor
        circleLayer.lineWidth = 2.0

        self.view.layer.addSublayer(circleLayer)

        let circleAnimation = CABasicAnimation(keyPath: "path")
        circleAnimation.fromValue = UIBezierPath(arcCenter: point, radius: 25.0, startAngle: 0, endAngle: 2.0 * CGFloat(Double.pi), clockwise: true).cgPath
        circleAnimation.toValue = UIBezierPath(arcCenter: point, radius: 15.0, startAngle: 0, endAngle: 2.0 * CGFloat(Double.pi), clockwise: true).cgPath
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 0.7
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
        animationGroup.animations = [circleAnimation, opacityAnimation]
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        circleLayer.add(animationGroup, forKey: nil)

    }

    //----------------------------------------------
    // PIの場合：
    // itemが1つであれば，PI/2の位置に配置したい
    // itemが2つであれば，0とPIに配置したい
    // itemが3であれば，0，PI/2，PIに配置したい
    // itemが4つであれば，PI/3ごとに配置したい
    // 0を起点として，PI/(n - 1)ごと
    // ただし，itemが1のことはありえない．デフォルトのリストは削除させないので，最低でも4つのリストが存在する．
    //----------------------------------------------
    private func showItems(menu: CircleMenu, point: CGPoint) {
        let itemCount = items.count
        if itemCount < 2 {
            return
        }

        switch menu {
        case .upSemicircle:
            let singleRadius = CGFloat(Double.pi / Double(itemCount - 1))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius)
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius)
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .downSemicircle:
            let singleRadius = CGFloat(Double.pi / Double(itemCount - 1))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius - CGFloat(Double.pi))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius - CGFloat(Double.pi))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .rightSemicircle:
            let singleRadius = CGFloat(Double.pi / Double(itemCount - 1))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius - CGFloat(Double.pi / 2.0))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius - CGFloat(Double.pi / 2.0))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .leftSemicircle:
            let singleRadius = CGFloat(Double.pi / Double(itemCount - 1))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius + CGFloat(Double.pi / 2.0))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius + CGFloat(Double.pi / 2.0))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .rightUpQuadrant:
            let singleRadius = CGFloat(Double.pi / (2.0 * Double(itemCount - 1)))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius)
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius)
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .rightDownQuadrant:
            let singleRadius = CGFloat(Double.pi / (2.0 * Double(itemCount - 1)))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius - CGFloat(Double.pi / 2.0))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius - CGFloat(Double.pi / 2.0))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .leftUpQuadrant:
            let singleRadius = CGFloat(Double.pi / (2.0 * Double(itemCount - 1)))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius + CGFloat(Double.pi / 2.0))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius + CGFloat(Double.pi / 2.0))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        case .leftDownQuadrant:
            let singleRadius = CGFloat(Double.pi / (2.0 * Double(itemCount - 1)))
            for (index, item) in items.enumerated() {
                let delta_x = circleRadius * cos(CGFloat(index) * singleRadius - CGFloat(Double.pi))
                let delta_y = circleRadius * sin(CGFloat(index) * singleRadius - CGFloat(Double.pi))
                displayItem(item: item, point: CGPoint(x: point.x + delta_x, y: point.y - delta_y), startPos: point)
            }
            break
        }
    }

    // 現状ではタップで遷移させている
    // もしD&Dで実現するならラベルも出せる
    private func displayItem(item: ContextItem, point: CGPoint, startPos: CGPoint) {
        let circleImageButton = UIButton(type: UIButtonType.custom)
        circleImageButton.setBackgroundImage(item.image, for: UIControlState())
        circleImageButton.setBackgroundImage(item.highlightedImage, for: .highlighted)
        circleImageButton.setBackgroundImage(item.highlightedImage, for: .selected)
        circleImageButton.frame = CGRect(x: startPos.x, y: startPos.y, width: itemRadius, height: itemRadius)
        circleImageButton.alpha = 0.0
        circleImageButton.layer.cornerRadius = circleImageButton.frame.size.width * 0.5
        circleImageButton.layer.borderColor = UIColor.white.cgColor
        circleImageButton.layer.borderWidth = 1.0
        circleImageButton.clipsToBounds = true

        // animation
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                circleImageButton.alpha = 1.0
                circleImageButton.frame = CGRect(x: point.x - self.itemRadius / 2.0, y: point.y - self.itemRadius / 2.0, width: self.itemRadius, height: self.itemRadius)
            }, completion: nil)

        self.view.addSubview(circleImageButton)

        circleImageButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.selectedItem(item: item)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

    private func selectedItem(item: ContextItem) {
        guard let task = self.selectedTask else {
            return
        }
        delegate.itemTap(item: item, task: task)
        end()
    }

    func end() {
        self.view.removeFromSuperview()
        self.contextParent?.tableView.isScrollEnabled = true
        delegate.closeContextMenu()
    }

    func tapped(_ sender: UIGestureRecognizer) {
        end()
    }

    private func bindViewModel() {
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContextMenuViewController.tapped(_:))))
    }
}
