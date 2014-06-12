//
//  altitudeViewController.m
//  Altitude
//
//  Created by Matt Gabriel on 03/11/2013.
//  Copyright (c) 2013 Matt Gabriel. All rights reserved.
//

#import "AltitudeViewController.h"

@interface AltitudeViewController ()

@property (nonatomic, strong) UIScrollView *sv;

@property (nonatomic) CGFloat maxAltitude;

@end

@implementation AltitudeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    self.sv = [UIScrollView new];
    self.sv.backgroundColor = [UIColor redColor];
    self.sv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.sv];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|" options:0 metrics:nil views:@{@"sv": self.sv}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sv]|" options:0 metrics:nil views:@{@"sv": self.sv}]];
    
    UIImage *image = [[UIImage imageNamed:@"background_2"] resizableImageWithCapInsets:UIEdgeInsetsMake(400, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sv addSubview:imgView];
    
    [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:@{@"v": imgView}]];
    
    [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v": imgView}]];
    
    self.maxAltitude = 4000;
    [self drawLines]; //call the draw line method
    
    _heightLabelBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    _heightLabelBG.translatesAutoresizingMaskIntoConstraints = NO;
    _heightLabel = [UILabel new];
    _heightLabel.text = @"Not available, yet...";
    _heightLabel.textAlignment = NSTextAlignmentCenter;
    _heightLabel.font = [UIFont systemFontOfSize:48];
    
    [_heightLabelBG addSubview:_heightLabel];
    
    _label = [UILabel new];
    _label.textColor = [UIColor grayColor];
    [_heightLabelBG addSubview:_label];
    
    [self.sv addSubview:_heightLabelBG];
    [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[v]|" options:0 metrics:nil views:@{@"v": _heightLabelBG}]];
    [self.sv addConstraint:[NSLayoutConstraint constraintWithItem:_heightLabelBG attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:100]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateAltitudeLabelFrameWithHeight:self.view.bounds.size.height / 2];
}

- (void)updateAltitudeLabelFrameWithHeight:(CGFloat)height {
    _heightLabelBG.center = CGPointMake(_heightLabelBG.center.x, height);
    _heightLabel.frame = _heightLabelBG.bounds;
    _label.center = CGPointMake(_heightLabelBG.bounds.size.width / 2, _heightLabelBG.bounds.size.height - _label.bounds.size.height / 2);
}

- (void)drawLines {
    CGFloat altitude = self.maxAltitude;
    
    UIView *previousView;
    
    for(int i = 0; i <100000 && altitude >= -200; i++){
        CGFloat lineWidth = 15;
        if (i % 5 == 0) {
            lineWidth = 25;
            UILabel *tickerLabel = [UILabel new];
            tickerLabel.translatesAutoresizingMaskIntoConstraints = NO;
            if (altitude >= 1000) {
                CGFloat kilos = altitude / 1000;
                tickerLabel.text = [NSString stringWithFormat:@"%.1fk", kilos];
            }
            else {
                tickerLabel.text = [NSString stringWithFormat:@"%.0f", altitude];
            }
            tickerLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
            
            [self.sv addSubview:tickerLabel];
            
            if (nil == previousView) {
                [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(25)-[v]" options:0 metrics:nil views:@{@"v": tickerLabel}]];
            }
            else {
                [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(8)-[v]" options:0 metrics:nil views:@{@"v": tickerLabel, @"prev": previousView}]];
            }
            [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(40)-[v]" options:0 metrics:nil views:@{@"v": tickerLabel}]];
        }
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor blackColor];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.sv addSubview:lineView];
        
        if (nil == previousView) {
            [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(35)-[v(0.5)]" options:0 metrics:nil views:@{@"v": lineView}]];
        }
        else {
            [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(18)-[v(0.5)]" options:0 metrics:nil views:@{@"prev": previousView, @"v": lineView}]];
        }
        
        [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[v(w)]" options:0 metrics:@{@"w": @(lineWidth)} views:@{@"v": lineView}]];

        previousView = lineView;
        altitude -= 40;
    }
    [self.sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(100)-|" options:0 metrics:nil views:@{@"prev": previousView}]];
}


-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    float altitude = newLocation.altitude;
    float altitudeMapped = [self mapping:altitude inMin:-200.00 inMax:self.maxAltitude outMin:self.sv.contentSize.height - 100 outMax:40.00];
    
    _heightLabel.text = [NSString stringWithFormat:@"%.2fm", altitude];
    _label.text = [NSString stringWithFormat:@"Accuracy %.2f m", newLocation.verticalAccuracy];
    [_label sizeToFit];
    
    [UIView animateWithDuration:2.0 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^(void){
        [self updateAltitudeLabelFrameWithHeight:altitudeMapped];
    }completion:^(BOOL Finished){ }];

    if (!(self.sv.dragging || self.sv.tracking || self.sv.decelerating)) {
        [self.sv scrollRectToVisible:_heightLabelBG.frame animated:YES];
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    _heightLabel.text = [NSString stringWithFormat:@"trying..."];
}


-(float)mapping:(float)currentValue inMin:(float)inMin inMax:(float)inMax outMin:(float)outMin outMax:(float)outMax{
    //mapping function, just like in arduino
    float result = (currentValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    return result;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
