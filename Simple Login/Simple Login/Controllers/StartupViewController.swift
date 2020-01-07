//
//  StartupViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 07/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Cocoa
import Alamofire

final class StartupViewController: NSViewController {
    @IBOutlet private weak var messageLabel: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var retryButton: NSButton!
    
    private var apiKey: String?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Retrieve API key from user defaults
        // API key exists -> verify it
        // API not exist -> open EnterApiKeyWindowController
        if let apiKey = SLUserDefaultsService.getApiKey() {
            self.apiKey = apiKey
            checkApiKeyAndProceed()
        } else {
            openEnterApiKeyWindowController()
        }
    }
    
    @IBAction private func retryButtonClicked(_ sender: Any) {
        checkApiKeyAndProceed()
    }
    
    private func checkApiKeyAndProceed() {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        messageLabel.stringValue = "Connecting to server..."
        retryButton.isHidden = true
        
        SLApiService.fetchUserInfo(apiKey!, completion: { [weak self] (userInfo, error) in
            guard let self = self else { return }
            
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(nil)
            
            if let error = error {
                self.messageLabel.stringValue = "Error occured: \(error.description)"
                self.retryButton.isHidden = false
            } else if let userInfo = userInfo {
                self.openInstructionViewController(with: userInfo)
            }
        })
    }
    
    private func openEnterApiKeyWindowController() {
        let storyboardName = NSStoryboard.Name(stringLiteral: "EnterApiKey")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let storyboardID = NSStoryboard.SceneIdentifier(stringLiteral: "EnterApiKeyWindowControllerID")
        
        if let enterApiKeyWindowController = storyboard.instantiateController(withIdentifier: storyboardID) as? NSWindowController {
            enterApiKeyWindowController.showWindow(nil)
            view.window?.performClose(nil)
        }
    }
    
    private func openInstructionViewController(with userInfo: UserInfo) {
        let storyboardName = NSStoryboard.Name(stringLiteral: "Instruction")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let storyboardID = NSStoryboard.SceneIdentifier(stringLiteral: "InstructionWindowControllerID")
        
        if let instructionWindowController = storyboard.instantiateController(withIdentifier: storyboardID) as? NSWindowController {
            
            if let instructionViewController = instructionWindowController.contentViewController as? InstructionViewController {
                instructionViewController.userInfo = userInfo
            }
            
            instructionWindowController.showWindow(nil)
            view.window?.performClose(nil)
        }
    }
}
