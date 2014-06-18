//
//  ChunyuPedometer.h
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

typedef enum PeakType {
    PEAK_TYPE_DOWN = 1, PEAK_TYPE_UP = 2, PEAK_TYPE_NONE = 3,
} PeakType;

typedef enum ThresholdState {
    THRESHOLD_BETWEEN, THRESHOLD_UNDER_LOW, THRESHOLD_OVER_HIGH
} ThresholdState;

//
// 记录了当前的Peak的信息
//
@interface PeakInfo : NSObject

@property (nonatomic) BOOL isCounted;

@property (nonatomic) double magnitude;
@property (nonatomic) PeakType peakType;
@property (nonatomic) double time; // 单位: s

- (void) updatePeakWithTime:(double) time type:(PeakType) peakType magnitude: (double) magnitude;
@end

//
// 发现了Step
//
@protocol StepDelegate
- (void) onNewStep: (PeakInfo*) peakInfo andTotalStep: (int) totalStep;
@end

//
// 算法的接口
//
@protocol StepCounterAlgorithm

- (void) onAccelerometerChangedWithTime:(NSTimeInterval) time andNorm: (CGFloat) norm;

- (void)updateWithAcceleration:(CMAcceleration)acceleration timestamp:(NSTimeInterval)timestamp;

@property (nonatomic, weak) id<StepDelegate> stepDelegate;
@property (nonatomic, assign) int totalStep;

@end

@class LowpassFilter;

@interface ChunyuPedometer : NSObject<StepCounterAlgorithm>

@property (nonatomic, assign) int totalStep;

@property (nonatomic, strong) LowpassFilter *filter;

- (void) reset;
@end
