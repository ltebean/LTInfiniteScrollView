//
//  LTInfiniteScrollView.h
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTInfiniteScrollViewDelegate <NSObject>
-(UIView*) viewAtIndex:(int)index reusingView:(UIView *)view;

@end


@interface LTInfiniteScrollView : UIView
@property(nonatomic,weak) id<LTInfiniteScrollViewDelegate> delegate;
-(void) reloadData;

@end
