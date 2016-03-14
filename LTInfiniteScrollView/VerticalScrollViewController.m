//
//  VerticalScrollViewController.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 16/3/13.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "VerticalScrollViewController.h"
#import "LTInfiniteScrollView.h"

@interface VerticalScrollViewController ()<LTInfiniteScrollViewDelegate,LTInfiniteScrollViewDataSource>
@property (nonatomic,strong) LTInfiniteScrollView *scrollView;
@end

@implementation VerticalScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[LTInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height)];
    self.scrollView.verticalScroll = YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.maxScrollDistance = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView reloadDataWithInitialIndex:0];
}

# pragma mark - LTInfiniteScrollView dataSource
- (NSInteger)numberOfViews
{
    return 20;
}

- (NSInteger)numberOfVisibleViews
{
    return 3;
}

# pragma mark - LTInfiniteScrollView delegate
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
{
    if (view) {
        ((UILabel *)view).text = [NSString stringWithFormat:@"%ld", index];
        return view;
    }
    
    UILabel *aView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 20, CGRectGetHeight(self.view.bounds) / 3)];
    aView.backgroundColor = [UIColor blackColor];
    aView.backgroundColor = [UIColor darkGrayColor];
    aView.textColor = [UIColor whiteColor];
    aView.textAlignment = NSTextAlignmentCenter;
    aView.text = [NSString stringWithFormat:@"%ld", index];
    return aView;
}

- (void)updateView:(UIView *)view withProgress:(CGFloat)progress scrollDirection:(ScrollDirection)direction
{
    CGFloat scale = 1 - fabs(progress) * 0.15;
    view.transform = CGAffineTransformMakeScale(scale, scale);
}


@end
