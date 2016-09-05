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
        contentController.addScriptMessageHandler(ScriptMessageHandler(viewController: self), name: "handler")
        config.userContentController = contentController

        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.webView!.navigationDelegate = NavigationDelegate(viewController: self)
        self.webView!.scrollView.bounces = false
        self.webView!.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView!)

        let platform = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("platform", ofType: "js")!)
        self.webView!.evaluateJavaScript(try! String(contentsOfURL: platform), completionHandler: nil)

        if let url = NSBundle.mainBundle().objectForInfoDictionaryKey("StartURL") as? String {
            self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        }
        else {
            let index = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!)
            self.webView!.loadFileURL(index, allowingReadAccessToURL: index.URLByDeletingLastPathComponent!)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPause), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onResume), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func onPause(notification: NSNotification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('pause'));", completionHandler: nil)
    }

    func onResume(notification: NSNotification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('resume'));", completionHandler: nil)
    }

}
