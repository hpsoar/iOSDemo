//
//  LocalMinMaxQueue.h
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-19.
//
//

#import "ChunyuPedometer.h"

#import <Foundation/Foundation.h>
//
//
//
@interface LocalMinMaxItem: NSObject

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) NSTimeInterval time; // 加速度的norm的value和时间
@property (nonatomic, assign) NSInteger minIndex;  // 在最小优先级队列中的位置, 如果为 -1 表示不在队列中
@property (nonatomic, assign) NSInteger maxIndex;  // 在最大优先级队列中的位置, 如果为 -1 表示不在队列中

@property (nonatomic, assign) NSInteger bufferIndex; // 在环形队列中的位置

@end


//
//
//
@interface LocalMinMaxQueue : NSObject

- (id) initWithSize: (NSInteger) size;
- (void) addNorm: (CGFloat) value andTime: (NSTimeInterval) time;

- (BOOL) isFull;

// 中心点是否为PeakType: 是否为波峰或波谷
- (PeakType) centerPeakType;

- (LocalMinMaxItem*) getCenterItem;


- (LocalMinMaxItem*) getLocalMaxItem;
- (LocalMinMaxItem*) getLocalMinItem;

@end


