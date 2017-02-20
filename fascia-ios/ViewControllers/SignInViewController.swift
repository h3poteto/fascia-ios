//
//  SignInViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift
import RxCocoa

class SignInViewController: UIViewController, UIWebViewDelegate, SideMenuable {
    private let viewModel = SignInViewModel()
    private var hud = HUDManager()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)

    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    @IBOutlet private weak var forwardButton: UIBarButtonItem!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var reloadButton: UIBarButtonItem!

    struct WebViewPage {
        var title: String?
        var url: URL?
        init() {
            title = "Fascia"
            url = URL(string: "https://fascia.io")
        }
    }

    var pageInfo = WebViewPage()

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuSetup(parentController: self)
        bindViewModel()
        guard let signInURL = viewModel.signInURL else {
            return
        }
        let url = URL(string: signInURL)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        viewModel.isLoading.value = true
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        viewModel.isLoading.value = false
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        pageInfo.url = request.url
        pageInfo.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        if request.url?.host == URL(string: viewModel.signInURL!)?.host && request.url?.path == "/webviews/callback" {
            viewModel.update()
            viewModel.isLoading.value = false
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return false
        }
        return true
    }

    private func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading.asDriver())

        backButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.goBack()
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)

        forwardButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.goForward()
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)

        reloadButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.webView.reload()
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)

        shareButton
            .rx
            .tap
            .subscribe(onNext: { () in
                guard let shareText = self.pageInfo.title else {
                    return
                }
                guard let shareURL = self.pageInfo.url else {
                    return
                }
                let activityItems = [shareText, shareURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

                let excludedActivityTypes = [
                    UIActivityType.postToFacebook,
                    UIActivityType.postToTwitter,
                    UIActivityType.message,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.print
                ]

                activityVC.excludedActivityTypes = excludedActivityTypes

                // UIActivityViewControllerを表示
                self.present(activityVC, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)
    }
}
