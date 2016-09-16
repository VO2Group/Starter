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

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "handler" {
            let body = message.body as! NSDictionary
            switch body["method"] as! String {
            case "foo":
                self.foo(body["message"] as! String)
                break
            case "bar":
                self.bar(body["message"] as! String, callback: body["callback"] as! String)
                break
            default:
                break
            }
        }
    }

    func foo(_ message: String) {
        let alert = UIAlertController(title: "Foo", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }

    func bar(_ message: String, callback: String) {
        let alert = UIAlertController(title: "Bar", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.viewController.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, true);", completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.viewController.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, false);", completionHandler: nil)
        }))
        self.viewController.present(alert, animated: true, completion: nil)
    }

}
