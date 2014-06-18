//
//  CYPageViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/18/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "CYPageViewController.h"

@interface CYPageViewController () <UIPageViewControllerDelegate>

@property (nonatomic, strong) id<UIPageViewControllerDelegate> thisDelegate;

@end

@implementation CYPageViewController

- (void)setDelegate:(id<UIPageViewControllerDelegate>)delegate {
    _thisDelegate = delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
