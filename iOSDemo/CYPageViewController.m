//
//  CYPageViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/18/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "CYPageViewController.h"

@interface CYPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) id<UIPageViewControllerDelegate> thisDelegate;
@property (nonatomic, weak) id<UIPageViewControllerDataSource> thisDataSource;

@property (nonatomic, strong) UIViewController *targetController; // remove the need of this

@property (nonatomic) NSInteger pageOffset;
@property (nonatomic) BOOL pageSwitched;

@end

@implementation CYPageViewController
@synthesize currentViewController = _currentViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.dataSource = self;
    
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)v).delegate = self;
        }
    }
}

#pragma mark - wrapped delegate and data source
- (void)setDelegate:(id<UIPageViewControllerDelegate>)delegate {
    if (delegate == self) {
        [super setDelegate:delegate];
    }
    else {
        _thisDelegate = delegate;
    }
}

- (void)setDataSource:(id<UIPageViewControllerDataSource>)dataSource {
    if (dataSource == self) {
        [super setDataSource:dataSource];
    }
    else {
        _thisDataSource = dataSource;
    }
}

#pragma mark - pageviewcontroller datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.targetController = viewController;
    return [self.thisDataSource pageViewController:pageViewController viewControllerAfterViewController:viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    self.targetController = viewController;
    return [self.thisDataSource pageViewController:pageViewController viewControllerBeforeViewController:viewController];
}

#pragma mark - pageviewcontroller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    // NOTE: completed is not reliable, we rely on pageOffset, and targetController
    if ([self switchPage:@"trans"]) {
        if ([self.thisDelegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
            [self.thisDelegate pageViewController:pageViewController didFinishAnimating:finished previousViewControllers:previousViewControllers transitionCompleted:completed];
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

    if ([self.thisDelegate respondsToSelector:@selector(pageViewController:willTransitionToViewControllers:)]) {
        [self.thisDelegate pageViewController:pageViewController willTransitionToViewControllers:pendingViewControllers];
    }
}

- (BOOL)switchPage:(NSString*)log {
    NSLog(@"%@", log);
    NSLog(@"page offset: %d", self.pageOffset);
    
    BOOL ret = NO;
    if (!self.pageSwitched) {
        self.pageSwitched = YES;
        // either page transition finished or scroll finished, but not both
        
        NSLog(@"finished by %@", log);
        if (self.pageOffset != 0 && self.viewControllers.firstObject == self.currentViewController) {
            UIPageViewControllerNavigationDirection dir = self.currentViewController.view.tag < self.targetController.view.tag ?
            UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
            [self setCurrentViewController:self.targetController direction:dir];
        }
        ret = YES;
    }
    NSLog(@"tag: %d, %d", [self.viewControllers.firstObject view].tag, self.targetController.view.tag);
    return ret;
}

- (void)switchPageDrivenByScrollEvent {
    if ([self switchPage:@"dragging"]) {
        if ([self.thisDelegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
            [self.thisDelegate pageViewController:self didFinishAnimating:YES previousViewControllers:nil transitionCompleted:YES];
        }
    }
}

- (void)setCurrentViewController:(UIViewController *)currentViewController direction:(UIPageViewControllerNavigationDirection)direction {
    [self setViewControllers:@[currentViewController] direction:direction animated:NO completion:^(BOOL finished) {

    }];
    _currentViewController = self.viewControllers.firstObject;
}

- (void)setCurrentViewController:(UIViewController *)currentViewController {
    [self setCurrentViewController:currentViewController direction:UIPageViewControllerNavigationDirectionForward];
}

- (UIViewController *)currentViewController {
    return self.viewControllers.firstObject;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.x);
    static CGFloat previousOffset = FLT_MAX;
    if (previousOffset != FLT_MAX) {
        // TODO: find more robust way to determine page change
        if (scrollView.contentOffset.x < 420) {
            if (previousOffset > 600) {
                // new right page
                self.pageOffset++;
            }
        }
        if (scrollView.contentOffset.x > 220) {
            if (previousOffset < 100) {
                // new left page
                self.pageOffset--;
            }
        }
    }
    previousOffset = scrollView.contentOffset.x;
    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageSwitched = NO;
    self.pageOffset = 0;
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.scrollDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.scrollDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self switchPageDrivenByScrollEvent];
    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.scrollDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self switchPageDrivenByScrollEvent];
    }
    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.scrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

// .... TODO: add more scroll delegate responder

@end
