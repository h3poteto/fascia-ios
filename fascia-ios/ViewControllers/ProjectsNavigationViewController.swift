//
//  ProjectsNavigationViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/15.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift
import RxCocoa

protocol SideMenuable {
    var openSideMenu: UIBarButtonItem { get }
    func sideMenuSetup(parentController: UIViewController)
    var disposeBag: DisposeBag { get }
}

extension SideMenuable {
    func sideMenuSetup(parentController: UIViewController) {
        parentController.navigationItem.leftBarButtonItem = openSideMenu
        openSideMenu
            .rx
            .tap
            .subscribe(onNext: { () in
                parentController.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

class ProjectsNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let leftNav = UIStoryboard.instantiateViewController(identifier: "UISideMenuNavigationController", storyboardName: "Main") as? UISideMenuNavigationController else {
            return
        }
        SideMenuManager.default.menuLeftNavigationController = leftNav
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
