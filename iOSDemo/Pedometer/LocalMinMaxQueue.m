//
//  LocalMinMaxQueue.m
//  AccelerometerGraph
//
//  Created by Fei Wang on 14-1-19.
//
//

#import "LocalMinMaxQueue.h"

static NSNull* kNullPlaceHolder = nil;

@implementation LocalMinMaxQueue {
    
    NSMutableArray* _buffer;
    NSInteger _bufferSize;
    NSInteger _bufferSizeHalf;
    NSInteger _bufferIndex;                 // 下一个可以使用的位置
    
    
    NSMutableArray* _minPriorityQueue;
    NSMutableArray* _maxPriorityQueue;
    NSInteger _queueSize;                   // 队列中的元素的个数
    
}

- (id) initWithSize: (NSInteger) size {
    self = [super init];
    
    if (self) {
        _bufferIndex = 0;
        _bufferSize = size;
        _bufferSizeHalf = size >> 1;
        
        _buffer = [[NSMutableArray alloc] initWithCapacity: size];
        for (int i = 0; i < size; i++) {
            LocalMinMaxItem* item = [[LocalMinMaxItem alloc] init];
            
            item.bufferIndex = i;
            
            [_buffer addObject: item];
        }
        
        if (!kNullPlaceHolder) {
            kNullPlaceHolder = [NSNull null];
        }
        
        
        _queueSize = 0;
        _minPriorityQueue = [[NSMutableArray alloc] initWithCapacity: size];
        _maxPriorityQueue = [[NSMutableArray alloc] initWithCapacity: size];
        for (int i = 0; i < size; i++) {
            [_minPriorityQueue addObject: kNullPlaceHolder];
            [_maxPriorityQueue addObject: kNullPlaceHolder];
        }
    }
    
    return self;
}


- (LocalMinMaxItem*) getLocalMinItem {
    if (_queueSize == 0) {
        return nil;
    } else {
        return _minPriorityQueue[0];
    }
}

- (LocalMinMaxItem*) getLocalMaxItem {
    if (_queueSize == 0) {
        return nil;
    } else {
        return _maxPriorityQueue[0];
    }
}

- (void) addNorm: (CGFloat) value andTime: (NSTimeInterval) time {
    // 将元素添加到队列中
    LocalMinMaxItem* item = _buffer[_bufferIndex];

    item.value = value;
    item.time = time;
    
    // 检查item是否在优先级队列中
    
    if (_queueSize < _bufferSize) {

        // 直接将新的元素添加到队列的末尾
        item.minIndex = _queueSize;
        item.maxIndex = _queueSize;
        _queueSize++;
        
        // 调整队列
        [self minPriorityQueueShiftUp: item];
        [self maxPriorityQueueshiftUp: item];
    } else {
        
        // 更新数据(并且调整堆)
        // 这个时候元素已经在堆中了
        [self minPriorityQueueShiftUp: item];
        [self minPriorityQueueShiftDown: item];
        
        
        [self maxPriorityQueueshiftUp: item];
        [self maxPriorityQueueshiftDown: item];

        
    }
    
    // 调整_bufferIndex的位置
    _bufferIndex++;
    if (_bufferIndex >= _bufferSize) {
        _bufferIndex = 0;
    }
    
}

// PARENT:
// i --> (i - 1) / 2
// 例如:
// 1, 2 --> 0
// 3, 4 --> 1
//
// 最小优先级队列中的元素 往上调整(堆的前面)
//
- (void) minPriorityQueueShiftUp: (LocalMinMaxItem*) item {
    // item对应queue的位置一直都是一个hole

    
    while(item.minIndex >= 1) {
        NSInteger parentIdx = (item.minIndex - 1) >> 1;
        LocalMinMaxItem* parent = _minPriorityQueue[parentIdx];
        
        if (item.value < parent.value) {
            // 交换位置
            _minPriorityQueue[item.minIndex] = parent;
            parent.minIndex = item.minIndex;
            
            item.minIndex = parentIdx;
        } else {
            break;
        }
    }
    
    _minPriorityQueue[item.minIndex] = item;
}

