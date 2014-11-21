//
//  LTInfiniteScrollView.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//


#define contentWidth 10000000

#import "LTInfiniteScrollView.h"

@interface LTInfiniteScrollView()<UIScrollViewDelegate>
@property CGSize viewSize;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableSet *reusableViews;
@property(nonatomic,strong) NSMutableArray* visibleViews;
@property(nonatomic) int visibleViewCount;
@property int currentIndex;
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
    self.visibleViewCount = 5;

    CGFloat viewWidth = CGRectGetWidth(self.bounds)/self.visibleViewCount;
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.viewSize = CGSizeMake(viewWidth, viewHeight);
    self.reusableViews = [NSMutableSet setWithCapacity:self.visibleViewCount+2];
    self.visibleViews = [NSMutableArray array];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [self addSubview: self.scrollView];
    self.scrollView.contentSize=CGSizeMake(contentWidth, CGRectGetHeight(self.bounds));
    self.scrollView.contentOffset = CGPointMake(contentWidth/2-CGRectGetWidth(self.bounds)/2, 0);
    
    NSLog(@"%@",NSStringFromCGPoint(self.scrollView.contentOffset));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    
}

-(void) reloadData
{
    NSLog(@"view:%@",NSStringFromCGRect(self.frame));
    
    int begin = -ceil(self.visibleViewCount/2.0f);
    int end = ceil(self.visibleViewCount/2.0f);
    for(int i = begin; i<=end;i++){
        UIView* view = [self.delegate viewAtIndex:i reusingView:nil];
        
        view.frame =CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
        view.center = [self centerForViewAtIndex:i];
        view.tag = i;
        [self.visibleViews addObject:view];
        NSLog(@"%@",NSStringFromCGRect(view.frame));
        
        [self.scrollView addSubview:view];
    }
}

-(CGPoint) centerForViewAtIndex:(int) index
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat x = contentWidth/2 + index*self.viewSize.width;
    return CGPointMake(x, y);
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = self.scrollView.contentOffset.x + CGRectGetWidth(self.bounds)/2 - contentWidth/2 ;
    self.currentIndex = ceil((offset- self.viewSize.width/2)/self.viewSize.width);
    
    //NSLog(@"offset:%f ",offset);
    
    if(offset == 0){
        return;
    }

    for (UIView* view in self.visibleViews) {
        if([self viewCanBeQueuedForReuse:view]){
            int indexNeeded;
            if(view.tag < self.currentIndex){
                indexNeeded = self.currentIndex + ceil(self.visibleViewCount/2.0f)+1;
            }else{
                indexNeeded = self.currentIndex - ceil(self.visibleViewCount/2.0f)-1;
            }
            if([self viewExistsAtIndex:indexNeeded]){
                continue;
            }
            NSLog(@"index:%d indexNeeded:%d",view.tag,indexNeeded);
            
            view.tag = indexNeeded;


            //NSLog(@"offset:%f indexNeeded:%d",offset, indexNeeded);
            [view removeFromSuperview];

            UIView* viewNeeded = [self.delegate viewAtIndex:indexNeeded reusingView:view];

            viewNeeded.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
            viewNeeded.center = [self centerForViewAtIndex:indexNeeded];
           // NSLog(@"view frame:%@",NSStringFromCGRect(viewNeeded.frame));
            [self.scrollView addSubview:viewNeeded];
        };
    }
    
   // NSLog(@"%f %d",offset, self.currentIndex);
}

-(BOOL) viewExistsAtIndex:(int) index
{
    for (UIView* view in self.visibleViews) {
        if(view.tag ==index){
            return YES;
        }
    }
    return NO;
}

-(BOOL) viewCanBeQueuedForReuse:(UIView*) view
{
    CGFloat offset = self.scrollView.contentOffset.x + CGRectGetWidth(self.bounds)/2 - view.center.x;
    CGFloat threshold = (self.visibleViewCount/2+1)*self.viewSize.width;


    if(fabs(offset)> threshold){
//        NSLog(@"%f, %d",threshold,view.tag);

        return YES;
    }
    return NO;
    
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];

}
-(CGPoint) contentOffsetForIndex:(int) index
{
    CGFloat x = contentWidth/2 + index*self.viewSize.width - CGRectGetWidth(self.bounds)/2;

    return CGPointMake(x, 0);
}




@end
