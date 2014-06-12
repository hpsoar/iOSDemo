//
//  ViewController.m
//  DrawCircle
//
//  Created by Yeming on 13-8-27.
//  Copyright (c) 2013年 Yeming. All rights reserved.
//

#import "AnimatedCircleViewController.h"
#import <QuartzCore/QuartzCore.h>

#define _OVERIOS7_ ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)

@interface AnimatedCircle : UIView

- (void)animateFrom:(CGFloat)from to:(CGFloat)to;

@end

@implementation AnimatedCircle {
    CAShapeLayer *arcLayer;
    UIView *snapshot;
    UIImageView *animatedImage;
    UIImageView *backgroundImage;
    UIView *overlay;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircle];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupCircle {
    backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"step_round_back.png"]];
    backgroundImage.frame = self.bounds;
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:backgroundImage];
    
    animatedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"step_round_back_color.png"]];
    animatedImage.contentMode = UIViewContentModeScaleAspectFill;
    
    animatedImage.frame = self.bounds;
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGRect rect = animatedImage.bounds;
    [path addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2) radius:(rect.size.height - 30) / 2 startAngle:0 endAngle:2*M_PI clockwise:NO];
    arcLayer=[CAShapeLayer layer];
    arcLayer.path = path.CGPath;
    arcLayer.fillColor= [UIColor clearColor].CGColor;
    arcLayer.strokeColor = [UIColor blackColor].CGColor;
    arcLayer.lineWidth = 30; // TODO: parameterize
    arcLayer.frame= rect;
    
    animatedImage.layer.mask = arcLayer;
    [self addSubview:animatedImage];
//    [self.layer addSublayer:arcLayer];
    
    arcLayer.strokeEnd = 0;

}

- (void)animateFrom:(CGFloat)from to:(CGFloat)to {
    if (!_OVERIOS7_) {
        [overlay removeFromSuperview];
        [snapshot removeFromSuperview];
        [self addSubview:animatedImage];
    }
    
    arcLayer.strokeEnd = to;
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.removedOnCompletion = YES;
    bas.duration=2;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithFloat:from];
    bas.toValue=[NSNumber numberWithFloat:to];
    [arcLayer addAnimation:bas forKey:@"key"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!_OVERIOS7_) {
        snapshot = [[UIImageView alloc] initWithImage:[self snapshot:self]];
        if (!overlay) {
//            overlay = [[UIView alloc] initWithFrame:snapshot.bounds];
//            overlay.backgroundColor = [UIColor redColor];
        }
        [self addSubview:overlay];
        [self addSubview:snapshot];
        [animatedImage removeFromSuperview];
    }
}

- (UIImage *)snapshot:(UIView *)view
{
    //mask layer to image
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, view.bounds.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    [arcLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //draw img
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), view.bounds, maskImage.CGImage);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end

@interface AnimatedCircleViewController ()
{
    CAShapeLayer *arcLayer;
    BOOL _isIntroduceVC;
    NSInteger numberOfHeight;
    BOOL _isIos5;
    BOOL _isAnimation;
    BOOL _isPressButton;
    AnimatedCircle *animatedCircle;
}
@end

@implementation AnimatedCircleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self intiUIOfView];
    self.view.backgroundColor=[UIColor greenColor];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)enterForeground {
    //[animatedCircle animateFrom:0.0 to:0.6];
}

-(void)intiUIOfView
{
    animatedCircle = [[AnimatedCircle alloc]initWithFrame:CGRectMake(100, 100, 180, 180)];
    
    animatedCircle.center = self.view.center;
    
    [self.view addSubview:animatedCircle];
}

- (void)viewDidAppear:(BOOL)animated {
    [animatedCircle animateFrom:1.0 to:0.6];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
