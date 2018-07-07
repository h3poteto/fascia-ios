//
//  ContactViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2018/07/07.
//  Copyright © 2018年 h3poteto. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift
import RxCocoa
import WebKit

class ContactViewController: UIViewController, WKNavigationDelegate, SideMenuable {

    private let viewModel = ContactViewModel()
    private var hud = HUDManager()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)

    @IBOutlet private weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuSetup(parentController: self)
        webView.navigationDelegate = self
        bindViewModel()
        guard let contactURL = viewModel.contactURL else {
            return
        }
        let url = URL(string: contactURL)
        let request = URLRequest(url: url!)
        webView.load(request)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading.asDriver())
    }
}
