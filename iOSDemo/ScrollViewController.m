//
//  ScrollViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/18/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "ScrollViewController.h"

@interface ScrollViewController ()

@end

@implementation ScrollViewController

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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    CGRect frame = scrollView.frame;
    frame.origin.y += 164;
    frame.size.height -= 164;
    scrollView.frame = frame;
    scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(320, 2048);
    [self.view addSubview:scrollView];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    v.backgroundColor = [UIColor blueColor];
    [scrollView addSubview:v];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    frame = btn.frame;
    frame.origin.y = 20;
    frame.origin.x = 20;
    btn.frame = frame;
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    frame = self.view.bounds;
    frame.origin.y = 64;
    frame.size.height -= 64;
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor grayColor];
    [backView addSubview:btn];
    [self.view insertSubview:backView belowSubview:scrollView];
    scrollView.clipsToBounds = NO;
//    scrollView.contentInset = UIEdgeInsetsMake(-80, 0, 0, 0);
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(-100, 0, 0, 0);
    scrollView.contentOffset = CGPointMake(0, 100);
}

- (void)test {
    NSLog(@"hello");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
