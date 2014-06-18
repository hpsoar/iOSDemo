//
//  ChunyuPedometer.m
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-15.
//
//

#import "ChunyuPedometer.h"
#import "MathUtils.h"
#import "LocalMinMaxQueue.h"
#import "AccelerometerFilter.h"

#define kPeakBufferSize 20
#define kUpdateFrequency 30

@implementation PeakInfo

- (void) updatePeakWithTime:(double) time type:(PeakType) peakType magnitude: (double) magnitude { //  andIdx: (int) idx
    //    self.index = idx;
    self.magnitude = magnitude;
    self.peakType = peakType;
    self.time = time;
}

@end

typedef enum WorkingMode {
    kWalking, kNonWalking
} WorkingMode;


@implementation ChunyuPedometer {
    int _totalStep;
    
    // 循环数组:
    NSMutableArray* _peaks;
    NSInteger _lastPeakPos;
    NSInteger _lastCountedPos;
    
    
    ThresholdState _thresholdState;
    
    double _currentValue;
    NSTimeInterval _currentTime;
    

    NSTimeInterval _minPeakIntervalSameStep;
    double _currentThreshold;
    
    LocalMinMaxQueue* _minMaxQueue;
    
    
    // 用于运动模式的检测
    WorkingMode _workingMode;
    NSTimeInterval _lastPeakUpTime;
    NSInteger _pendingPeakNum;

}

@synthesize totalStep = _totalStep;
@synthesize stepDelegate = _stepDelegate;


