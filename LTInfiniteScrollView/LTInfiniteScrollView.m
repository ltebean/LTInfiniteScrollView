//
//  LTInfiniteScrollView.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//



#import "LTInfiniteScrollView.h"

@interface LTInfiniteScrollView()<UIScrollViewDelegate>
@property (nonatomic) CGSize viewSize;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic) NSInteger visibleViewCount;
@property (nonatomic) NSInteger totalViewCount;
@property (nonatomic) CGFloat preContentOffsetX;
@property (nonatomic) CGFloat totalWidth;
@property (nonatomic) BOOL dragging;
@property (nonatomic) ScrollDirection scrollDirection;
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = self.pagingEnabled;
    [self addSubview:self.scrollView];
}

#pragma mark - public methods

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    self.scrollView.pagingEnabled = pagingEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.scrollView.scrollEnabled = scrollEnabled;
}

- (void)reloadData
{

    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    
    self.visibleViewCount = [self.dataSource numberOfVisibleViews];
    self.totalViewCount = [self.dataSource numberOfViews];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds)/self.visibleViewCount;
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.viewSize = CGSizeMake(viewWidth, viewHeight);
    
    self.totalWidth = viewWidth * self.totalViewCount;
    
    self.scrollView.contentSize = CGSizeMake(self.totalWidth, CGRectGetHeight(self.bounds));
    
    self.views = [NSMutableArray array];
    
    int begin = -ceil(self.visibleViewCount / 2.0f);
    int end = ceil(self.visibleViewCount / 2.0f);
    _currentIndex = 0;
    
    self.scrollView.contentOffset = CGPointMake(self.totalWidth / 2-CGRectGetWidth(self.bounds) / 2, 0);
    
    CGFloat currentCenter = [self currentCenter].x;
    
    for (int i = begin; i<= end;i++) {
        UIView *view = [self.dataSource viewAtIndex:i reusingView:nil];
        view.center = [self centerForViewAtIndex:i];
        view.tag = i;
        [self.views addObject:view];
        [self.scrollView addSubview:view];
        [self.delegate updateView:view withDistanceToCenter:(view.center.x - currentCenter) scrollDirection:self.scrollDirection];
    }
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    self.dragging = YES;
    [self.scrollView setContentOffset:[self contentOffsetForIndex:index] animated:animated];
}

- (UIView *)viewAtIndex:(NSInteger)index
{
    CGPoint center = [self centerForViewAtIndex:index];
    for (UIView *view in self.views) {
        if (fabs(center.x - view.center.x) <= self.viewSize.width / 2.0f) {
            return view;
        }
    }
    return nil;
}

- (NSArray *)allViews
{
    return self.views;
}

# pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = [self currentCenter].x - self.totalWidth / 2;
    _currentIndex = ceil((offset- self.viewSize.width / 2) / self.viewSize.width);
    
    //    NSLog(@"--------------------------------");
    for (UIView *view in self.views) {
        if ([self viewCanBeQueuedForReuse:view]) {
            NSInteger indexNeeded;
            NSInteger indexOfViewToReuse = (NSInteger)view.tag;
            if (indexOfViewToReuse < self.currentIndex) {
                indexNeeded = indexOfViewToReuse + self.visibleViewCount + 2;
            } else {
                indexNeeded = indexOfViewToReuse - (self.visibleViewCount + 2);
            }
            
            if (fabs(indexNeeded) <= floorf(self.totalViewCount / 2)) {
                //NSLog(@"index:%d indexNeeded:%d",indexOfViewToReuse,indexNeeded);
                
                [view removeFromSuperview];
                
                UIView *viewNeeded = [self.dataSource viewAtIndex:indexNeeded reusingView:view];
                viewNeeded.center = [self centerForViewAtIndex:indexNeeded];
                [self.scrollView addSubview:viewNeeded];
                viewNeeded.tag = indexNeeded;
            }
        };
        
        CGFloat currentCenter = [self currentCenter].x;
        [self.delegate updateView:view withDistanceToCenter:(view.center.x - currentCenter) scrollDirection:self.scrollDirection];
        
    }
    if (self.scrollView.contentOffset.x > self.preContentOffsetX) {
        self.scrollDirection = ScrollDirectionLeft;
    } else {
        self.scrollDirection = ScrollDirectionRight;
    }
    self.preContentOffsetX = self.scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.dragging = NO;
    if (!self.pagingEnabled && !decelerate) {
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.pagingEnabled) {
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.maxScrollDistance <= 0) {
        return;
    }
    CGFloat targetX = targetContentOffset -> x;
    CGFloat currentX = [self contentOffsetForIndex:self.currentIndex].x;
    if (fabs(targetX - currentX) <= self.viewSize.width / 2) {
        return;
    } else {
        NSInteger distance = self.maxScrollDistance - 1;
        NSInteger currentIndex = [self currentIndex];
        NSInteger targetIndex = self.scrollDirection == ScrollDirectionLeft ? currentIndex + distance : currentIndex - distance;
        targetContentOffset -> x = [self contentOffsetForIndex:targetIndex].x;
    }
}

#pragma mark - helper methods

- (CGPoint)currentCenter
{
    CGFloat x = self.scrollView.contentOffset.x + CGRectGetWidth(self.bounds) / 2.0f;
    CGFloat y = self.scrollView.contentOffset.y;
    return  CGPointMake(x, y);
}

- (CGPoint)contentOffsetForIndex:(NSInteger)index
{
    CGFloat x = self.totalWidth / 2 + index*self.viewSize.width - CGRectGetWidth(self.bounds) / 2;
    return CGPointMake(x, 0);
}

- (CGPoint)centerForViewAtIndex:(NSInteger)index
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat x = self.totalWidth/2 + index * self.viewSize.width;
    return CGPointMake(x, y);
}

- (BOOL)viewCanBeQueuedForReuse:(UIView *)view
{
    CGFloat distanceToCenter = [self currentCenter].x - view.center.x;
    CGFloat threshold = (ceil(self.visibleViewCount/2.0f)) * self.viewSize.width + self.viewSize.width / 2.0f;
    if (self.scrollDirection == ScrollDirectionLeft) {
        if (distanceToCenter < 0){
            return NO;
        }
    } else {
        if (distanceToCenter > 0) {
            return NO;
        }
    }
    if (fabs(distanceToCenter) > threshold) {
        return YES;
    }
    return NO;
}
@end
