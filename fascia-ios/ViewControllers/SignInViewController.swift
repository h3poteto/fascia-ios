//
//  SignInViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UIWebViewDelegate {
    private let viewModel = SignInViewModel()
    private var hud = HUDManager()

#if DEBUG
    let SIGN_IN_URL = "http://fascia.localdomain:9090/webviews/sign_in"
#else
    let SIGN_IN_URL = "https://fascia.io/webviews/sign_in"
#endif

    @IBOutlet private weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        let url = NSURL(string: SIGN_IN_URL)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(webView: UIWebView) {
        viewModel.isLoading.value = true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        viewModel.isLoading.value = false
    }


    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.host == NSURL(string: SIGN_IN_URL)?.host && request.URL?.path == "/webviews/callback" {
            viewModel.update()
            viewModel.isLoading.value = false
            self.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popViewControllerAnimated(true)
            return false
        }
        return true
    }

    private func bindViewModel() {
        hud.bind(viewModel.isLoading.asDriver())
    }
}
