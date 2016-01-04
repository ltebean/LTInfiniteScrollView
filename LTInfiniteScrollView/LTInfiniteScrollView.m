//
//  LTInfiniteScrollView.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//



#import "LTInfiniteScrollView.h"

@interface LTInfiniteScrollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) CGSize viewSize;
@property (nonatomic) NSInteger visibleViewCount;
@property (nonatomic) NSInteger totalViewCount;
@property (nonatomic) CGFloat preContentOffsetX;
@property (nonatomic) CGFloat totalWidth;
@property (nonatomic) ScrollDirection scrollDirection;
@property (nonatomic, strong) NSMutableDictionary *views;
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

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    self.scrollView.bounces = bounces;
}

- (void)reloadDataWithInitialIndex:(NSInteger)initialIndex
{
    for (UIView *view in [self allViews]) {
        [view removeFromSuperview];
    }
    
    self.visibleViewCount = [self.dataSource numberOfVisibleViews];
    self.totalViewCount = [self.dataSource numberOfViews];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds) / self.visibleViewCount;
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.viewSize = CGSizeMake(viewWidth, viewHeight);
    
    
    if (self.totalViewCount % 2 == 1) {
        self.totalWidth = viewWidth * self.totalViewCount;
        self.scrollView.contentSize = CGSizeMake(self.totalWidth, CGRectGetHeight(self.bounds));
    } else {
        self.totalWidth = viewWidth * (self.totalViewCount + 1);
        self.scrollView.contentSize = CGSizeMake(self.totalWidth - viewWidth, CGRectGetHeight(self.bounds));
    }
    
    self.views = [NSMutableDictionary dictionary];

    _currentIndex = initialIndex;
    self.scrollView.contentOffset = [self contentOffsetForIndex:_currentIndex];
    [self reArrangeViews];
    [self updateProgress];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < _currentIndex) {
        self.scrollDirection = ScrollDirectionRight;
    } else {
        self.scrollDirection = ScrollDirectionLeft;
    }
    [self.scrollView setContentOffset:[self contentOffsetForIndex:index] animated:animated];
}

- (UIView *)viewAtIndex:(NSInteger)index
{
    return self.views[@(index)];
}

- (NSArray *)allViews
{
    return [self.views allValues];
}

#pragma mark - private methods

- (void)reArrangeViews
{
    NSMutableSet *indexesNeeded = [NSMutableSet set];
    NSInteger begin = _currentIndex -ceil(self.visibleViewCount / 2.0f);
    NSInteger end = _currentIndex + ceil(self.visibleViewCount / 2.0f);
    
    for (NSInteger i = begin; i <= end; i++) {
        if (i * 2 >= self.totalViewCount || i * 2 < -self.totalViewCount) {
            continue;
        }
        [indexesNeeded addObject: @(i)];
    }
    for (NSNumber *indexNeeded in indexesNeeded) {
        UIView *view = self.views[indexNeeded];
        if (view) {
            continue;
        }
        // find view to reuse
        for (NSNumber *index in [self allViews]) {
            if (![indexesNeeded containsObject:index]) {
                view = self.views[index];
                [self.views removeObjectForKey:index];
                break;
            }
        }
        view = [self.dataSource viewAtIndex:indexNeeded.integerValue reusingView:view];
        [view removeFromSuperview];
        view.tag = indexNeeded.integerValue;
        view.center = [self centerForViewAtIndex:indexNeeded.integerValue];
        self.views[indexNeeded] = view;
        [self.scrollView addSubview:view];
    }
}

- (void)updateProgress
{
    CGFloat currentCenter = [self currentCenter].x;
    for (UIView *view in [self allViews]) {
        CGFloat progress = (view.center.x - currentCenter) / CGRectGetWidth(self.bounds) * self.visibleViewCount;
        [self.delegate updateView:view withProgress:progress scrollDirection:self.scrollDirection];
    }
}

# pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentCenter = [self currentCenter].x;
    CGFloat offset = currentCenter - self.totalWidth / 2;
    _currentIndex = ceil((offset- self.viewSize.width / 2) / self.viewSize.width);

    if (self.scrollView.contentOffset.x > self.preContentOffsetX) {
        self.scrollDirection = ScrollDirectionLeft;
    } else {
        self.scrollDirection = ScrollDirectionRight;
    }
    self.preContentOffsetX = self.scrollView.contentOffset.x;
    
    [self reArrangeViews];
    [self updateProgress];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.pagingEnabled && !decelerate && self.needsCenterPage) {
        CGFloat offsetX = scrollView.contentOffset.x;
        if (offsetX < 0 || offsetX > scrollView.contentSize.width) {
            return;
        }
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.pagingEnabled && self.needsCenterPage) {
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.maxScrollDistance <= 0) {
        return;
    }
    if (![self needsCenterPage]) {
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

- (BOOL)needsCenterPage
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX < 0 || offsetX > self.scrollView.contentSize.width - self.viewSize.width) {
        return NO;
    } else {
        return YES;
    }
}

- (CGPoint)currentCenter
{
    CGFloat x = self.scrollView.contentOffset.x + CGRectGetWidth(self.bounds) / 2.0f;
    CGFloat y = self.scrollView.contentOffset.y;
    return  CGPointMake(x, y);
}

- (CGPoint)contentOffsetForIndex:(NSInteger)index
{
    CGFloat x = self.totalWidth / 2 + index * self.viewSize.width - CGRectGetWidth(self.bounds) / 2;
    return CGPointMake(x, 0);
}

- (CGPoint)centerForViewAtIndex:(NSInteger)index
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat x = self.totalWidth / 2 + index * self.viewSize.width;
    return CGPointMake(x, y);
}

- (BOOL)viewCanBeQueuedForReuse:(UIView *)view
{
    CGFloat distanceToCenter = [self currentCenter].x - view.center.x;
    CGFloat threshold = (ceil(self.visibleViewCount / 2.0f)) * self.viewSize.width + self.viewSize.width / 2.0f;
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
