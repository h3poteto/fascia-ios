//
//  SignInViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UIWebViewDelegate {

#if DEBUG
    let SIGN_IN_URL = "http://fascia.localdomain:9090/webviews/sign_in"
#else
    let SIGN_IN_URL = "https://fascia.io/webviews/sign_in"
#endif

    @IBOutlet private weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: SIGN_IN_URL)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        // Do any additional setup after loading the view.
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
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.host == NSURL(string: SIGN_IN_URL)?.host && request.URL?.path == "/webviews/callback" {
            FasciaAPIService.sharedInstance.updateSession()
            self.dismissViewControllerAnimated(true, completion: nil)
            return false
        }
        return true
    }

}
