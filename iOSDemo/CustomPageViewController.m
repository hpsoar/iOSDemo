//
//  CustomPageViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 8/27/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "CustomPageViewController.h"

@interface MyViewController2 : UIViewController

@property (nonatomic) NSInteger direction;

- (id)initWithDirection:(NSInteger)direction index:(NSInteger)index;

- (void)updateWithOffset:(CGFloat)offset;

@property (nonatomic) NSInteger index;

@end

@implementation MyViewController2 {
    UIView *_contentView;
    UIView *_dummyView;
}

- (id)initWithDirection:(NSInteger)direction index:(NSInteger)index {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _direction = direction;
        _index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [self createView];
    
    [self.view addSubview:_contentView];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 100, 100)];
    v.backgroundColor = [self color];
    
    _dummyView = v;
    
    self.direction = _direction;
    
    [self.view addSubview:v];
}

- (UIColor *)color {
    NSArray *colors = @[ [UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor yellowColor] ];
    static NSInteger i = 0;
    i++;
    return colors[i % colors.count];
}

- (UIView *)createView {
    UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
    v.layer.borderColor = [UIColor redColor].CGColor;
    v.layer.borderWidth = 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:v.bounds];
    [v addSubview:label];
    label.text = [NSString stringWithFormat:@"%ld label", (long)self.index];
    label.font = [UIFont systemFontOfSize:80];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSLog(@"%d", self.index);
    
    return v;
}

- (void)setDirection:(NSInteger)direction {
    _direction = direction;
    
    UIView *v = _dummyView;
    if (_direction < 0) {
        v.center = CGPointMake(300, 200);
    }
    else if (_direction > 0) {
        v.center = CGPointMake(20, 200);
    }
    else {
        v.center = CGPointMake(160, 200);
    }
}

- (void)updateWithOffset:(CGFloat)offset {
    NSLog(@"offset: %f", offset);

    BOOL movingRight = YES;
    if (offset > 0) {
        movingRight = NO;
    }
    
    CGFloat factor = 140.0 / 320.0;
    
    CGPoint center = _dummyView.center;
    if (_direction < 0) {
        if (movingRight) {
            center.x = 300 + factor * offset;
        }
    }
    else if (_direction > 0) {
        if (!movingRight) {
            center.x = 20 + factor * offset;
        }
    }
    else {
        center.x = 160 + factor * offset;
    }
    NSLog(@"%d, center x: %f", _index, center.x);
    _dummyView.center = center;
}

@end

@interface CustomPageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic) CGFloat previousOffset;

@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation CustomPageViewController {
    NSMutableArray *_viewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingNone;
    self.scrollView.pagingEnabled = YES;
//    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scrollView];
    
    self.scrollView.delegate = self;
    
    CGRect frame = self.scrollView.bounds;
    frame.size.width *= 3;
    self.containerView = [[UIView alloc] initWithFrame:frame];
    [self.scrollView addSubview:self.containerView];
    
    _viewControllers = [NSMutableArray new];
}

- (void)setCurrentViewController:(UIViewController *)currentViewController {
    _currentViewController = currentViewController;
    
    [self.containerView sendSubviewToBack:currentViewController.view];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (int i = 0; i < _viewControllers.count; ++i) {
        UIViewController *controller = _viewControllers[i];
        [controller.view removeFromSuperview];
    }
    [_viewControllers removeAllObjects];
    
    self.currentViewController = viewControllers[0];
    
    [_viewControllers addObject:self.currentViewController];
    [self.containerView addSubview:self.currentViewController.view];
    
    [self updateContent:-1 finished:NO];
    [self updateContent:1 finished:NO];
}

- (void)updatePageLayout {
    CGRect frame = self.containerView.frame;
    frame.size.width = _viewControllers.count * self.scrollView.frame.size.width;
    self.containerView.frame = frame;
    
    self.containerView.backgroundColor = [UIColor grayColor];
    
    // update layout
    frame = self.scrollView.bounds;
    frame.origin.x = 0;
    for (int i = 0; i < _viewControllers.count; ++i) {
        UIViewController *controller = _viewControllers[i];
        controller.view.frame = frame;
        frame.origin.x += frame.size.width;
    }
}

- (void)popFront {
    [self removePageAtIndex:0];
}

- (void)removePageAtIndex:(NSInteger)index {
    UIViewController *controller = _viewControllers[index];
    [controller.view removeFromSuperview];
    [_viewControllers removeObject:controller];
}

- (void)popBack {
    [self removePageAtIndex:_viewControllers.count - 1];
}

/*
  | |
 
 */
