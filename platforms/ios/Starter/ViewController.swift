//
//  ViewController.swift
//  Starter
//
//  Created by Julien Rouzieres on 23/07/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        contentController.addScriptMessageHandler(self, name: "handler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        self.webView = WKWebView (frame: self.view.frame, configuration: config)
        self.webView!.navigationDelegate = self
        self.webView!.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView!)

        let starter = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("starter", ofType: "js")!)
        self.webView!.evaluateJavaScript(try! String(contentsOfURL: starter), completionHandler: nil)

        let www = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!)
        self.webView!.loadFileURL(www, allowingReadAccessToURL: www.URLByDeletingLastPathComponent!)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == "handler" {
            switch message.body["method"] as! String {
            case "alert":
                self.alert(message.body["message"] as! String)
                break
            case "yesOrNo":
                self.yesOrNo(message.body["message"] as! String, resolve: message.body["resolve"] as! Int, reject: message.body["reject"] as! Int)
                break
            default:
                break
            }
        }
    }

    func alert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func yesOrNo(message: String, resolve: Int, reject: Int) {
        let alert = UIAlertController(title: "Question", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.webView!.evaluateJavaScript("window.starter._invoke(" + String(resolve) + ", true);", completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.webView!.evaluateJavaScript("window.starter._invoke(" + String(resolve) + ", false);", completionHandler: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
