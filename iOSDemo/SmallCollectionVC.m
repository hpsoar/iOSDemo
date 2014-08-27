//
//  SmallCollectionVC.m
//  iOSDemo
//
//  Created by HuangPeng on 8/19/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "SmallCollectionVC.h"
#import "CollectionViewController.h"

@interface SmallCollectionVC ()

@property (nonatomic, assign) NSInteger slide;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *reflected;
@property (nonatomic, strong) NSArray *galleryImages;

@end


@implementation SmallCollectionVC

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [self nextViewControllerAtPoint:CGPointZero];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionViewController *)nextViewControllerAtPoint:(CGPoint)point {
    // We could have multiple section stacks and find the right one,
    CollectionViewControllerLayout *largeLayout = [[CollectionViewControllerLayout alloc] init];
    CollectionViewController *nextCollectionViewController = [[CollectionViewController alloc] initWithCollectionViewLayout:largeLayout];
    
    nextCollectionViewController.useLayoutToLayoutNavigationTransitions = YES;
    return nextCollectionViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Change slider
- (void)changeSlide {
    //    if (_fullscreen == NO && _transitioning == NO) {
    if(_slide > _galleryImages.count-1) _slide = 0;
    
    UIImage *toImage = [UIImage imageNamed:_galleryImages[_slide]];
    [UIView transitionWithView:_mainView
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                    animations:^{
                        _topImage.image = toImage;
                        _reflected.image = toImage;
                    } completion:nil];
    _slide++;
    //    }
}

@end

@implementation SmallCollectionVCLayout

- (id)init {
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(300, 440);
    self.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return NO;
}

@end