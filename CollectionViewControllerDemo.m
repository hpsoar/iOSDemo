//
//  CollectionViewControllerDemo.m
//  iOSDemo
//
//  Created by HuangPeng on 8/19/14.
//  Copyright (c) 2014 HuangPeng. All rights reserved.
//

#import "CollectionViewControllerDemo.h"
#import "SmallCollectionVC.h"
#import "CollectionViewController.h"

@implementation CollectionViewControllerDemo {
    CollectionViewController *_collectionVC;
    SmallCollectionVCLayout *_smallLayout;
    CollectionViewControllerLayout *_normalLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _smallLayout = [SmallCollectionVCLayout new];
    _normalLayout = [CollectionViewControllerLayout new];
    
    _collectionVC = [[CollectionViewController alloc] initWithCollectionViewLayout:_smallLayout];
    
    [self addChildViewController:_collectionVC];
    
    [self.view addSubview:_collectionVC.view];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch" style:UIBarButtonItemStylePlain target:self action:@selector(switchLayout)];
}

- (void)switchLayout {
    if (_collectionVC.collectionView.collectionViewLayout == _smallLayout) {
        [_collectionVC.collectionView setCollectionViewLayout:_normalLayout animated:YES];
    }
    else {
        [_collectionVC.collectionView setCollectionViewLayout:_smallLayout animated:YES];
    }
}

@end
