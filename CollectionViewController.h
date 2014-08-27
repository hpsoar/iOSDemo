//
//  CollectionViewController.h
//  iOSDemo
//
//  Created by HuangPeng on 8/19/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UICollectionViewController

- (UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point;

@end

@interface CollectionViewControllerLayout : UICollectionViewFlowLayout

@end

@interface HATransitionLayout : UICollectionViewTransitionLayout

@property (nonatomic) UIOffset offset;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGSize itemSize;

@end