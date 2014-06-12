//
//  ViewController3.m
//  Test
//
//  Created by HuangPeng on 5/12/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "GradientViewController.h"

@interface GradientView2 : UIView

@end

@implementation GradientView2 {
    CAGradientLayer *_gradient;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradient = [CAGradientLayer layer];
        _gradient.frame = self.bounds;
        _gradient.startPoint = CGPointMake(0, 1);
        _gradient.endPoint = CGPointMake(0, 0);
        _gradient.opacity = 0.6;
        _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                            (id)[[UIColor clearColor] CGColor], nil];
        self.layer.mask = _gradient;
        _gradient.frame = self.bounds;
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _gradient.frame = self.frame;
}

@end

@interface GradientView : UIView

@end


@implementation GradientView {
    CAGradientLayer *_gradient;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.opacity = 0.6;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSaveGState(con);
    
    /* create gradient */
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // left color
    UIColor *leftColor = [UIColor clearColor];
    const CGFloat *leftColorComponents = CGColorGetComponents(leftColor.CGColor);
    
    // right color
    UIColor *rightColor = [UIColor redColor];
    const CGFloat *rightColorComponents = CGColorGetComponents(rightColor.CGColor);
    
    // color components
    const CGFloat colorComponents[8] = {
        // left color
        leftColorComponents[0],
        leftColorComponents[1],
        leftColorComponents[2],
        leftColorComponents[3],
        // middle color 1
//        middleColor1Components[0],
//        middleColor1Components[1],
//        middleColor1Components[2],
//        middleColor1Components[3],
//        // middle color 2
//        middleColor2Components[0],
//        middleColor2Components[1],
//        middleColor2Components[2],
//        middleColor2Components[3],
        // right color
        rightColorComponents[0],
        rightColorComponents[1],
        rightColorComponents[2],
        rightColorComponents[3]
    };
    
    // color indices
    const CGFloat colorIndices[2] = {
        0.0f, 1.0f
    };
    
    // num of colors
    const unsigned int numColors = 2;
    
    // create gradient
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 colorComponents,
                                                                 colorIndices,
                                                                 numColors);
    
    /* draw gradient */
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint startPoint, endPoint;
    int options = 0;
//    if (YES) {
//        startPoint = CGPointMake(rect.size.width / 4, 0.0f);
//        endPoint = CGPointMake(rect.size.width * .75f, 0.0f);
//        options = kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation;
//    } else {
//        startPoint = CGPointMake(rect.size.width / 4, 0.0f);
//        endPoint = CGPointMake(rect.size.width * .75f, 0.0f);
//    }
    startPoint = CGPointMake(0, 0);
    endPoint = CGPointMake(0, rect.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, options);
    
    /* release */
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(con);
}

@end

@interface GradientViewController ()

@property (nonatomic, strong) UIView *view1;

@property (nonatomic, strong) UIView *view2;

@property (nonatomic, strong) UILabel *label1;

@property (nonatomic, strong) UILabel *label2;

@end

#define RGBCOLOR_HEX(hexColor) [UIColor colorWithRed: (((hexColor >> 16) & 0xFF))/255.0f         \
green: (((hexColor >> 8) & 0xFF))/255.0f          \
blue: ((hexColor & 0xFF))/255.0f                 \
alpha: 1]

@implementation GradientViewController {
    CAShapeLayer *shapeLayer;
}

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
    
    self.view.backgroundColor = [UIColor greenColor];
    
    self.view1 = [[GradientView alloc] initWithFrame:CGRectMake(0, 64, 320, 100)];
    
    self.view2 = [[UIView alloc] initWithFrame:self.view1.frame];
    self.view2.backgroundColor = [UIColor blueColor];
    
    self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_0866.png"]];
    self.view2.contentMode = UIViewContentModeScaleAspectFill;
    self.view2.clipsToBounds = YES;
    self.view2.frame = self.view1.frame;
    
    [self.view addSubview:self.view2];
    
    [self.view addSubview:self.view1];
    
    CGRect frame = self.view1.bounds;
    frame.size.height = 30;
    frame.origin.x = 200;
    frame.origin.y = 60 + 64;
    self.label1 = [[UILabel alloc] initWithFrame:frame];
    self.label1.text = @"hello, world";
    self.label1.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.label1];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 100, 60)];
    [btn setTitle:@"hello" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)btnTouched {
    CGFloat heights[] = { 100, 150, 200, 250, 300 };
    static int index = 0;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration: 0.1f];
//    [UIView setAnimationDelegate: nil]; // TODO: add a animation flag, and a completion event handler
    CGRect frame = self.view1.frame;
    frame.size.height = heights[index++];
    if (index == 5) index = 0;
    self.view2.frame = frame;
    self.view1.frame = frame;
//    [UIView commitAnimations];
    //[self.view1 setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