- (void)updateContent:(CGFloat)direction finished:(BOOL)finished {
    BOOL layoutChanged = NO;
    {
        NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
    
        CGFloat selectedViewX = self.currentViewController.view.frame.origin.x;
        CGFloat offset = self.scrollView.contentOffset.x;
        
        UIViewController *previous, *next;
        if (index < _viewControllers.count - 1) {
            next = _viewControllers[index + 1];
        }
        if (index > 0) {
            previous = _viewControllers[index - 1];
        }

        if (offset <= selectedViewX - self.scrollView.frame.size.width) {
            // select left
            NSLog(@"left");
            layoutChanged = YES;
            self.currentViewController = previous;
            if ([self.delegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
                [self.delegate pageViewController:nil
                               didFinishAnimating:finished
                          previousViewControllers:@[ _viewControllers[index] ]
                              transitionCompleted:YES];
            }
        }
        else if (offset >= selectedViewX + self.scrollView.frame.size.width) {
            // select right
            NSLog(@"right");
            layoutChanged = YES;
            self.currentViewController = next;
            if ([self.delegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
                [self.delegate pageViewController:nil
                               didFinishAnimating:finished
                          previousViewControllers:@[ _viewControllers[index] ]
                              transitionCompleted:YES];
            }
        }
        else if (offset < selectedViewX) {
            if ([self.delegate respondsToSelector:@selector(pageViewController:willTransitionToViewControllers:)]) {
                [self.delegate pageViewController:nil willTransitionToViewControllers:@[ previous ]];
            }
        }
        else if (offset > selectedViewX) {
            if ([self.delegate respondsToSelector:@selector(pageViewController:willTransitionToViewControllers:)]) {
                [self.delegate pageViewController:nil willTransitionToViewControllers:@[ next ]];
            }
        }
    }
    
    // update content
    CGFloat add = 0;
    NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
    NSInteger leftCount = index;
    NSInteger rightCount = _viewControllers.count - index - 1;
    if (direction > 0) { // load right
        if (rightCount < 2) {
            UIViewController *controller = [self controllerWithDirection:direction];
            if (controller) {
                layoutChanged = YES;
                [_viewControllers addObject:controller];
                [self.containerView addSubview:controller.view];
            }
        }
    }
    else if (direction < 0) {
        if (leftCount < 2) {
            UIViewController *controller = [self controllerWithDirection:direction];
            if (controller) {
                layoutChanged = YES;
                [_viewControllers insertObject:controller atIndex:0];
                [self.containerView addSubview:controller.view];
                add += 320;
            }
        }
    }
    
    while (leftCount > 2) {
        layoutChanged = YES;
        [self popFront];
        --leftCount;
        add -= 320;
    }
    
    while (rightCount > 2) {
        layoutChanged = YES;
        [self popBack];
        --rightCount;
    }

    if (layoutChanged) {
        [self updatePageLayout];
        
        NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
        self.previousOffset = index * self.scrollView.frame.size.width;
        
        if (add != 0) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + add, 0);
        }
        self.scrollView.contentSize = self.containerView.frame.size;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //[self updateContent:scrollView.contentOffset.x - self.previousOffset finished:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateContent:scrollView.contentOffset.x - self.previousOffset finished:NO];
    
    [self.scrollViewDelegate scrollViewDidScroll:scrollView];
}

- (UIViewController *)controllerWithDirection:(NSInteger)direction {
    if (direction > 0) {
        return [self.dataSource pageViewController:nil viewControllerAfterViewController:self.viewControllers.lastObject];
    }
    else if (direction < 0) {
        return [self.dataSource pageViewController:nil viewControllerBeforeViewController:self.viewControllers.firstObject];
    }
    return nil;
}

@end

@implementation CustomPageViewController2  {
    CustomPageViewController *_pvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pvc = [CustomPageViewController new];
    _pvc.dataSource = self;
    _pvc.delegate = self;
    _pvc.scrollViewDelegate = self;
    
    [self.view addSubview:_pvc.view];
    
    _pvc.viewControllers = @[ [[MyViewController2 alloc] initWithDirection:0 index:0] ];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    MyViewController2 *vc = (MyViewController2 *)viewController;
    if (vc.index > 10) {
        return nil;
    }
    return [[MyViewController2 alloc] initWithDirection:1 index: vc.index + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    MyViewController2 *vc = (MyViewController2 *)viewController;
    if (vc.index < -10) {
        return nil;
    }
    return [[MyViewController2 alloc] initWithDirection:1 index: vc.index - 1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePageState];
    [self updateWithOffset:scrollView.contentOffset.x];
}

- (void)updatePageState {
    NSInteger index = [_pvc.viewControllers indexOfObject:_pvc.currentViewController];
    for (int i = 0; i < index; ++i) {
        MyViewController2 *controller = _pvc.viewControllers[i];
        controller.direction = -1;
    }
    for (int i = index + 1; i < _pvc.viewControllers.count; ++i) {
        MyViewController2 *controller = _pvc.viewControllers[i];
        controller.direction = 1;
    }
    MyViewController2 *controller = _pvc.viewControllers[index];
    controller.direction = 0;
}


- (void)updateWithOffset:(CGFloat)offset {
    NSInteger index = [_pvc.viewControllers indexOfObject:_pvc.currentViewController];
    NSLog(@"--------%f, %d", offset, index);
    for (int i = MAX(0, index - 1); i <= MIN(index + 1, _pvc.viewControllers.count - 1); ++i) {
        MyViewController2 *controller = _pvc.viewControllers[i];
        [controller updateWithOffset:offset - index * 320];
    }
}

@end
