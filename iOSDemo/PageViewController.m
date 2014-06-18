//
//  PageViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/17/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "PageViewController.h"

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

@end

CGFloat R() {
    return (CGFloat)rand() / INT_MAX;
}

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, TestDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, strong) UIViewController *targetController;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic) CGFloat previousOffset;

@property (nonatomic) NSInteger pageOffset;
@property (nonatomic) BOOL pageSwitched;

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

- (void)setCurrentViewController:(UIViewController *)currentViewController {
    _currentViewController = currentViewController;
    self.title = [NSString stringWithFormat:@"page %d", currentViewController.view.tag];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

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
        controller.delegate = self;
        [self.controllers addObject:controller];
    }
    
    [self.pageController setViewControllers:@[self.controllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    for (UIView *v in self.pageController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)v).delegate = self;
        }
    }
    self.currentViewController = self.pageController.viewControllers.firstObject;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController.view.tag == 4) return nil;
    return self.controllers[viewController.view.tag + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController.view.tag == 0) return nil;
    return self.controllers[viewController.view.tag - 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        UIViewController *v1 = pageViewController.viewControllers.firstObject;
        UIViewController *v2 = previousViewControllers.firstObject;
        //NSLog(@"tag2: %d, %d", v1.view.tag, v2.view.tag);
//        if (abs(v1.view.tag - v2.view.tag) > 1) {
//            if (v1.view.tag < v2.view.tag) {
//                [pageViewController setViewControllers:@[v2] direction:UIPageViewControllerNavigationDirectionForward animated:NO  completion:nil];
//            }
//            else {
//                [pageViewController setViewControllers:@[v2] direction:UIPageViewControllerNavigationDirectionReverse animated:NO  completion:nil];
//                
//            }
//        }
        
    }
    [self switchPage:@"trans"];
    NSLog(@"here: tag: %d", [self.pageController.viewControllers.firstObject view].tag);
    self.currentViewController = self.pageController.viewControllers.firstObject;
    self.pageOffset = 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSLog(@"will trans");
}

- (void)controllerBecomesTarge:(UIViewController *)controller {
    self.targetController = controller;
    NSLog(@"target tag: %d", controller.view.tag);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.x);
    if (scrollView.contentOffset.x < 420) {
        if (self.previousOffset > 600) {
            // new right page
            self.pageOffset++;
        }
    }
    if (scrollView.contentOffset.x > 220) {
        if (self.previousOffset < 100) {
            // new left page
            self.pageOffset--;
        }
    }
    self.previousOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self switchPage:@"dragging"];
    self.pageSwitched = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self switchPage:@"dragging"];
        self.pageSwitched = NO;
    }
}

- (void)switchPage:(NSString*)log {
    NSLog(@"%@", log);
    NSLog(@"page offset: %d", self.pageOffset);
    if (!self.pageSwitched) {
        self.pageSwitched = YES;
        NSLog(@"finished by %@", log);
        if (self.pageOffset != 0 && self.pageController.viewControllers.firstObject == self.currentViewController) {
            UIPageViewControllerNavigationDirection dir = self.currentViewController.view.tag < self.targetController.view.tag ?
            UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
            __weak PageViewController *weakSelf = self;
            [self.pageController setViewControllers:@[self.targetController] direction:dir animated:NO completion:^(BOOL finished) {
                 NSLog(@"tag: %d, %d", [weakSelf.pageController.viewControllers.firstObject view].tag, weakSelf.targetController.view.tag);
            }];
        }
    }
    self.currentViewController = self.pageController.viewControllers.firstObject;
    self.pageOffset = 0;
        NSLog(@"tag: %d, %d", [self.pageController.viewControllers.firstObject view].tag, self.targetController.view.tag);
}

@end
