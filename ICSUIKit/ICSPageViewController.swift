//
//  PageViewControllerFactory.swift
//  Qinghai
//
//  Created by LEI on 5/16/15.
//  Copyright (c) 2015 TouchingApp. All rights reserved.
//

import UIKit

@objc public protocol ICSPageViewControllerDelegate {
    optional func ics_pageViewController(pageViewController: UIPageViewController, willTransitionToPage page: Int)
    optional func ics_pageViewController(pageViewController: UIPageViewController, didTransitionToPage page: Int)
}

public class QHPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private(set) public var currentPage: Int = 0
    public var loopScrolling = false
    private var shouldLoopScrolling: Bool  {
        return loopScrolling && ics_viewControllers.count>1
    }
    public weak var ics_delegate: ICSPageViewControllerDelegate?
    public var ics_viewControllers = [UIViewController]() {
        didSet(old) {
            updateViewControllers()
        }
    }

    public init(viewControllers: [UIViewController], transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        ics_viewControllers = viewControllers
        updateViewControllers()
    }
    
    public init(viewControllers: [UIViewController]) {
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        ics_viewControllers = viewControllers
        updateViewControllers()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    private func updateViewControllers() {
        if ics_viewControllers.count > 0 {
            setViewControllers([ics_viewControllers[0]], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    public func showPage(page: Int, animated: Bool) {
        let direction: UIPageViewControllerNavigationDirection = page > currentPage ? .Forward : .Reverse
        if page == currentPage {
            return
        }
        if !loopScrolling && (page < 0 || page >= ics_viewControllers.count){
            return
        }
        let newPage = normalizedPage(page)
        setViewControllers([ics_viewControllers[newPage]], direction: direction, animated: animated, completion: { [unowned self] finished in
            if finished {
                self.currentPage = newPage
            }
        })
    }
    
    private func normalizedPage(page: Int) -> Int {
        return (page + ics_viewControllers.count) % ics_viewControllers.count
    }
    
    // MARK: - PageViewController DataSource
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let vcIndex = ics_viewControllers.indexOf(viewController) {
            currentPage = vcIndex
            if shouldLoopScrolling {
                return ics_viewControllers[normalizedPage(currentPage+1)]
            }else if currentPage + 1 < ics_viewControllers.count {
                return ics_viewControllers[currentPage + 1]
            }
        }
        return nil
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let vcIndex = ics_viewControllers.indexOf(viewController) {
            currentPage = vcIndex
            if shouldLoopScrolling {
                return ics_viewControllers[normalizedPage(currentPage-1)]
            }else if currentPage - 1 >= 0 {
                return ics_viewControllers[currentPage - 1]
            }
        }
        return nil
    }
    
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.count > 0 {
            if let vcIndex = ics_viewControllers.indexOf(pendingViewControllers[0] ) {
                currentPage = vcIndex
                ics_delegate?.ics_pageViewController?(pageViewController, willTransitionToPage: currentPage)
            }
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            ics_delegate?.ics_pageViewController?(pageViewController, didTransitionToPage: currentPage)
        }
    }
}