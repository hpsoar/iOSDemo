//
//  MathUtils.h
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-9.
//
//

#import <Foundation/Foundation.h>

// 计算x, y, z的norm
inline static double Norm(double x, double y, double z) {
	return sqrt(x * x + y * y + z * z);
}

//
// 将输入v限定在范围[min, max]之间
//
inline static double Clamp(double v, double min, double max) {
	if(v > max) {
		return max;
    } else if(v < min) {
		return min;
    } else {
		return v;
    }
}

NSString* getNowMinutesString();

