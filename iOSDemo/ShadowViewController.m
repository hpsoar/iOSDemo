//
//  ShadowViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/15/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "ShadowViewController.h"

@interface ShadowViewController ()

@end

@implementation ShadowViewController

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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(20, 84, 280, 400)];
    
    card.layer.cornerRadius = 10;
    
    card.layer.shadowOpacity = 0.8;
    card.layer.shadowColor = [UIColor blueColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(10, 10);
    card.layer.shadowRadius = 10;
    
    card.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:card];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