- (id) init {
    self = [super init];
    if (self) {
        
        _peaks = [NSMutableArray arrayWithCapacity: kPeakBufferSize];
        for (int i = 0; i < kPeakBufferSize; i++) {
            PeakInfo* peakInfo = [[PeakInfo alloc] init];
            [_peaks addObject: peakInfo];
        }

        [self reset];
        
        _minMaxQueue = [[LocalMinMaxQueue alloc] initWithSize: 9];
        
        _minPeakIntervalSameStep = 0.2;
        _currentThreshold = 0.04;
        
        _filter = [[LowpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency: 5.0];
    }
    return self;
}

//
// 输入的数据:
//
- (void) onAccelerometerChangedWithTime:(NSTimeInterval) time andNorm: (CGFloat) value {
    

    [_minMaxQueue addNorm: value andTime: time];
    
    PeakType peakType = [_minMaxQueue centerPeakType];
    if (peakType != PEAK_TYPE_NONE) {
        LocalMinMaxItem* item = [_minMaxQueue getCenterItem];
        
        // 幅度太小了，直接返回
        if (item.value < 0.025) {
            // printf("item value: %.3f", item.value);
            return;
        }
        if (peakType == PEAK_TYPE_DOWN) {
            // 局部最小值
            [self addPeakWithMag: item.value time: item.time andPeakType: PEAK_TYPE_DOWN];
        } else if (peakType == PEAK_TYPE_UP) {
            // 局部最大值
            [self addPeakWithMag: item.value time: item.time andPeakType: PEAK_TYPE_UP];
        }
        
    }
}

- (void)updateWithAcceleration:(CMAcceleration)acceleration timestamp:(NSTimeInterval)timestamp {
    [_filter addAcceleration:acceleration];
    
    [self onAccelerometerChangedWithTime:timestamp andNorm: _filter.norm];
}

- (void) addPeakWithMag: (double) magnitude time:(NSTimeInterval)time andPeakType: (PeakType)peakType {
    PeakInfo* lastPeak = (_lastPeakPos >= 0) ? _peaks[_lastPeakPos] : nil;
    
    if (lastPeak) {
        if (peakType == PEAK_TYPE_UP) {
            // 如果同是UP, 并且间隔小于 _minPeakIntervalSameStep, 则合并
            if (lastPeak.peakType == PEAK_TYPE_UP && time - lastPeak.time < _minPeakIntervalSameStep) {
                if (magnitude > lastPeak.magnitude) {
                    lastPeak.time = time;
                    lastPeak.magnitude = magnitude;
                    lastPeak.peakType = PEAK_TYPE_UP;
                }
                return;
            }
        } else {
            // 如果同是DOWN, 并且间隔小于 _minPeakIntervalSameStep, 则合并
            if (lastPeak.peakType == PEAK_TYPE_DOWN && time - lastPeak.time < _minPeakIntervalSameStep) {
                if (magnitude < lastPeak.magnitude) {
                    lastPeak.time = time;
                    lastPeak.magnitude = magnitude;
                    lastPeak.peakType = PEAK_TYPE_DOWN;
                }
                return;
            }
        }
    }
    
    // 其他情况下添加新的Peak
    if (peakType == PEAK_TYPE_UP && _lastPeakPos >= 0) {
        // 需要和前一个peakType == UP的接点间距至少: 0.25s
        for (int i = 0; i < kPeakBufferSize; i++) {
            int loc = _lastPeakPos - i;
            if (loc < 0) {
                loc += kPeakBufferSize;
            }
            PeakInfo* peak = _peaks[loc];
            if (peak.peakType == PEAK_TYPE_UP) {
                // 每秒4步
                NSTimeInterval diff = time - peak.time;
                if (diff < 0.22) {
                    // 退出之前的Steps
                    _lastPeakPos = loc;
                    
                    PeakInfo* newPeak = _peaks[_lastPeakPos];
                    newPeak.time = time;
                    newPeak.magnitude = magnitude;
                    newPeak.peakType = peakType;
                    newPeak.isCounted = NO;
                    
                    return;
                } else {
                    // 找到一个合适的
                    break;
                }
            }
            
        }
    }
    
    _lastPeakPos = (_lastPeakPos + 1) % kPeakBufferSize;
    PeakInfo* newPeak = _peaks[_lastPeakPos];
    
    // 新加入的接点: isCounted = NO
    // 更新newPeak
    newPeak.time = time;
    newPeak.magnitude = magnitude;
    newPeak.peakType = peakType;
    newPeak.isCounted = NO;
    
    
    // 只有新增加Peak时才启动检测
    if (peakType == PEAK_TYPE_UP) {
        [self detectSteps];
    }
}

- (void) detectSteps {
    // 遍历10个结点:
    // 假设: _lastCountedPos < _lastPeakPos
    int normalizedPeakPos = _lastPeakPos;
    if (_lastCountedPos > _lastPeakPos) {
        normalizedPeakPos = _lastPeakPos + kPeakBufferSize;
    }
    
    
    
    // lastCountedPos表示最后一个被处理完毕的Step
    // 接下来要处理的就是 lastCountedPos + 1, lastCountedPos + 2
    for (int i = _lastCountedPos + 2; i < normalizedPeakPos; ) {

        int k = i % kPeakBufferSize;
        int k1 = (i - 1) % kPeakBufferSize;
        
        PeakInfo* info = _peaks[k];
        PeakInfo* info1 = _peaks[k1];
        
        if (info.peakType != info1.peakType) {
            [self onGenerateNewStep: info];
            
            i += 2;
            _lastCountedPos = (_lastCountedPos + 2) % kPeakBufferSize;;
            // printf("PATTERN: %s - %s\n", info1.peakType == PEAK_TYPE_UP ? "UP" : "DOWN", info.peakType == PEAK_TYPE_UP ? "UP" : "DOWN");
        } else {

            // 只有处于UP状态，才算是正常的
            if (info.peakType == PEAK_TYPE_UP) {

                
                // 检测是否是有效的检测结果:
                
                // printf("PATTERN: UP - UP\n");
                // UP/UP时需要检测两个UP之间是否有低谷出现(不一定是靠谱的低谷，但是一定要
                [self onGenerateNewStep: info];
            }
            
            i += 1;
            _lastCountedPos = (_lastCountedPos + 1) % kPeakBufferSize;;
        }
    }
    
}

//
// @param peakInfo: peakInfo是一个有效的波峰
//
// 需要根据peakInfo以及之前的数据来判断用户的步行状态
//
- (void) onGenerateNewStep: (PeakInfo*) peakInfo {
    
    // 如果出现当个的Peak,  则直接放弃
    if (_workingMode == kWalking) {
        // 不行状态，检测什么时候没有步行(正在步行时运行有一些扰动)
        if (peakInfo.time - _lastPeakUpTime > 4)  {
            _pendingPeakNum = 1; // 当前的点，可能是新的一段walking的起点
            _workingMode = kNonWalking;
        } else {
            _totalStep++;
            [self.stepDelegate onNewStep: peakInfo andTotalStep: _totalStep];
        }
    } else {
        // 检测是否开始了:
        if (peakInfo.time - _lastPeakUpTime <= 1.10) {
            _pendingPeakNum++;
            
            // 乐动力如果低于10步，则暂时不记录
            if (_pendingPeakNum >= 8) {
                _workingMode = kWalking;
                for (int i = 0; i < _pendingPeakNum; i++) {
                    _totalStep++;
                    [self.stepDelegate onNewStep: peakInfo andTotalStep: _totalStep];
                }
                _pendingPeakNum = 0;
            }
        } else {
            _pendingPeakNum = 1; // 放弃了
        }
    }
    
    _lastPeakUpTime = peakInfo.time;
}

- (void) reset {
    
    _totalStep = 0;
    
    _lastPeakPos = -1;
    _lastCountedPos = -1;
    
    _thresholdState = THRESHOLD_BETWEEN;
    _currentValue = 0;
}

@end
