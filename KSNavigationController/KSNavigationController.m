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

#import "KSNavigationController.h"
#import <Quartz/Quartz.h>

#pragma mark - Stack

@interface _KSStackItem : NSObject {
@public
    id _value;
    _KSStackItem *_next;
}
@end

@implementation _KSStackItem
@end

/** Not thread-safe */
@interface _KSStack : NSObject {
    _KSStackItem *_head;
}
- (void)push:(id)object;
- (id)pop;
- (void)iterateWithBlock:(void(^)(id object))block;

@property (nonatomic, readonly) id headValue;
@property (nonatomic, readonly) NSUInteger count;

@end

@implementation _KSStack

- (void)push:(id)object {
    _KSStackItem *item = [_KSStackItem new];
    item->_value = object;
    item->_next = _head;
    _head = item;
    ++_count;
}

- (id)pop {
    if (_head == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Popped an empty stack"];
        return nil;
    }
    
    id retVal = _head->_value;
    _head = _head->_next;
    --_count;
    return retVal;
}

- (id)headValue {
    return _head ? _head->_value : nil;
}

- (void)iterateWithBlock:(void(^)(id object))block {
    if (!block) {
        return;
    }
    
    _KSStackItem *item = _head;
    while (item) {
        block(item->_value);
        item = item->_next;
    }
}

@end


#pragma mark - KSNavigationController

@interface KSNavigationController () {
    _KSStack *_stack;
    NSViewController<KSNavigationControllerCompatible> *_rootViewController;
    NSView *_activeView;
    dispatch_once_t _addRootViewOnceToken;
}

@property (nonatomic, readonly) CATransition *transition;

@end

@implementation KSNavigationController

@synthesize transition = _transition;

#pragma mark - Life Cycle

- (instancetype)initWithRootViewController:(NSViewController<KSNavigationControllerCompatible> *)rootViewController {
    if (!rootViewController) {
        [NSException raise:NSInternalInconsistencyException format:@"`rootViewController` can't be nil"];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _rootViewController = rootViewController;
        _rootViewController.navigationController = self;
        _stack = [_KSStack new];
    }
    return self;
}

- (void)loadView {
    self.view = [NSView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    dispatch_once(&_addRootViewOnceToken, ^{
        if (_rootViewController) {
            _activeView = _rootViewController.view;
            [self addActiveViewAnimated:NO subtype:nil];
        }
    });
}

#pragma mark - Accessors

- (CATransition *)transition {
    if (!_transition) {
        _transition = [CATransition animation];
        _transition.type = kCATransitionPush;
        self.view.animations = @{@"subviews": _transition};
    }
    
    return _transition;
}

- (NSUInteger)viewControllersCount {
    return _stack.count + 1;
}

- (NSViewController *)topViewController {
    if (_stack.count) {
        return _stack.headValue;
    }
    
    return _rootViewController;
}

- (NSViewController<KSNavigationControllerCompatible> *)rootViewController {
    return _rootViewController;
}

#pragma mark - Public Methods

- (void)pushViewController:(NSViewController<KSNavigationControllerCompatible> *)viewController animated:(BOOL)animated {
    [_activeView removeFromSuperview];
    [_stack push:viewController];
    viewController.navigationController = self;
    _activeView = viewController.view;
    [self addActiveViewAnimated:animated subtype:kCATransitionFromRight];
}

- (NSViewController<KSNavigationControllerCompatible> *)popViewControllerAnimated:(BOOL)animated {
    if (_stack.count == 0) {
        return nil;
    }
    
    [_activeView removeFromSuperview];
    NSViewController<KSNavigationControllerCompatible> *retVal = [_stack pop];
    _activeView = [_stack.headValue view];
    if (!_activeView) {
        _activeView = _rootViewController.view;
    }
    
    [self addActiveViewAnimated:animated subtype:kCATransitionFromLeft];
    return retVal;
}

- (NSArray<NSViewController<KSNavigationControllerCompatible> *> *)viewControllers {
    if (!_rootViewController) {
        return nil;
    }
    
    NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:_stack.count + 1];
    [_stack iterateWithBlock:^(id object) {
        [retVal addObject:object];
    }];
    [retVal addObject:_rootViewController];

    return [retVal copy];
}

- (NSArray<NSViewController<KSNavigationControllerCompatible> *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (_stack.count == 0) {
        return nil;
    }
    
    NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:_stack.count];
    for (NSUInteger i = 0; i < _stack.count; i++) {
        [retVal addObject:[self popViewControllerAnimated:animated]];
    }
    
    return [retVal copy];
}

#pragma mark - Private Methods

- (void)addActiveViewAnimated:(BOOL)animated subtype:(NSString *)subtype {
    if (animated) {
        self.transition.subtype = subtype;
        [self.view.animator addSubview:_activeView];
    } else {
        [self.view addSubview:_activeView];
    }
}

@end
