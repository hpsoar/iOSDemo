#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

//
// iOs中Accelerometer采样的频率: kUpdateFrequency 30
//         人的步行的频率:  2.x
//         人跑步的频率:    2~4.5, 大部分都在: 3左右
// 滤波的逻辑: 过滤高频的部分, 剩下都是直流

//
// 低通滤波
//
@interface LowpassFilter : NSObject
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float z;
@property (nonatomic, readonly) float norm;

// 初始化采样频率
- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

// 添加一个新的输入数据
- (void)addAcceleration:(CMAcceleration)accel;
- (void) reset;
@end



@interface AvergageFilter: NSObject

- (void) reset;
- (void) addData: (double) value;
- (double) getAverage;

@end