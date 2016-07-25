//
//  ViewController.swift
//  Starter
//
//  Created by Julien Rouzieres on 23/07/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "web")
        let url = NSURL(fileURLWithPath: path!)
        webView.loadFileURL(url, allowingReadAccessToURL: url.URLByDeletingLastPathComponent!)
        webView.allowsBackForwardNavigationGestures = true
    }

}
