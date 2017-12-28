//
//  ApplicationController.swift
//  FreshPots
//
//  Created by Nicholas Scheurich on 12/27/17.
//  Copyright © 2017 Nicholas Scheurich. All rights reserved.
//

import UIKit
import WebKit
import Turbolinks

class ApplicationController: UINavigationController {
    
    fileprivate let url = URL(string: "http://localhost:3000")!
    fileprivate let webViewProcessPool = WKProcessPool()
    
    fileprivate var application: UIApplication {
        return UIApplication.shared
    }
    
    fileprivate lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = self.webViewProcessPool
        configuration.userContentController.add(self as WKScriptMessageHandler, name: "freshPots")
        configuration.applicationNameForUserAgent = "Fresh Pots iOS"
        return configuration
    }()
    
    fileprivate lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.barStyle = UIBarStyle.black
        navigationBar.tintColor = UIColor.lightGray
        
        presentVisitableForSession(session, url: url)
    }
    
    fileprivate func presentVisitableForSession(_ session: Session, url: URL, action: Action = .Advance) {
        let visitable = ViewController(url: url)
        let isDashboard = url.relativeString.contains("dashboard")
        let isBrewForm = url.relativeString.contains("brews/new")

        if (isDashboard) {
            visitable.navigationItem.hidesBackButton = true
        }
       
        if (!isBrewForm) {
            createAddButton(viewController: visitable)
        }

        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewController(animated: false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }
    
    fileprivate func createAddButton(viewController: UIViewController) {
        let addButton
            = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(visitNewBrewURL))
        addButton
            .tintColor = UIColor.white
        viewController.navigationItem.rightBarButtonItem = addButton

    }
    
    @objc func visitNewBrewURL() {
        let url = Foundation.URL(string: "http://localhost:3000/brews/new")
        presentVisitableForSession(session, url: url!)
    }
}

extension ApplicationController: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {
        presentVisitableForSession(session, url: URL, action: action)
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let viewController = visitable as? ViewController, let errorCode = ErrorCode(rawValue: error.code) else { return }
        
        switch errorCode {
        case .httpFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 404:
                viewController.presentError(.HTTPNotFoundError)
            default:
                viewController.presentError(Error(HTTPStatusCode: statusCode))
            }
        case .networkFailure:
            viewController.presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = false
    }
}

extension ApplicationController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Fresh Pots", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}
