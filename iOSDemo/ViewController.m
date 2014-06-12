//
//  ViewController.m
//  Test
//
//  Created by HuangPeng on 14-5-4.
//  Copyright (c) 2014年 HuangPeng. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"
#import "GradientViewController.h"
#import "AnimatedCircleViewController.h"
#import "AccelerometerController.h"

@interface ViewController ()

@property (nonatomic, strong) UIBarButtonItem *item1;
@property (nonatomic, strong) UIBarButtonItem *item2;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"hello";
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    
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
            return [[AccelerometerController alloc] init];
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

@end
