//
//  KSNavigationController.m
//
//  Copyright © 2016 Alex Gordiyenko. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016 A. Gordiyenko
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Cocoa

// MARK: Stack

class _KSStackItem<T> : NSObject {
    var value: T
    var next: _KSStackItem<T>?
    init(_ value: T) {
        self.value = value
    }
}

class _KSStack<T>: NSObject {
    private var _head: _KSStackItem<T>?
    private var _count: UInt = 0
    var headValue: T? {
        get {
            return self._head?.value
        }
    }
    var count: UInt {
        get {
            return self._count
        }
    }
    
    func push(object: T) -> Void {
        let item = _KSStackItem(object)
        item.next = self._head
        self._head = item
        self._count += 1
    }
    
    func pop() -> T? {
        guard self._head != nil else {
            NSException(name: NSInternalInconsistencyException, reason: "Popped an empty stack", userInfo: nil).raise()
            return nil
        }
        
        let retVal = self._head?.value
        self._head = self._head?.next
        self._count -= 1
        return retVal
    }
    
    func iterate(block: (T) -> (Void)) -> Void {
        var item = self._head
        while true {
            if let item = item {
                block(item.value)
            } else {
                break
            }
            
            item = item?.next
        }
    }

}

// MARK: KSNavigationControllerCompatible

protocol KSNavigationControllerCompatible {
    weak var navigationController: KSNavigationController? {get set}
}

// MARK: KSNavigationController

class KSNavigationController: NSViewController {
    // MARK: Properties
    
    private(set) var rootViewController: NSViewController
    
    var viewControllers: [NSViewController] {
        get {
            var retVal = [NSViewController]()
            self._stack.iterate { (object: NSViewController) -> (Void) in
                retVal.append(object)
            }
            
            retVal.append(self.rootViewController)
            return retVal
        }
    }
    
    var viewControllersCount: UInt {
        get {
            return self._stack.count + 1
        }
    }
    
    var topViewController: NSViewController? {
        get {
            if self._stack.count > 0 {
                return self._stack.headValue;
            }
            
            return self.rootViewController;
        }
    }

    private var _activeView: NSView?
    private var _addRootViewOnceToken: dispatch_once_t = 0
    private var _stack: _KSStack<NSViewController> = _KSStack<NSViewController>()
    private var _transition: CATransition {
        get {
            let transition = CATransition()
            transition.type = kCATransitionPush
            self.view.animations = ["subviews": transition]
            return transition
        }
    }
    
    // MARK: Life Cycle
    
    init?(rootViewController: NSViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        if var rootViewController = rootViewController as? KSNavigationControllerCompatible {
            rootViewController.navigationController = self
        } else {
            NSException(name: NSInternalInconsistencyException, reason: "`rootViewController` doesn't conform to `KSNavigationControllerCompatible`", userInfo: nil).raise()
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        self.rootViewController = NSViewController()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        dispatch_once(&self._addRootViewOnceToken) {
            self._activeView = self.rootViewController.view
            self.addActiveViewAnimated(false, subtype: nil)
        }
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    // MARK: Public Methods
    
    func pushViewController(viewController: NSViewController, animated: Bool) {
        self._activeView?.removeFromSuperview()
        self._stack.push(viewController)
        if var viewControllerWithNav = viewController as? KSNavigationControllerCompatible {
            viewControllerWithNav.navigationController = self
        }
        
        self._activeView = viewController.view
        self.addActiveViewAnimated(animated, subtype: kCATransitionFromRight)
    }
    
    func popViewControllerAnimated(animated: Bool) -> NSViewController? {
        if self._stack.count == 0 {
            return nil
        }
        
        self._activeView?.removeFromSuperview()
        let retVal = self._stack.pop()
        self._activeView = self._stack.headValue?.view
        if self._activeView == nil {
            self._activeView = self.rootViewController.view
        }
        
        self.addActiveViewAnimated(animated, subtype: kCATransitionFromLeft)
        return retVal
    }
    
    func popToRootViewControllerAnimated(animated: Bool) -> [NSViewController]? {
        if self._stack.count == 0 {
            return nil;
        }
        
        var retVal = [NSViewController]()
        for _ in 1...self._stack.count {
            if let vc = self.popViewControllerAnimated(animated) {
                retVal.append(vc)
            }
        }
        
        return retVal
    }
    
    // MARK: Private Methods
    
    func addActiveViewAnimated(animated: Bool, subtype: String?) {
        if animated {
            self._transition.subtype = subtype
            self.view.animator().addSubview(self._activeView!)
        } else {
            self.view.addSubview(self._activeView!)
        }
    }
}
