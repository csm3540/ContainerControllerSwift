//
//  ContainerView.swift
//  PatternsSwift
//
//  Created by mrustaa on 21/04/2020.
//  Copyright © 2020 mrustaa. All rights reserved.
//

import UIKit

class ContainerView: UIView {
    
    var contentView: UIView?
    
    var visualEffectView: UIVisualEffectView?
    
    // MARK: CornerRadius
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            let r = radius()
            layer.cornerRadius = r
            contentView?.layer.cornerRadius = r
            contentView?.clipsToBounds = true
            visualEffectView?.layer.cornerRadius = r
        }
    }
    
    func radius() -> CGFloat {
        let minSize = min(frame.width, frame.height)
        let radius = (((minSize / 2) < cornerRadius) ? (minSize / 2) : cornerRadius)
        return radius
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin]
        addSubview(contentView)
        self.contentView = contentView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Add Custom Shadow
    
    func addShadow(opacity: CGFloat = 0.1) {
        layer.shadowOpacity = Float(opacity)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
    }
    
    // MARK: Add Blur
    
    func addBlur(darkStyle: Bool) {
        let style: UIBlurEffect.Style = darkStyle ? .systemThinMaterialDark : .systemChromeMaterialLight
        backgroundColor = .clear
        addBlur(style: style)
    }

    func addBlur(style: UIBlurEffect.Style) {
        
        if visualEffectView == nil {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            self.insertSubview(blurView, at: 0)
            visualEffectView = blurView
        }
        
        guard let visualEffectView = visualEffectView else { return }
        visualEffectView.effect = UIBlurEffect(style: style)
        visualEffectView.bounds = bounds
        visualEffectView.frame = CGRect(x: 0, y: 0, width: visualEffectView.frame.width, height: visualEffectView.frame.height)
        visualEffectView.layer.cornerRadius = radius()
        visualEffectView.layer.masksToBounds = true
        visualEffectView.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin]
        
    }
    
    // MARK: Remove Blur
    
    func removeBlur() {
        if let visualEffectView = visualEffectView {
            visualEffectView.removeFromSuperview()
        }
        visualEffectView = nil
    }
    
}
