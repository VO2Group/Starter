//
//  NavigationDelegate.swift
//  AppShell
//
//  Created by Julien Rouzieres on 26/08/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import WebKit

class NavigationDelegate: NSObject, WKNavigationDelegate {

    let viewController: ViewController

    init(viewController: ViewController) {
        self.viewController = viewController
    }

}
