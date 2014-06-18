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
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Extendable Gradient View";
            break;
        case 1:
            cell.textLabel.text = @"Animated Circle";
            break;
        case 2:
            cell.textLabel.text = @"Accelerometer & locationManager";
            break;
        case 3:
            cell.textLabel.text = @"Pedometer Test";
            break;
        case 4:
            cell.textLabel.text = @"AltitudeViewController";
            break;
        case 5:
            cell.textLabel.text = @"Shadow";
            break;
        case 6:
            cell.textLabel.text = @"TableInset";
            break;
        case 7:
            cell.textLabel.text = @"page view";
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIViewController *)controllerForRow:(NSInteger)row {
    switch (row) {
        case 0:
            return [[GradientViewController alloc] init];
            break;
            
        case 1:
            return [[AnimatedCircleViewController alloc] init];
            break;
        case 2:
            return self.accelerometerController;
            break;
        case 3:
            return [[PedometerTestController alloc] init];
            break;
        case 4:
            return [AltitudeViewController new];
            break;
        case 5:
            return [ShadowViewController new];
            break;
        case 6:
            return [TableInsetViewController new];
            break;
        case 7:
            return [PageViewController new];
            break;
        default:
            break;
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
