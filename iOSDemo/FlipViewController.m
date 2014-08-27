//
//  FlipViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/28/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "FlipViewController.h"


@interface FlipViewController ()

@property (nonatomic, strong) UIView *smallV;
@property (nonatomic, strong) UIView *largeV;
@property (nonatomic, strong) UIView *container;
@property (nonatomic) BOOL flag;

@end

@implementation FlipViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(20, 84, 280, 480)];
    [self.view addSubview:self.container];
    self.container.clipsToBounds = NO;
    
    self.smallV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 400)];
    self.smallV.backgroundColor = [UIColor redColor];
    [self.container addSubview:self.smallV];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(flip:)];
    
    self.flag = NO;
}

- (UIView *)largeV {
    if (_largeV == nil) {
        _largeV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 480)];
        _largeV.backgroundColor = [UIColor greenColor];
    }
    return _largeV;
}

- (void)flip:(id)sender {
    if (self.flag) {
        [UIView transitionFromView:self.largeV toView:self.smallV duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            
        }];
    }
    else {
        [self.container insertSubview:self.largeV belowSubview:self.smallV];
        [UIView transitionFromView:self.smallV toView:self.largeV duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            
        }];
    }
    self.flag = !self.flag;
}



@end
