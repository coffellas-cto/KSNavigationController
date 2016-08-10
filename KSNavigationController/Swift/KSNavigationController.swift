//
//  KSNavigationController.swift
//  KSNavigationControllerExampleSwift
//
//  Created by Alex on 8/4/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Cocoa

/*
/**
 @brief Initializes and returns a newly created navigation controller.
 @description This method throws exception if `rootViewController` is nil.
 @param rootViewController The view controller that resides at the bottom of the navigation stack.
 @return The initialized navigation controller object or nil if there was a problem initializing the object.
 */
- (instancetype)initWithRootViewController:(NSViewController<KSNavigationControllerCompatible> *)rootViewController;
/**
 Pushes a view controller onto the receiver’s stack and updates the display. Uses a horizontal slide transition.
 @param viewController The view controller to push onto the stack.
 @param animated Set this value to YES to animate the transition, NO otherwise.
 */
- (void)pushViewController:(NSViewController<KSNavigationControllerCompatible> *)viewController animated:(BOOL)animated;
/**
 Pops the top view controller from the navigation stack and updates the display.
 @param animated Set this value to YES to animate the transition, NO otherwise.
 @return The popped controller.
 */
- (NSViewController<KSNavigationControllerCompatible> *)popViewControllerAnimated:(BOOL)animated;
/**
 Pops until there's only a single view controller left on the stack. Returns the popped view controllers.
 @param animated Set this value to YES to animate the transitions if any, NO otherwise.
 @return The popped view controllers.
 */
- (NSArray<__kindof NSViewController<KSNavigationControllerCompatible> *> *)popToRootViewControllerAnimated:(BOOL)animated;
*/

// MARK: Stack
// TODO: Implement

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
    
    var viewControllers: [NSViewController]? {
        get {
            return nil
        }
    }
    
    var viewControllersCount: UInt {
        get {
            return 0
        }
    }
    
    var topViewController: NSViewController? {
        get {
            return nil
        }
    }
    
    var rootViewController: NSViewController {
        get {
            return self._rootViewController
        }
    }

    private var _rootViewController: NSViewController
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
        self._rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        if var rootViewController = rootViewController as? KSNavigationControllerCompatible {
            rootViewController.navigationController = self
        } else {
            NSException(name: NSInternalInconsistencyException, reason: "`rootViewController` doesn't conform to `KSNavigationControllerCompatible`", userInfo: nil).raise()
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        self._rootViewController = NSViewController()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        dispatch_once(&self._addRootViewOnceToken) {
            self._activeView = self._rootViewController.view
            self.addActiveViewAnimated(false, subtype: nil)
        }
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    func addActiveViewAnimated(animated: Bool, subtype: String?) -> Void {
        if animated {
            self._transition.subtype = subtype
            self.view.animator().addSubview(self._activeView!)
        } else {
            self.view.addSubview(self._activeView!)
        }
    }
}
