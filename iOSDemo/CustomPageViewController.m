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

- (id)initWithDirection:(NSInteger)direction;

- (void)updateWithOffset:(CGFloat)offset;

@property (nonatomic) NSInteger index;

@end

@implementation MyViewController2 {
    UIView *_contentView;
    UIView *_dummyView;
}

- (id)initWithDirection:(NSInteger)direction {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _direction = direction;
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
    static NSInteger i = 0;
    
    UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
    v.layer.borderColor = [UIColor redColor].CGColor;
    v.layer.borderWidth = 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:v.bounds];
    [v addSubview:label];
    label.text = [NSString stringWithFormat:@"%ld label", (long)i];
    label.font = [UIFont systemFontOfSize:80];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSLog(@"%d", i);
    
    _index = i;
    
    i++;
    
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

@interface CustomPageViewController () <UIPageViewControllerDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) id<UIPageViewControllerDataSource> dataSource;
@property (nonatomic, strong) UIViewController *currentViewController;
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

    self.dataSource = self;
    
    self.scrollView.delegate = self;
    
    CGRect frame = self.scrollView.bounds;
    frame.size.width *= 3;
    self.containerView = [[UIView alloc] initWithFrame:frame];
    [self.scrollView addSubview:self.containerView];
    
    _viewControllers = [NSMutableArray new];
    
    self.viewControllers = @[ [self controllerWithDirection:0] ];
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

    [self updatePageLayout];
    
    [self updatePageState];
//    [self updateContent:-1 finished:YES];
//    [self updateContent:1 finished:YES];
}

- (void)updatePageLayout {
    CGRect frame = self.containerView.frame;
    frame.size.width = _viewControllers.count * self.scrollView.frame.size.width;
    self.containerView.frame = frame;
    self.scrollView.contentSize = frame.size;
    
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

- (void)updatePageState {
    [self.containerView sendSubviewToBack:self.currentViewController.view];
    
    NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
    for (int i = 0; i < index; ++i) {
        MyViewController2 *controller = _viewControllers[i];
        controller.direction = -1;
    }
    for (int i = index + 1; i < _viewControllers.count; ++i) {
        MyViewController2 *controller = _viewControllers[i];
        controller.direction = 1;
    }
    MyViewController2 *controller = _viewControllers[index];
    controller.direction = 0;
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
    {
        NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
    
        CGFloat selectedViewX = self.currentViewController.view.frame.origin.x;
        CGFloat offset = self.scrollView.contentOffset.x;
        if (offset <= selectedViewX - self.scrollView.frame.size.width) {
            // select left
            NSLog(@"left");
            self.currentViewController = _viewControllers[index - 1];
        }
        else if (offset >= selectedViewX + self.scrollView.frame.size.width) {
            // select right
            NSLog(@"right");
            self.currentViewController = _viewControllers[index + 1];
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
                [_viewControllers addObject:controller];
                [self.containerView addSubview:controller.view];
            }
        }
    }
    else if (direction < 0) {
        if (leftCount < 2) {
            UIViewController *controller = [self controllerWithDirection:direction];
            if (controller) {
                [_viewControllers insertObject:controller atIndex:0];
                [self.containerView addSubview:controller.view];
            }
            add += 320;
        }
    }
    
    while (leftCount > 2) {
        [self popFront];
        --leftCount;
        add -= 320;
    }
    
    while (rightCount > 2) {
        [self popBack];
        --rightCount;
    }

    
    [self updatePageLayout];
    {
        NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
        self.previousOffset = index * self.scrollView.frame.size.width;
        //self.scrollView.contentOffset = CGPointMake(self.previousOffset + direction, 0);
    }
    
    if (add != 0) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + add, 0);
    }
    
    [self updatePageState];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //[self updateContent:scrollView.contentOffset.x - self.previousOffset finished:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateContent:scrollView.contentOffset.x - self.previousOffset finished:NO];
    [self updateWithOffset:scrollView.contentOffset.x];
}

- (void)updateWithOffset:(CGFloat)offset {
    NSInteger index = [_viewControllers indexOfObject:self.currentViewController];
    for (int i = MAX(0, index - 1); i <= MIN(index + 1, _viewControllers.count - 1); ++i) {
        MyViewController2 *controller = _viewControllers[i];
        [controller updateWithOffset:offset - self.previousOffset];
    }
}

- (UIViewController *)controllerWithDirection:(NSInteger)direction {
    return [[MyViewController2 alloc] initWithDirection:direction];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self controllerWithDirection:1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self controllerWithDirection:-1];
}

@end
