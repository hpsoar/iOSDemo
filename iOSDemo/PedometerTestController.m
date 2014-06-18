//
//  ViewController2.m
//  Test
//
//  Created by HuangPeng on 14-5-7.
//  Copyright (c) 2014年 HuangPeng. All rights reserved.
//

#import "PedometerTestController.h"
#import "GradientViewController.h"
#import "ChunyuPedometer.h"

#define kUpdateFrequency 30.0

@interface PedometerTestController () <StepDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;

@property (nonatomic, strong) NSMutableArray *controllers;

@property (nonatomic, strong) ChunyuPedometer *pedometer;

@property (nonatomic, strong) NSArray *dataPoints;

@property (nonatomic, strong) NSArray *dataFiles;

@property (nonatomic) NSInteger fileIndex;

@property (nonatomic, strong) UILabel *stepsLabel;

@end

@implementation PedometerTestController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}

- (NSString *)getDocumentPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    // 1. setup ui
    self.stepsLabel = [UILabel new];
    self.stepsLabel.frame = CGRectMake(0, 100, 320, 30);
    self.stepsLabel.textAlignment = NSTextAlignmentCenter;
    self.stepsLabel.text = @"0 steps";
    [self.view addSubview:self.stepsLabel];
    
    // 2. load data
    self.dataFiles = @[ @"1.txt", @"2.txt", @"3.txt", @"4.txt" ];
    self.fileIndex = 3;

    NSArray *pathes =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = pathes.firstObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:self.dataFiles[self.fileIndex]];
    NSArray *rawData = [NSArray arrayWithContentsOfFile:filePath];
    self.dataPoints = rawData;
//    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:rawData.count];
//    for (NSString *str in rawData) {
//        NSArray *tmp = [str componentsSeparatedByString:@" "];
//        NSLog(@"%@", tmp);
//    }
    
    // 3. start pedometer
    _pedometer = [[ChunyuPedometer alloc] init];
    
    _pedometer.stepDelegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 / kUpdateFrequency target:self selector:@selector(feedDataToPedometer) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onNewStep:(PeakInfo *)peakInfo andTotalStep:(int)totalStep {
    self.stepsLabel.text = [NSString stringWithFormat:@"%d steps", totalStep];
}

- (void)feedDataToPedometer {
    static NSInteger index = 1;
    if (index < self.dataPoints.count) {
        NSString *str = self.dataPoints[index++];
        NSArray *comps = [str componentsSeparatedByString:@" "];
        NSTimeInterval timestamp = [comps[0] doubleValue];
        CMAcceleration acceleration;
        acceleration.x = [comps[1] doubleValue];
        acceleration.y = [comps[2] doubleValue];
        acceleration.z = [comps[3] doubleValue];
        
        [_pedometer updateWithAcceleration:acceleration timestamp:timestamp];
    }
    else {
        NSLog(@"data exhausted");
    }
}

@end
