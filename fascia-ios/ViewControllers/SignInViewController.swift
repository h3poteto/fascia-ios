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
import WebKit

class SignInViewController: UIViewController, WKNavigationDelegate, SideMenuable {
    private let viewModel = SignInViewModel()
    private var hud = HUDManager()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItem.Style.plain, target: nil, action: nil)

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    @IBOutlet private weak var forwardButton: UIBarButtonItem!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var reloadButton: UIBarButtonItem!

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
        guard let signInURL = viewModel.signInURL else {
            return
        }
        let url = URL(string: signInURL)
        let request = URLRequest(url: url!)
        webView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.isLoading.accept(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.isLoading.accept(false)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        pageInfo.url = webView.url

        if webView.url?.host == URL(string: viewModel.signInURL!)?.host && webView.url?.path == "/webviews/callback" {
            // WKWebViewはcookieの管理が別になる
            // ログインをWebViewでやる限り，WKWebView -> Alamofireへとsessionを共有する必要がある
            // そのためWKHTTPCookieStoreの中身をすべてHTTPCookieStorageに詰め込む
            // https://qiita.com/ShingoFukuyama/items/c2d33ff3fc36dbdb69a4
            let cookieStore: WKHTTPCookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { (cookies) in
                for cookie: HTTPCookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }

            viewModel.update()
            viewModel.isLoading.accept(false)
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // WKWebViewはcookieの管理が別になる
        // ログインをWebViewでやる限り，WKWebView -> Alamofireへとsessionを共有する必要がある
        // そのためWKHTTPCookieStoreの中身をすべてHTTPCookieStorageに詰め込む
        // https://qiita.com/ShingoFukuyama/items/c2d33ff3fc36dbdb69a4
/*        let cookieStore: WKHTTPCookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            for cookie: HTTPCookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
*/
        decisionHandler(WKNavigationResponsePolicy.allow)
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
