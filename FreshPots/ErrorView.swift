//
//  ErrorView.swift
//  FreshPots
//
//  Created by Nicholas Scheurich on 12/27/17.
//  Copyright © 2017 Nicholas Scheurich. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var error: Error? {
        didSet {
            titleLabel.text = error?.title
            messageLabel.text = error?.message
        }
    }
}
