//
//  PageViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/17/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "PageViewController.h"
#import "CYPageViewController.h"

@protocol TestDelegate <NSObject>

- (void)controllerBecomesTarge:(UIViewController *)controller;

@end

@interface MyViewController : UIViewController

@property (nonatomic, weak) id<TestDelegate> delegate;

@end

@implementation MyViewController {
    UILabel *_label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 100, 40)];
    [self.view addSubview:_label];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _label.text = [NSString stringWithFormat:@"page %d", self.view.tag];
    NSLog(@"%d appeared\n", self.view.tag);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        NSLog(@"%d will appeared\n", self.view.tag);
    [self.delegate controllerBecomesTarge:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    NSLog(@"didMoveToParentViewController");
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    NSLog(@"willMoveToParentViewController");
}

@end

CGFloat R() {
    return (CGFloat)rand() / INT_MAX;
}

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CYPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *controllers;

@end

@implementation PageViewController

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

    self.pageController = [[CYPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.view.frame = CGRectMake(0, 64, 320, 500);
    self.pageController.view.backgroundColor = [UIColor redColor];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    [self.view addSubview:self.pageController.view];
    
    self.controllers = [NSMutableArray new];
    for (int i = 0; i < 5; ++i) {
        MyViewController *controller = [MyViewController new];
        controller.view.tag = i;
        controller.view.backgroundColor = [UIColor colorWithRed:R() green:R() blue:R() alpha:1.0];
        [self.controllers addObject:controller];
    }
    
    self.pageController.currentViewController = self.controllers[0];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController.view.tag == 4) {
        return nil;
    }
    else {
        return self.controllers[viewController.view.tag + 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController.view.tag == 0) {
        return nil;
    }
    else {
        return self.controllers[viewController.view.tag - 1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.title = [NSString stringWithFormat:@"page %d", self.pageController.currentViewController.view.tag];
}
@end
