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
    fileprivate let viewModel = SignInViewModel()
    fileprivate var hud = HUDManager()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)

    @IBOutlet fileprivate weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuSetup(self)
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
        if request.url?.host == URL(string: viewModel.signInURL!)?.host && request.url?.path == "/webviews/callback" {
            viewModel.update()
            viewModel.isLoading.value = false
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return false
        }
        return true
    }

    fileprivate func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading.asDriver())
    }

}
