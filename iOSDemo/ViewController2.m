//
//  ViewController2.m
//  Test
//
//  Created by HuangPeng on 14-5-7.
//  Copyright (c) 2014年 HuangPeng. All rights reserved.
//

#import "ViewController2.h"
#import "GradientViewController.h"

@interface ViewController2 () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;

@property (nonatomic, strong) NSMutableArray *controllers;

@end

@implementation ViewController2

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
    
    if (self.view.frame.origin.y == 0) {
        CGRect frame = self.view.frame;
        frame.origin.y = 20;
        frame.size.height -= 20;
        self.view.frame = frame;
    }
}

- (NSString *)getDocumentPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, 80, 40)];
    
    [self.view addSubview:webView];
    [self.view addSubview:textField];
    
    NSArray *data = @[@"abc", @"123"];
    
    NSString *filePath = [[self getDocumentPath] stringByAppendingString:@"test.txt"];
    [data writeToFile:filePath atomically:YES];
    
    NSArray *data2 = [NSArray arrayWithContentsOfFile:filePath];
    
    self.controllers = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        UIViewController *controller = [[GradientViewController alloc] init];
        controller.view.backgroundColor = [UIColor colorWithRed:i * 0.3 green:1.0 blue:0 alpha:1.0];
        controller.view.tag = i;
        [self.controllers addObject:controller];
    }
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    [self.pageController setViewControllers:@[self.controllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.superview.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"%@", data2);
}

- (UIViewController *)getControllerAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.controllers.count) return nil;
    return self.controllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self getControllerAtIndex:viewController.view.tag + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self getControllerAtIndex:viewController.view.tag - 1];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
