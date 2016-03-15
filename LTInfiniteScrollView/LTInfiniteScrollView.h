//
//  LTInfiniteScrollView.h
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ScrollDirection {
    ScrollDirectionNext,
    ScrollDirectionPrev,
} ScrollDirection;

@class LTInfiniteScrollView;

@protocol LTInfiniteScrollViewDelegate<NSObject>
@optional
- (void)updateView:(UIView *)view withProgress:(CGFloat)progress scrollDirection:(ScrollDirection)direction;
- (void)scrollView:(LTInfiniteScrollView *)scrollView didScrollToIndex:(NSInteger)index;
@end

@protocol LTInfiniteScrollViewDataSource<NSObject>
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
- (NSInteger)numberOfViews;
- (NSInteger)numberOfVisibleViews;
@end

@interface LTInfiniteScrollView: UIView
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, weak) id<LTInfiniteScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<LTInfiniteScrollViewDelegate> delegate;
@property (nonatomic) BOOL verticalScroll;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL pagingEnabled;
@property (nonatomic) BOOL bounces;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) NSInteger maxScrollDistance;

- (void)reloadDataWithInitialIndex:(NSInteger)initialIndex;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (UIView *)viewAtIndex:(NSInteger)index;
- (NSArray *)allViews;
@end
