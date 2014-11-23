//
//  LTInfiniteScrollView.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//



#import "LTInfiniteScrollView.h"

@interface LTInfiniteScrollView()<UIScrollViewDelegate>
@property CGSize viewSize;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableArray* views;
@property(nonatomic) int visibleViewCount;
@property(nonatomic) int totalViewCount;
@property(nonatomic) CGFloat preContentOffsetX;
@property(nonatomic) CGFloat totalWidth;
@property int currentIndex;
@property BOOL dragging;
@property ScrollDirection scrollDirection;
@end


@implementation LTInfiniteScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview: self.scrollView];
}

-(void) reloadData
{
    
    for(UIView* view in self.views){
        [view removeFromSuperview];
    }
    
    self.visibleViewCount = [self.dataSource visibleViewCount];
    self.totalViewCount = [self.dataSource totalViewCount];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds)/self.visibleViewCount;
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.viewSize = CGSizeMake(viewWidth, viewHeight);

    self.totalWidth = viewWidth*self.totalViewCount;
    
    self.scrollView.contentSize=CGSizeMake(self.totalWidth, CGRectGetHeight(self.bounds));
   
    self.views = [NSMutableArray array];

    int begin = -ceil(self.visibleViewCount/2.0f);
    int end = ceil(self.visibleViewCount/2.0f);
    self.currentIndex = 0;
    
    for(int i = begin; i<=end;i++){
        UIView* view = [self.dataSource viewAtIndex:i reusingView:nil];
        view.center = [self centerForViewAtIndex:i];
        view.tag = i;
        [self.views addObject:view];
        
        [self.scrollView addSubview:view];
        [self.delegate updateView:view atPercent:0 withScrollDirection:ScrollDirectionLeft];
    }
    self.scrollView.contentOffset = CGPointMake(self.totalWidth/2-CGRectGetWidth(self.bounds)/2, 0);

}

-(CGPoint) centerForViewAtIndex:(int) index
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat x = self.totalWidth/2 + index*self.viewSize.width;
//    NSLog(@"view center:%f at index:%d",x,index);
    return CGPointMake(x, y);
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = [self currentCenter].x - self.totalWidth/2 ;
    self.currentIndex = ceil((offset- self.viewSize.width/2)/self.viewSize.width);
    
//    NSLog(@"--------------------------------");
    for (UIView* view in self.views) {
        if([self viewCanBeQueuedForReuse:view]){
            int indexNeeded;
            int indexOfViewToReuse = (int)view.tag;
            if(indexOfViewToReuse < self.currentIndex){
                indexNeeded = indexOfViewToReuse + self.visibleViewCount + 2;
            }else{
                indexNeeded = indexOfViewToReuse - (self.visibleViewCount + 2);
            }

            //NSLog(@"index:%d indexNeeded:%d",indexOfViewToReuse,indexNeeded);
            
            [view removeFromSuperview];

            UIView* viewNeeded = [self.dataSource viewAtIndex:indexNeeded reusingView:view];
            viewNeeded.center = [self centerForViewAtIndex:indexNeeded];
            [self.scrollView addSubview:viewNeeded];
            viewNeeded.tag = indexNeeded;
        };
        
        CGFloat currentCenter = [self currentCenter].x;
        CGFloat percent = (view.center.x - currentCenter) / self.viewSize.width;
        [self.delegate updateView:view atPercent:percent withScrollDirection:self.scrollDirection];

    }
    if(self.dragging){
        if(self.scrollView.contentOffset.x > self.preContentOffsetX){
            self.scrollDirection = ScrollDirectionLeft;
        }else{
            self.scrollDirection = ScrollDirectionRight;
        }
    }
    
    self.preContentOffsetX = self.scrollView.contentOffset.x;
}


-(CGPoint) currentCenter
{
    CGFloat x = self.scrollView.contentOffset.x + CGRectGetWidth(self.bounds)/2.0f;
    CGFloat y = self.scrollView.contentOffset.y;
    return  CGPointMake(x, y);
}

-(BOOL) viewCanBeQueuedForReuse:(UIView*) view
{
    
    CGFloat distanceToCenter = [self currentCenter].x - view.center.x;
    CGFloat threshold = (ceil(self.visibleViewCount/2.0f))*self.viewSize.width + self.viewSize.width/2.0f;

    if(self.scrollDirection == ScrollDirectionLeft){
        if(distanceToCenter <0){
            return NO;
        }
    }else{
        if(distanceToCenter >0){
            return NO;
        }
    }
    if(fabs(distanceToCenter)> threshold){
        return YES;
    }
    return NO;
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.dragging = NO;
    [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];

}

-(CGPoint) contentOffsetForIndex:(int) index
{
    CGFloat x = self.totalWidth/2 + index*self.viewSize.width - CGRectGetWidth(self.bounds)/2;

    return CGPointMake(x, 0);
}

@end
