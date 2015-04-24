//
//  LTInfiniteScrollView.h
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ScrollDirection {
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

@protocol LTInfiniteScrollViewDelegate <NSObject>
-(void)updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction;
@end

@protocol LTInfiniteScrollViewDataSource <NSObject>
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
- (NSInteger)numberOfViews;
- (NSInteger)numberOfVisibleViews;
@end

@interface LTInfiniteScrollView : UIView
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, weak) id<LTInfiniteScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<LTInfiniteScrollViewDelegate> delegate;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL pagingEnabled;
@property (nonatomic) NSInteger maxScrollDistance;

- (void)reloadData;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (UIView *)viewAtIndex:(NSInteger)index;
- (NSArray *)allViews;
@end
