//
//  MathUtils.m
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-9.
//
//

#import "MathUtils.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* getNowMinutesString() {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_HHmm";
    return [formatter stringFromDate:[NSDate date]];
}
