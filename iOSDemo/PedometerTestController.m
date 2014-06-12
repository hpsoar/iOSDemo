//
//  ViewController2.m
//  Test
//
//  Created by HuangPeng on 14-5-7.
//  Copyright (c) 2014年 HuangPeng. All rights reserved.
//

#import "PedometerTestController.h"
#import "GradientViewController.h"

@interface PedometerTestController ()

@property (nonatomic, strong) UIPageViewController *pageController;

@property (nonatomic, strong) NSMutableArray *controllers;

@end

@implementation PedometerTestController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}

- (NSString *)getDocumentPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    // load latest acceleration data
    
    // feed into Pedometer
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
