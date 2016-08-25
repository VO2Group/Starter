//
//  ScriptMessageHandler.swift
//  AppShell
//
//  Created by Julien Rouzieres on 26/08/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import UIKit
import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {

    let viewController: ViewController

    init(viewController: ViewController) {
        self.viewController = viewController
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == "handler" {
            switch message.body["method"] as! String {
            case "foo":
                self.foo(message.body["message"] as! String)
                break
            case "bar":
                self.bar(message.body["message"] as! String, callback: message.body["callback"] as! String)
                break
            default:
                break
            }
        }
    }

    func foo(message: String) {
        let alert = UIAlertController(title: "Foo", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.viewController.presentViewController(alert, animated: true, completion: nil)
    }

    func bar(message: String, callback: String) {
        let alert = UIAlertController(title: "Bar", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.viewController.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, true);", completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.viewController.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, false);", completionHandler: nil)
        }))
        self.viewController.presentViewController(alert, animated: true, completion: nil)
    }

}
