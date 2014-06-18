//
//  CYPageViewController.h
//  iOSDemo
//
//  Created by HuangPeng on 6/18/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYPageViewController : UIPageViewController

@property (nonatomic, weak) id<UIScrollViewDelegate> scrollDelegate;

@property (nonatomic, strong) UIViewController *currentViewController;

@end
