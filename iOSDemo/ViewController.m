//
//  ViewController.m
//  Test
//
//  Created by HuangPeng on 14-5-4.
//  Copyright (c) 2014年 HuangPeng. All rights reserved.
//

#import "ViewController.h"
#import "PedometerTestController.h"
#import "GradientViewController.h"
#import "AnimatedCircleViewController.h"
#import "AccelerometerController.h"
#import "AltitudeViewController.h"
#import "ShadowViewController.h"
#import "TableInsetViewController.h"
#import "PageViewController.h"
#import "ScrollViewController.h"
#import "FlipViewController.h"
#import "ShareSDKViewController.h"
#import "SplitViewController.h"
#import "CollectionViewControllerDemo.h"
#import "CustomPageViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIBarButtonItem *item1;
@property (nonatomic, strong) UIBarButtonItem *item2;

@property (nonatomic, strong) AccelerometerController *accelerometerController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"iOSDemo";
	// Do any additional setup after loading the view, typically from a nib.
    self.item1 = [[UIBarButtonItem alloc] initWithTitle:@"hello" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
    self.item2 = [[UIBarButtonItem alloc] initWithTitle:@"world" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationController.navigationItem.rightBarButtonItems = @[ self.item2, self.item1];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (void)test:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *texts = @[ @"Extendable Gradient View",  @"Animated Circle", @"Accelerometer & locationManager", @"Pedometer Test", @"AltitudeViewController", @"Shadow", @"TableInset", @"page view", @"scroll view", @"flip transition", @"ShareSDK", @"split view controller", @"collection view controller", @"custom pageview controller" ];
    
    if (indexPath.row < texts.count) {
        cell.textLabel.text = texts[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIViewController *)controllerForRow:(NSInteger)row {
    NSArray *controllers = @[ [GradientViewController new], [AnimatedCircleViewController new],  self.accelerometerController, [PedometerTestController new], [AltitudeViewController new], [ShadowViewController new], [TableInsetViewController new], [PageViewController new], [ScrollViewController new], [FlipViewController new], [ShareSDKViewController new], [SplitViewController new], [CollectionViewControllerDemo new], [CustomPageViewController new]];
    if (row < controllers.count) {
        return controllers[row];
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    UIViewController *controller = [self controllerForRow:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    return indexPath;
}

#pragma mark - Properties
- (AccelerometerController *)accelerometerController {
    if (_accelerometerController == nil) {
        _accelerometerController = [[AccelerometerController alloc] init];
    }
    return _accelerometerController;
}

@end
