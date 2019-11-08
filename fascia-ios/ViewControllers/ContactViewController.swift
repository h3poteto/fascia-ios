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
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItem.Style.plain, target: nil, action: nil)

    @IBOutlet private weak var webView: WKWebView!

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!

    struct WebViewPage {
        var url: URL?
        init() {
            url = URL(string: "https://fascia.io")
        }
    }

    var pageInfo = WebViewPage()

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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.isLoading.value = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.isLoading.value = false
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        pageInfo.url = webView.url

        decisionHandler(WKNavigationActionPolicy.allow)
    }

    private func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading.asDriver())

        backButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.goBack()
            }, onError: nil, onCompleted: nil)
            .disposed(by: disposeBag)

        forwardButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.goForward()
            }, onError: nil, onCompleted: nil)
            .disposed(by: disposeBag)

        reloadButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.reload()
            }, onError: nil, onCompleted: nil)
            .disposed(by: disposeBag)

        shareButton
            .rx
            .tap
            .subscribe(onNext: { () in
                guard let shareURL = self.pageInfo.url else {
                    return
                }
                let activityItems = [shareURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

                let excludedActivityTypes = [
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.message,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.print
                ]

                activityVC.excludedActivityTypes = excludedActivityTypes

                // UIActivityViewControllerを表示
                self.present(activityVC, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil)
            .disposed(by: disposeBag)
    }
}
