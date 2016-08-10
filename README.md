# KSNavigationController
UINavigationController for macOS (Objective-C)

![ksnavigationcontrollerdemo](https://cloud.githubusercontent.com/assets/3193877/17337372/04002c08-58eb-11e6-9c1f-2cabdea4dd66.gif)

Looking for macOS (Mac OS X) analog of UIKit's `UINavigationController` from iOS? This class mimics its behavior.

**Attention**: Navigation bar is not implemented. All methods must be called from main thread.

## Usage
### Creating a navigation controller
```objc
TestViewController *vc1 = [[TestViewController alloc] init];
KSNavigationController *navVC = [[KSNavigationController alloc] initWithRootViewController:vc1];
navVC.view.frame = NSMakeRect(0.0, 0.0, 480.0, 272.0); // Or use constraints if appropriate
self.window.contentViewController = navVC;
[self.window orderFrontRegardless];
```
Here your `TestViewController` class is a subclass of `NSViewController`. It also has to conform to `KSNavigationControllerCompatible` protocol in order to have access to `navigationController` property.
### Pushing and popping view controllers onto / from stack
Now, inside your `NSViewController` you can access `navigationController` property (just like in iOS) and push any new view controller on top of navigation stack:
```objc
- (IBAction)pushaction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
}
```

Do the following to pop the top controller from stack:
```objc
- (IBAction)popaction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
```

## KSNavigationControllerCompatible protocol
Conform to this protocol if you want your `NSViewController` subclass to work with `KSNavigationController`.

This protocol has only one property:

```objc
@property (weak, nonatomic) KSNavigationController *navigationController;
```

**Warning:** Do not set this properly by yourself.
You must synthesize `navigationController` property explicitly in your subclass implementation:
```objc
@synthesize navigationController = _navigationController;
```

See example project for more understanding.
