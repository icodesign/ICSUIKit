//
//  ICSParallaxScrollView.swift
//  ICSParallaxScrollView
//
//  Created by LEI on 6/13/15.
//  Copyright © 2015 TouchingApp. All rights reserved.
//

import UIKit

private let DefaultParallaxHeaderHeight: Float = 100

extension UIScrollView {
    
    private struct StaticKeys {
        static var ParallaxHeaderView = "ParallaxHeaderView"
        static var ParallaxHeaderHeight = "ParallaxHeaderHeight"
        static var ParallaxHeaderStickToTop = "ParallaxHeaderStickToTop"
        static var ContentOffset = "contentOffset"
    }
    
    private(set) public var parallaxHeader: UIView? {
        get {
            return objc_getAssociatedObject(self, &StaticKeys.ParallaxHeaderView) as? UIView
        }
        set {
            if let v = newValue {
                objc_setAssociatedObject(self, &StaticKeys.ParallaxHeaderView, v, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var parallaxHeaderHeight: Float {
        get {
            return objc_getAssociatedObject(self, &StaticKeys.ParallaxHeaderHeight) as? Float ?? DefaultParallaxHeaderHeight
        }
        set {
            objc_setAssociatedObject(self, &StaticKeys.ParallaxHeaderHeight, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            var originContentInset = self.contentInset
            originContentInset.top = CGFloat(parallaxHeaderHeight)
            self.contentInset = originContentInset
        }
    }
    
    public var parallaxHeaderStickToTop: Bool {
        get {
            return objc_getAssociatedObject(self, &StaticKeys.ParallaxHeaderStickToTop) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &StaticKeys.ParallaxHeaderStickToTop, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addParallaxHeader(headerView: UIView, height: Float) {
        parallaxHeader?.removeFromSuperview()
        parallaxHeader = headerView
        parallaxHeader?.backgroundColor = UIColor.blackColor()
        insertSubview(parallaxHeader!, atIndex: 0)
        parallaxHeaderHeight = height
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let _ = newSuperview {
            addObserver(self, forKeyPath: StaticKeys.ContentOffset, options: NSKeyValueObservingOptions.New, context: nil)
        }else{
            removeObserver(self, forKeyPath: StaticKeys.ContentOffset)
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == StaticKeys.ContentOffset, let contentOffset = change?[NSKeyValueChangeNewKey]?.CGPointValue {
            // update scrollIndicatorInsets to make it more nature
            if contentOffset.y < contentInset.top {
                scrollIndicatorInsets = UIEdgeInsetsMake(-contentOffset.y, 0, 0, 0)
            }
            // update headerview frame
            if let view = parallaxHeader {
                let height = (contentOffset.y < -contentInset.top || !parallaxHeaderStickToTop) ? -contentOffset.y : CGFloat(parallaxHeaderHeight)
                view.frame = CGRect(x: 0, y: contentOffset.y, width: self.bounds.width, height: height)
            }
        }
    }
    
}
