/*
     File: MainViewController.m
 Abstract: Responsible for all UI interactions with the user and the accelerometer
  Version: 2.6
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "AccelerometerController.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#include <sys/types.h>
#include <sys/sysctl.h>

#define MIB_SIZE 2

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resume","resume taking samples")

@class DLog;

@protocol DLogDelegate <NSObject>

@optional
- (void)DLog:(DLog*)logger updatedWithLogs:(NSArray *)logs;

@end

@interface DLog : NSObject

- (void)log:(NSString *)format, ...;

@property (nonatomic, readonly) NSArray *logs;

@property (nonatomic, weak) id<DLogDelegate> delegate;

@end

@implementation DLog {
    NSMutableArray *_logs;
    NSString *_logFilePath;
}

- (id)init {
    self = [super init];
    if (self) {
        _logs = [[NSMutableArray alloc] initWithCapacity:10];
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        _logFilePath = [docPath stringByAppendingString:@"sensor.log"];
    }
    return self;
}

- (void)log:(NSString *)formatString, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, formatString);
    NSString *str = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    NSString *dateStr = [NSString stringWithFormat:@"%@, ", [NSDate date]];
    str = [dateStr stringByAppendingString:str];
    [_logs addObject:str];
    
    [_logs writeToFile:_logFilePath atomically:YES];
    
    if ([self.delegate respondsToSelector:@selector(DLog:updatedWithLogs:)]) {
        [self.delegate DLog:self updatedWithLogs:self.logs];
    }
#endif
}

@end

@interface AccelerometerController() <CLLocationManagerDelegate, DLogDelegate>
{
    NSTimeInterval _lastSaveTime;
    CGFloat _yOffset;
    CGFloat _maxWidth;
}

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSMutableArray *accelerations;
@property (nonatomic, strong) NSDate *bootTime;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DLog *logger;
@property (nonatomic, strong) UIScrollView *scrollView;

- (IBAction)saveAccelData:(id)sender;
- (IBAction)switchAutoPause:(id)sender;

@end

@implementation AccelerometerController

- (NSMutableArray *)accelerations {
    if (nil == _accelerations) {
        _accelerations = [[NSMutableArray alloc] init];
    }
    return _accelerations;
}

- (void)DLog:(DLog *)logger updatedWithLogs:(NSArray *)logs {
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor redColor];
    UILabel *prevLabel = logs.count <= 1 ? nil : _scrollView.subviews.lastObject;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = logs.lastObject;
    [label sizeToFit];
    [_scrollView addSubview:label];
    
    if (prevLabel == nil) {
        _yOffset = 10;
    }
    
    CGRect frame = label.frame;
    frame.origin.x = 10;
    frame.origin.y = _yOffset;
    label.frame = frame;
    
    _yOffset += frame.size.height + 1;
    _maxWidth = MAX(_maxWidth, frame.size.width);
    _scrollView.contentSize = CGSizeMake(_maxWidth, _yOffset);
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 30, 320, 440)];
    _scrollView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_scrollView];
    
    _logger = [DLog new];
    _logger.delegate = self;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 1.0 / kUpdateFrequency; // 设置加速度的更新频率
    
    __weak AccelerometerController *_self = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [_self processAccelerometerData:accelerometerData withError:error];
    }];
    
    // 保证自己不死
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers; // 尽量少用电
    self.locationManager.distanceFilter = 1000;
    
    [self updateIdLabel:NO];
    
    [self.locationManager startUpdatingLocation];
    
    int mib[MIB_SIZE];
    size_t size;
    struct timeval  boottime;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_BOOTTIME;
    size = sizeof(boottime);
    if (sysctl(mib, MIB_SIZE, &boottime, &size, NULL, 0) != -1)
    {
        // successful call
        NSDate* bootDate = [NSDate dateWithTimeIntervalSince1970:
                            boottime.tv_sec + boottime.tv_usec / 1.e6];
        self.bootTime = bootDate;
    }
}

- (void)processAccelerometerData:(CMAccelerometerData *)accelerometerData withError:(NSError *)error {
    CMAcceleration accel = accelerometerData.acceleration;
    [self.accelerations addObject:[NSString stringWithFormat:@"%@ %@ %@ %@\n", @(accelerometerData.timestamp), @(accel.x), @(accel.y), @(accel.z)]];
    
    self.stepsLabel.text = [NSString stringWithFormat:@"%d points", self.accelerations.count];
    
    if (accelerometerData.timestamp - _lastSaveTime > 3600) {
        [self saveAccelData:nil];
        _lastSaveTime = accelerometerData.timestamp;
    }
}

- (IBAction)saveAccelData:(id)sender {
    NSArray *pathes =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = pathes.firstObject;
    NSString *filename = [NSString stringWithFormat:@"%@.txt", [NSDate date]];
    NSString *filePath = [documentPath stringByAppendingPathComponent:filename];
    [self.accelerations writeToFile:filePath atomically:NO];
    
    [self.logger log:@"saved %@", filename];
}

- (void)updateIdLabel:(BOOL)log {
    if (self.locationManager.pausesLocationUpdatesAutomatically) {
        self.idLabel.text = @"autoPause";
    }
    else {
        self.idLabel.text = @"nonAutoPause";
    }
    
    if (log) {
        [self.logger log:@"switch to %@", self.idLabel.text];
    }
}

- (IBAction)switchAutoPause:(id)sender {
    self.locationManager.pausesLocationUpdatesAutomatically = !self.locationManager.pausesLocationUpdatesAutomatically;
    
    [self updateIdLabel:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.logger log:@"update location"];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self.logger log:@"paused location"];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self.logger log:@"resumed location"];
}

@end
