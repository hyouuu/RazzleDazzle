//
//  AnimatedPagingScrollViewController.swift
//  RazzleDazzle
//
//  Created by Laura Skelton on 6/16/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

import UIKit

/**
View controller for creating scrolling app intros. Set animation times based on the page number, and this view controller handles calling `animate:` on the `animator`.
*/
public class AnimatedPagingScrollViewController : UIViewController, UIScrollViewDelegate {
    public let scrollView = UIScrollView()
    public let contentView = UIView()
    public var animator = Animator()
    private var scrollViewPageConstraintAnimations = [ScrollViewPageConstraintAnimation]()
    public var pageWidth : CGFloat {
        get {
            return scrollView.frame.width
        }
    }
    public var pageOffset : CGFloat {
        get {
            var currentOffset = scrollView.contentOffset.x
            if pageWidth > 0 {
                currentOffset = currentOffset / pageWidth
            }
            return currentOffset
        }
    }
    
    public func numberOfPages() -> Int {
        return 2
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: CGFloat(numberOfPages()) * view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
      
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView" : scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView" : scrollView]))
      
        let scrollViewLeft = NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0)
        let scrollViewRight = NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0)
        let scrollViewTop = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let scrollViewBottom = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
      
        NSLayoutConstraint.activate([scrollViewLeft, scrollViewRight, scrollViewTop, scrollViewBottom])
      
        let contentViewWidth = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: CGFloat(numberOfPages()), constant: 0)
        let contentViewHeight = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
      
        NSLayoutConstraint.activate([contentViewWidth, contentViewHeight])
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCurrentFrame()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        let newPageWidth = size.width
        for animation in scrollViewPageConstraintAnimations {
            animation.pageWidth = newPageWidth
        }
        let futurePixelOffset = pageOffset * newPageWidth
        coordinator.animate(alongsideTransition: {context in
            self.animateCurrentFrame()
            self.scrollView.contentOffset.x = futurePixelOffset
            }, completion: nil)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        animateCurrentFrame()
    }
    
    public func animateCurrentFrame () {
        animator.animate(time: pageOffset)
    }
    
    public func keepView(view: UIView, onPage page: CGFloat) {
        keepView(view: view, onPage: page, withAttribute: .CenterX)
    }
    
    public func keepView(view: UIView, onPage page: CGFloat, withAttribute attribute: HorizontalPositionAttribute) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: view, attribute: layoutAttributeFromRazAttribute(razAttribute: attribute), relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: multiplierForPage(page: page, attribute: attribute), constant: 0).isActive = true
    }
    
    public func keepView(view: UIView, onPages pages: [CGFloat]) {
        keepView(view: view, onPages: pages, atTimes: pages)
    }
    
    public func keepView(view: UIView, onPages pages: [CGFloat], withAttribute attribute: HorizontalPositionAttribute) {
        keepView(view: view, onPages: pages, atTimes: pages, withAttribute: attribute)
    }

    public func keepView(view: UIView, onPages pages: [CGFloat], atTimes times: [CGFloat]) {
        keepView(view: view, onPages: pages, atTimes: times, withAttribute: .CenterX)
    }
    
    public func keepView(view: UIView, onPages pages: [CGFloat], atTimes times: [CGFloat], withAttribute attribute: HorizontalPositionAttribute) {
        assert(pages.count == times.count, "Make sure you set a time for each position.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let xPositionConstraint = NSLayoutConstraint(item: view, attribute: layoutAttributeFromRazAttribute(razAttribute: attribute), relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0)
        xPositionConstraint.isActive = true
        let xPositionAnimation = ScrollViewPageConstraintAnimation(superview: contentView, constraint: xPositionConstraint, pageWidth: pageWidth, attribute: attribute)
        for (index, page) in pages.enumerated() {
            xPositionAnimation[times[index]] = page
        }
        animator.addAnimation(animation: xPositionAnimation)
        scrollViewPageConstraintAnimations.append(xPositionAnimation)
    }
    
    public func centerXMultiplierForPage(page: CGFloat) -> CGFloat {
        return multiplierForPage(page: page, attribute: .CenterX)
    }
    
    public func leftMultiplierForPage(page: CGFloat) -> CGFloat {
        return multiplierForPage(page: page, attribute: .Left)
    }
    
    public func rightMultiplierForPage(page: CGFloat) -> CGFloat {
        return multiplierForPage(page: page, attribute: .Right)
    }
    
    public func multiplierForPage(page: CGFloat, attribute: HorizontalPositionAttribute) -> CGFloat {
        var offset : CGFloat
        switch attribute {
        case .CenterX:
            offset = 0.5
        case .Left:
            offset = 0
        case .Right:
            offset = 1
        }
        return 2.0 * (offset + page) / CGFloat(numberOfPages())
    }
    
    public func layoutAttributeFromRazAttribute(razAttribute: HorizontalPositionAttribute) -> NSLayoutAttribute {
        var attribute : NSLayoutAttribute
        switch razAttribute {
        case .CenterX:
            attribute = .centerX
        case .Left:
            attribute = .left
        case .Right:
            attribute = .right
        }
        return attribute
    }
}

