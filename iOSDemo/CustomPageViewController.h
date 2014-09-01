//
//  CustomPageViewController.h
//  iOSDemo
//
//  Created by HuangPeng on 8/27/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageViewController : UIViewController

@property (nonatomic, weak) id<UIPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<UIPageViewControllerDelegate> delegate;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@interface CustomPageViewController2 : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>

@end