- (void) maxPriorityQueueshiftUp: (LocalMinMaxItem*) item {

    while(item.maxIndex >= 1) {
        NSInteger parentIdx = (item.maxIndex - 1) >> 1;
        LocalMinMaxItem* parent = _maxPriorityQueue[parentIdx];
        
        if (item.value > parent.value) {
            _maxPriorityQueue[item.maxIndex] = parent;
            parent.maxIndex = item.maxIndex;
            
            item.maxIndex = parentIdx;
        } else {
            break;
        }
    }
    
    _maxPriorityQueue[item.maxIndex] = item;
}

//
// item可能比它的两个child大，需要往下调整
//
- (void) minPriorityQueueShiftDown: (LocalMinMaxItem*) item {
    // CHILD:
    // i,  2 * i + 1, 2 * i + 2
    NSInteger leftIdx;
    
    while((leftIdx = (item.minIndex * 2 + 1)) < _queueSize) {
        NSInteger minIdx = item.minIndex;
        CGFloat minValue = item.value;
        
        // 左边Child
        LocalMinMaxItem* leftChild = _minPriorityQueue[leftIdx];
        if (leftChild.value < minValue) {
            minIdx = leftIdx;
            minValue = leftChild.value;
        }
        
        // 右边的Child
        if (leftIdx + 1 < _queueSize) {
            LocalMinMaxItem* rightChild = _minPriorityQueue[leftIdx + 1];
            if (rightChild.value < minValue) {
                minIdx = leftIdx + 1;
            }
        }
        
        if (minIdx != item.minIndex) {
            // 交换:
            LocalMinMaxItem* child = _minPriorityQueue[minIdx];
            _minPriorityQueue[item.minIndex] = child;
            child.minIndex = item.minIndex;
            
            item.minIndex = minIdx;
        } else {
            break;
        }
    }
    
    _minPriorityQueue[item.minIndex] = item;
    
}

- (void) maxPriorityQueueshiftDown: (LocalMinMaxItem*) item {
    // CHILD:
    // i,  2 * i + 1, 2 * i + 2
    NSInteger leftIdx;
    
    while((leftIdx = (item.maxIndex * 2 + 1)) < _queueSize) {
        NSInteger maxIdx = item.maxIndex;
        CGFloat maxValue = item.value;
        
        // 左边Child
        LocalMinMaxItem* leftChild = _maxPriorityQueue[leftIdx];
        if (leftChild.value > maxValue) {
            maxIdx = leftIdx;
            maxValue = leftChild.value;
        }
        
        // 右边的Child
        if (leftIdx + 1 < _queueSize) {
            LocalMinMaxItem* rightChild = _maxPriorityQueue[leftIdx + 1];
            if (rightChild.value > maxValue) {
                maxIdx = leftIdx + 1;
            }
        }
        
        if (maxIdx != item.maxIndex) {
            // 交换:
            LocalMinMaxItem* child = _maxPriorityQueue[maxIdx];
            _minPriorityQueue[item.maxIndex] = child;
            child.maxIndex = item.maxIndex;
            
            item.maxIndex = maxIdx;
        } else {
            break;
        }
    }
    
    _maxPriorityQueue[item.maxIndex] = item;
}

//
// 当前的队列是否已经满了
//
- (BOOL) isFull {
    return _bufferSize == _queueSize;
}

//
// 当前的队列的中心的数据
//
- (LocalMinMaxItem*) getCenterItem {
    if ([self isFull]) {
        NSInteger center = _bufferIndex - _bufferSizeHalf;
        if (center < 0) {
            center += _bufferSize;
        }
        return _buffer[center];
    } else {
        return nil;
    }
}

//
// 当前的队列的中心是否为波峰或波谷
//
- (PeakType) centerPeakType {
    // Center的定义
    if ([self isFull]) {
        NSInteger center = _bufferIndex - _bufferSizeHalf;
        if (center < 0) {
            center += _bufferSize;
        }
        
        LocalMinMaxItem* maxItem = [self getLocalMaxItem];
        LocalMinMaxItem* minItem = [self getLocalMinItem];
        if (maxItem.bufferIndex == center) {
            return PEAK_TYPE_UP;
        } else if (minItem.bufferIndex == center) {
            return PEAK_TYPE_DOWN;
        }
        
    }
    return PEAK_TYPE_NONE;
}


@end



@implementation LocalMinMaxItem

- (void) reset {
    _minIndex = -1;
    _maxIndex = -1;
}


@end