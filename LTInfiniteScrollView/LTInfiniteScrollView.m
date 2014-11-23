//
//  LTInfiniteScrollView.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//
typedef enum ScrollDirection {
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

#define contentWidth 1000000000

#import "LTInfiniteScrollView.h"

@interface LTInfiniteScrollView()<UIScrollViewDelegate>
@property CGSize viewSize;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableArray* views;
@property(nonatomic) int visibleViewCount;
@property(nonatomic) CGFloat preContentOffsetX;
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
    self.visibleViewCount = 5;

    CGFloat viewWidth = CGRectGetWidth(self.bounds)/self.visibleViewCount;
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.viewSize = CGSizeMake(viewWidth, viewHeight);
    
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
    
    self.views = [NSMutableArray array];

    int begin = -ceil(self.visibleViewCount/2.0f);
    int end = ceil(self.visibleViewCount/2.0f);
    self.currentIndex = 0;
    
    for(int i = begin; i<=end;i++){
        UIView* view = [self.delegate viewAtIndex:i reusingView:nil];
        view.center = [self centerForViewAtIndex:i];
        view.tag = i;
        [self.views addObject:view];
        NSLog(@"%@",NSStringFromCGRect(view.frame));
        
        [self.scrollView addSubview:view];
        [self updateView:view atPercent:0 withIndexDiff:(i-self.currentIndex)];
    }
}

-(CGPoint) centerForViewAtIndex:(int) index
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat x = contentWidth/2 + index*self.viewSize.width;
//    NSLog(@"view center:%f at index:%d",x,index);
    return CGPointMake(x, y);
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = [self currentCenter].x - contentWidth/2 ;
    self.currentIndex = ceil((offset- self.viewSize.width/2)/self.viewSize.width);
    
    //NSLog(@"offset:%f ",offset);

    NSLog(@"--------------------------------");
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
            

            //NSLog(@"offset:%f indexNeeded:%d",offset, indexNeeded);
            [view removeFromSuperview];

            UIView* viewNeeded = [self.delegate viewAtIndex:indexNeeded reusingView:view];
            viewNeeded.center = [self centerForViewAtIndex:indexNeeded];
           // NSLog(@"view frame:%@",NSStringFromCGRect(viewNeeded.frame));
            [self.scrollView addSubview:viewNeeded];
            viewNeeded.tag = indexNeeded;
            
            
            
        };
        CGFloat currentCenter = [self currentCenter].x;
        CGFloat percent = (view.center.x - currentCenter) / self.viewSize.width;
        [self updateView:view atPercent:percent withIndexDiff:((int)view.tag - self.currentIndex)];


    }
    if(self.dragging){
        if(self.scrollView.contentOffset.x > self.preContentOffsetX){
            self.scrollDirection = ScrollDirectionLeft;
        }else{
            self.scrollDirection = ScrollDirectionRight;
        }
    }
    
    self.preContentOffsetX = self.scrollView.contentOffset.x;



    
   // NSLog(@"%f %d",offset, self.currentIndex);
}

-(void) updateView:(UIView*) view atPercent:(CGFloat)percent withIndexDiff:(int)diff
{

    if(view.tag == 2){
        NSLog(@"%f,%d",percent,diff);
    }
    
    CATransform3D transform = CATransform3DIdentity;
    
    // scale
    CGFloat angle =  180.0f * M_PI / 180.0f*percent;
    CGFloat scale = 1.6 - 0.3*fabs(percent);
    transform = CATransform3DScale(transform, scale, scale, scale);
    
    // translate
    CGFloat translate = 16 * percent;
    transform = CATransform3DTranslate(transform,translate, 0, 0);
    
    
    if( fabs(percent)<1){
        if(percent>0){
            percent = MAX(1,percent);
        }else{
            percent = MIN(-1,percent);
        }
        transform.m34 = 1.0/-600;
        transform = CATransform3DRotate(transform, angle , 0.0f, 1.0f, 0.0f);
    }

    // rotate
   
    view.layer.transform = transform;
    

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

    // swipe left
    if(self.scrollDirection == ScrollDirectionLeft){
//        NSLog(@"left");
        if(distanceToCenter <0){
            return NO;
        }
    }else{
//        NSLog(@"right");

        if(distanceToCenter >0){
            return NO;
        }
    }
    if(fabs(distanceToCenter)> threshold){
        NSLog(@"%f, %d",distanceToCenter,view.tag);

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
    CGFloat x = contentWidth/2 + index*self.viewSize.width - CGRectGetWidth(self.bounds)/2;

    return CGPointMake(x, 0);
}




@end
