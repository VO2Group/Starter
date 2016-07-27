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

    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a WKWebView instance
        webView = WKWebView (frame: self.view.frame, configuration: WKWebViewConfiguration())
        
        // Delegate to handle navigation of web content
        webView!.navigationDelegate = self
        
        view.addSubview(webView!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the HTML document
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")
        let url = NSURL(fileURLWithPath: path!)

        webView!.loadFileURL(url, allowingReadAccessToURL: url.URLByDeletingLastPathComponent!)
        webView!.allowsBackForwardNavigationGestures = true
    }

}
