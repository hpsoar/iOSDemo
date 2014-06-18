#import "AccelerometerFilter.h"
#import "MathUtils.h"

#pragma mark - 定义常量以及函数
#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0


#pragma mark - 定义Base Filter
//
// 低通滤波器的实现算法, See http://en.wikipedia.org/wiki/Low-pass_filter for details low pass filtering
//
@implementation LowpassFilter {
    float _filterConstant;
    float _filterConstantMinus1;
    
    // 当前的可以输出的value
	float _x, _y, _z;
    
    float _norm;
    
    AvergageFilter* _averageFilter;
    
}

@synthesize x = _x, y = _y, z = _z, norm = _norm;


- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq {
	self = [super init];
	if(self) {
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		_filterConstant = dt / (dt + RC);
        _filterConstantMinus1 = 1 - _filterConstant;
        
        
        _averageFilter = [[AvergageFilter alloc] init];
	}
	return self;
}

- (void)addAcceleration:(CMAcceleration)accel {
	
	_x = accel.x * _filterConstant + _x * _filterConstantMinus1;
	_y = accel.y * _filterConstant + _y * _filterConstantMinus1;
	_z = accel.z * _filterConstant + _z * _filterConstantMinus1;
    
    _norm = sqrt(_x * _x + _y * _y + _z * _z);
    [_averageFilter addData: _norm];
    
    _norm -= [_averageFilter getAverage];
}

- (void) reset {
    _x = 0;
    _y = 0;
    _z = 0;
    
    [_averageFilter reset];
}
@end

#define kBufferSize0 30
#define kBufferSize1 300

@implementation AvergageFilter {
    double _buffer[kBufferSize0]; // 一秒的采样时间
    int _bufferIdx;
    int _size;
    double _accumulator;
    
    double _buffer1[kBufferSize1]; // 10秒
    int _bufferIdx1;
    int _size1;
    double _accumulator1;
}

- (id) init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void) reset {
    _bufferIdx = 0;
    _size = 0;
    _accumulator = 0;
    
    
    _bufferIdx1 = 0;
    _size1 = 0;
    _accumulator1 = 0;
}

- (void) addData: (double) value {
    _bufferIdx++;
    if (_bufferIdx >= kBufferSize0) {
        _bufferIdx = 0;
    }
    
    // 如果已经满了，则需要退出之前的数据
    if (_size >= kBufferSize0) {
        _accumulator -= _buffer[_bufferIdx];
    } else {
        _size++;
    }
    _accumulator += value;
    
    _buffer[_bufferIdx] = value;
    
    
    // 处理第二个Buffer
    _bufferIdx1++;
    if (_bufferIdx1 >= kBufferSize1) {
        _bufferIdx1 = 0;
    }
    
    // 如果已经满了，则需要退出之前的数据
    if (_size1 >= kBufferSize1) {
        _accumulator1 -= _buffer1[_bufferIdx1];
    } else {
        _size1++;
    }
    _accumulator1 += value;
    
    _buffer1[_bufferIdx1] = value;
}


- (double) getAverage {
    if (_size == 0) {
        return 0;
    } else {
        // 波峰出现之后一定会回落，经常出现负的加速度(除非刻意为之)
        double avg0 = _accumulator / _size;
        double avg1 = _accumulator1 / _size1;
        
        double result = MAX(avg0, avg1);
        return MAX(result, 0);
    }
}

@end

