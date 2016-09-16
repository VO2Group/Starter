//
//  ViewController.swift
//  AppShell
//
//  Created by Julien Rouzieres on 03/08/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(ScriptMessageHandler(viewController: self), name: "handler")
        config.userContentController = contentController

        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.webView!.navigationDelegate = NavigationDelegate(viewController: self)
        self.webView!.scrollView.bounces = false
        self.webView!.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView!)

        let platform = URL(fileURLWithPath: Bundle.main.path(forResource: "platform", ofType: "js")!)
        self.webView!.evaluateJavaScript(try! String(contentsOf: platform), completionHandler: nil)

        if let url = Bundle.main.object(forInfoDictionaryKey: "StartURL") as? String {
            self.webView!.load(URLRequest(url: URL(string: url)!))
        }
        else {
            let index = URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "www")!)
            self.webView!.loadFileURL(index, allowingReadAccessTo: index.deletingLastPathComponent())
        }

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onPause), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onResume), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func onPause(_ notification: Notification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('pause'));", completionHandler: nil)
    }

    func onResume(_ notification: Notification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('resume'));", completionHandler: nil)
    }

}
