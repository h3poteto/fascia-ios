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
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

    @IBOutlet private weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuSetup(self)
        bindViewModel()
        guard let signInURL = viewModel.signInURL else {
            return
        }
        let url = NSURL(string: signInURL)
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
        if request.URL?.host == NSURL(string: viewModel.signInURL!)?.host && request.URL?.path == "/webviews/callback" {
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
