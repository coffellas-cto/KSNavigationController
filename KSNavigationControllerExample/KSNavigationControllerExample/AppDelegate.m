//
//  AppDelegate.m
//  KSNavigationControllerExample
//
//  Created by Alex Gordiyenko on 8/2/16.
//  Copyright © 2016 Alex Gordiyenko. All rights reserved.
//

#import "AppDelegate.h"
#import "KSNavigationController.h"
#import "TestViewController.h"

@interface AppDelegate ()
@property NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window = [[NSWindow alloc] init];
    [self.window center];
    
    TestViewController *vc1 = [[TestViewController alloc] init];
    KSNavigationController *navVC = [[KSNavigationController alloc] initWithRootViewController:vc1];
    navVC.view.frame = NSMakeRect(0.0, 0.0, 480.0, 272.0);
    self.window.contentViewController = navVC;
    [self.window orderFrontRegardless];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
