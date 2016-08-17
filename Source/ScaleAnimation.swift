//
//  ScaleAnimation.swift
//  RazzleDazzle
//
//  Created by Laura Skelton on 6/13/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

import UIKit

/**
Animates the scale of the `transform` of a `UIView`.
*/
public class ScaleAnimation : Animation<CGFloat>, Animatable {
    private let view : UIView
    
    public init(view: UIView) {
        self.view = view
    }
    
    public func animate(time: CGFloat) {
        if !hasKeyframes() {return}
        let scale = self[time]
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        view.scaleTransform = scaleTransform
        var newTransform = scaleTransform
        if let rotationTransform = view.rotationTransform {
            newTransform = newTransform.concatenating(rotationTransform)
        }
        if let translationTransform = view.translationTransform {
            newTransform = newTransform.concatenating(translationTransform)
        }
        view.transform = newTransform
    }
    
    public override func validateValue(value: CGFloat) -> Bool {
        return (value >= 0)
    }
}
