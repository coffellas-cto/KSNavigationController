//
//  TestViewController.m
//
//  Created by Alex Gordiyenko on 8/1/16.
//  Copyright © 2016 Alex Gordiyenko. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@property (weak) IBOutlet NSTextField *textField;

@end

@implementation TestViewController

@synthesize navigationController = _navigationController;

- (IBAction)pushaction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
}
- (IBAction)popaction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.stringValue = [@(self.navigationController.viewControllersCount) stringValue];
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor colorWithRed:arc4random_uniform(63) / 63.0 + 0.5 green:arc4random_uniform(63) / 63.0 + 0.5 blue:arc4random_uniform(63) / 63.0 + 0.5 alpha:1].CGColor;
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
