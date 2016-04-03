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
@property (nonatomic) CGFloat viewSize;
@property (nonatomic) NSInteger visibleViewCount;
@property (nonatomic) NSInteger totalViewCount;
@property (nonatomic) CGFloat previousPosition;
@property (nonatomic) CGFloat totalSize;
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

- (CGFloat)scrollViewSize
{
    return self.verticalScroll ? self.bounds.size.height : self.bounds.size.width;
}

- (CGFloat)scrollViewContentSize
{
    CGSize size = self.scrollView.contentSize;
    return self.verticalScroll ? size.height : size.width;
}

- (CGFloat)scrollPosition
{
    CGPoint position = self.scrollView.contentOffset;
    return self.verticalScroll ? position.y : position.x;
}

- (void)setup
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = self.pagingEnabled;
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    NSInteger index = self.currentIndex;
    [self updateSize];
    if (self.views.count == 0) {
        return;
    }
    for (UIView *view in self.views.allValues) {
        view.center = [self centerForViewAtIndex:view.tag];
    }
    [self scrollToIndex:index animated:NO];
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

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    self.scrollView.contentInset = contentInset;
}

- (void)reloadDataWithInitialIndex:(NSInteger)initialIndex
{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    self.views = [NSMutableDictionary dictionary];

    self.visibleViewCount = [self.dataSource numberOfVisibleViews];
    self.totalViewCount = [self.dataSource numberOfViews];
    
    [self updateSize];
    _currentIndex = initialIndex;
    self.scrollView.contentOffset = [self contentOffsetForIndex:_currentIndex];
    [self reArrangeViews];
    [self updateProgress];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < _currentIndex) {
        self.scrollDirection = ScrollDirectionPrev;
    } else {
        self.scrollDirection = ScrollDirectionNext;
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

- (void)updateSize
{
    self.viewSize = self.scrollViewSize / self.visibleViewCount;;
    self.totalSize = self.viewSize * self.totalViewCount;
    if (self.verticalScroll) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), self.totalSize);
    } else {
        self.scrollView.contentSize = CGSizeMake(self.totalSize, CGRectGetHeight(self.bounds));
    }
}

- (void)reArrangeViews
{
    NSMutableSet *indexesNeeded = [NSMutableSet set];
    NSInteger begin = _currentIndex -ceil(self.visibleViewCount / 2.0f);
    NSInteger end = _currentIndex + ceil(self.visibleViewCount / 2.0f);
    
    for (NSInteger i = begin; i <= end; i++) {
        if (i < 0 ) {
            NSInteger index = end - i;
            if (index < self.totalViewCount) {
                [indexesNeeded addObject:@(index)];
            }
        }
        else if (i >= self.totalViewCount) {
            NSInteger index = begin - i;
            if (index >= 0) {
                [indexesNeeded addObject:@(index)];
            }
        }
        else {
            [indexesNeeded addObject:@(i)];
        }
    }
    for (NSNumber *indexNeeded in indexesNeeded) {
        UIView *view = self.views[indexNeeded];
        if (view) {
            continue;
        }
        // find view to reuse
        for (NSNumber *index in [self.views allKeys]) {
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
    if (![self.delegate respondsToSelector:@selector(updateView:withProgress:scrollDirection:)]) {
        return;
    }
    CGFloat center = [self currentCenter];
    NSArray *allViews = [self allViews];
    for (UIView *view in allViews) {
        CGFloat progress;
        if (self.verticalScroll) {
            progress = (view.center.y - center) / CGRectGetHeight(self.bounds) * self.visibleViewCount;
        } else {
            progress = (view.center.x - center) / CGRectGetWidth(self.bounds) * self.visibleViewCount;
        }
        [self.delegate updateView:view withProgress:progress scrollDirection:self.scrollDirection];
    }
}

- (void)didScrollToIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(scrollView:didScrollToIndex:)]) {
        [self.delegate scrollView:self didScrollToIndex:self.currentIndex];
    }
}

# pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentCenter = [self currentCenter];
    CGFloat offset = [self scrollPosition];
    
    _currentIndex = round((currentCenter - self.viewSize / 2) / self.viewSize);
    if (offset > self.previousPosition) {
        self.scrollDirection = ScrollDirectionNext;
    } else {
        self.scrollDirection = ScrollDirectionPrev;
    }
    self.previousPosition = offset;
    
    [self reArrangeViews];
    [self updateProgress];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.pagingEnabled && !decelerate && self.needsCenterPage) {
        CGFloat offset = [self scrollPosition];
        if (offset < 0 || offset > self.scrollViewContentSize) {
            return;
        }
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
        [self didScrollToIndex:self.currentIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.pagingEnabled && self.needsCenterPage) {
        [self.scrollView setContentOffset:[self contentOffsetForIndex:self.currentIndex] animated:YES];
    }
    [self didScrollToIndex:self.currentIndex];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.maxScrollDistance <= 0) {
        return;
    }
    if (![self needsCenterPage]) {
        return;
    }
    CGFloat target = self.verticalScroll ? targetContentOffset -> y : targetContentOffset -> x;
    CGPoint contentOffset = [self contentOffsetForIndex:self.currentIndex];
    CGFloat current = self.verticalScroll ? contentOffset.y : contentOffset.x;
    if (fabs(target - current) <= self.viewSize / 2) {
        return;
    } else {
        NSInteger distance = self.maxScrollDistance - 1;
        NSInteger currentIndex = [self currentIndex];
        NSInteger targetIndex = self.scrollDirection == ScrollDirectionNext ? currentIndex + distance : currentIndex - distance;
        CGPoint targetOffset = [self contentOffsetForIndex:targetIndex];
        if (self.verticalScroll) {
            targetContentOffset -> y = targetOffset.y;
        } else {
            targetContentOffset -> x = targetOffset.x;
        }
    }
}

#pragma mark - helper methods

- (BOOL)needsCenterPage
{
    CGFloat position = [self scrollPosition];
    if (position < 0 || position > self.scrollViewContentSize - self.viewSize) {
        return NO;
    } else {
        return YES;
    }
}

- (CGFloat)currentCenter
{
    return self.scrollPosition + self.scrollViewSize / 2.0f;
}

- (CGPoint)contentOffsetForIndex:(NSInteger)index
{
    CGPoint point = [self centerForViewAtIndex:index];
    
    CGFloat center = self.verticalScroll ? point.y : point.x;
    CGFloat position = center - self.scrollViewSize / 2.0f;
    position = MAX(0, position);
    position = MIN(position, self.scrollViewContentSize);
    if (self.verticalScroll) {
        return CGPointMake(0, position);
    } else {
        return CGPointMake(position, 0);
    }
}

- (CGPoint)centerForViewAtIndex:(NSInteger)index
{
    CGFloat position = index * self.viewSize + self.viewSize / 2;
    if (self.verticalScroll) {
        return CGPointMake(CGRectGetMidX(self.bounds), position);
    } else {
        return CGPointMake(position, CGRectGetMidY(self.bounds));
    }
}

@end
