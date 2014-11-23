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
-(void) updateView:(UIView*) view atPercent:(CGFloat)percent withScrollDirection:(ScrollDirection)direction;
@end

@protocol LTInfiniteScrollViewDataSource <NSObject>
-(UIView*) viewAtIndex:(int)index reusingView:(UIView *)view;
-(int) totalViewCount;
-(int) visibleViewCount;
@end


@interface LTInfiniteScrollView : UIView
@property(nonatomic,weak) id<LTInfiniteScrollViewDataSource> dataSource;
@property(nonatomic,weak) id<LTInfiniteScrollViewDelegate> delegate;
-(void) reloadData;

@end
