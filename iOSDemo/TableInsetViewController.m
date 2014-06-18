//
//  TableInsetViewController.m
//  iOSDemo
//
//  Created by HuangPeng on 6/15/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "TableInsetViewController.h"

@interface TableInsetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *toolBoardView;

@end

@implementation TableInsetViewController

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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.clipsToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    
    self.tableView.contentOffset = CGPointMake(0, 50);
    
    [self.view addSubview:self.tableView];
    
    if (self.toolBoardView == nil) {
        self.toolBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.bounds.size.width, 200)];
        self.toolBoardView.backgroundColor = [UIColor grayColor];
        UILabel *label = [UILabel new];
        label.text = @"hello";
        [label sizeToFit];
        [self.toolBoardView addSubview:label];
        [self.view insertSubview:self.toolBoardView belowSubview:self.tableView];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

#pragma mark - delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    for (UIView *view in scrollView.subviews) {
        if (![view isKindOfClass:[UIImageView class]]) {
            view.layer.cornerRadius = 10;
        }
    }
//    CGFloat top = MAX(0, scrollView.contentOffset.y);
//    scrollView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
}

@end
