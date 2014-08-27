//
//  SplitViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 8/14/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "SplitViewController.h"

@class TouchView;
@protocol TouchViewDelegate <NSObject>

- (void)touchView:(TouchView *)touchView touchPointMovedTo:(CGPoint)point;

@end

@interface TouchView : UIView

@property (nonatomic) CGFloat xSplitPosition;
@property (nonatomic) CGFloat splitAreaWidth;
@property (nonatomic, weak) id<TouchViewDelegate> delegate;

@end

@implementation TouchView {
    BOOL _moving;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    if (point.x > self.xSplitPosition - self.splitAreaWidth && point.x < self.xSplitPosition + self.splitAreaWidth) {
//        return YES;
//    }
//    return [super pointInside:point withEvent:event];
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.x > self.xSplitPosition - self.splitAreaWidth && point.x < self.xSplitPosition + self.splitAreaWidth) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _moving = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_moving) {
        UITouch *touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        
        [self.delegate touchView:self touchPointMovedTo:point];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _moving = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _moving = NO;
}

@end

@interface SplitViewController () <TouchViewDelegate>
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, strong) TouchView *touchView;
@end

@implementation SplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect frame = self.view.bounds;
    frame.size.width /= 2;
    self.leftTableView = [[UITableView alloc] initWithFrame:frame];
    self.leftTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    frame.origin.x = frame.size.width;
    self.rightTableView = [[UITableView alloc] initWithFrame:frame];
    self.rightTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.touchView = [[TouchView alloc] initWithFrame:self.view.bounds];
    self.touchView.xSplitPosition = frame.size.width;
    self.touchView.splitAreaWidth = 10;
    self.touchView.delegate = self;
    [self.view addSubview:self.touchView];
    
    [self.touchView addSubview:self.leftTableView];
    [self.touchView addSubview:self.rightTableView];
}

- (void)touchView:(TouchView *)touchView touchPointMovedTo:(CGPoint)point {
    CGRect tmp = self.leftTableView.frame;
    tmp = self.rightTableView.frame;
    
    CGRect frame = self.view.bounds;
    frame.size.width = point.x;
    self.leftTableView.frame = frame;
    
    frame = self.view.bounds;
    frame.size.width -= point.x;
    frame.origin.x = point.x;
    self.rightTableView.frame = frame;
    
    touchView.xSplitPosition = point.x;
}

@end
