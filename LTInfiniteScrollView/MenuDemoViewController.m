//
//  MenuDemoViewController.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 15/3/29.
//  Copyright (c) 2015年 ltebean. All rights reserved.
//

#import "MenuDemoViewController.h"
#import "LTInfiniteScrollView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define NUMBER_OF_VISIBLE_VIEWS 5
#define ICON_VIEW_PADDING 5

@interface MenuDemoViewController()<LTInfiniteScrollViewDataSource, LTInfiniteScrollViewDelegate>
@property (weak, nonatomic) IBOutlet LTInfiniteScrollView *scrollView;
@end
@implementation MenuDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.userInteractionEnabled = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView reloadData];
}

- (IBAction)next:(id)sender {
    [self.scrollView scrollToIndex:self.scrollView.currentIndex + 1 animated:YES];
}

- (IBAction)pre:(id)sender {
    [self.scrollView scrollToIndex:self.scrollView.currentIndex - 1 animated:YES];
}

# pragma mark - LTInfiniteScrollView dataSource
- (NSInteger)numberOfViews
{
    return 999;
}

- (NSInteger)numberOfVisibleViews
{
    return NUMBER_OF_VISIBLE_VIEWS;
}

# pragma mark - LTInfiniteScrollView delegate
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
{
    if (!view) {
        view = [self newIconView];
    }
    return view;
}

- (UIView *)newIconView
{
    CGFloat width =  SCREEN_WIDTH/NUMBER_OF_VISIBLE_VIEWS - ICON_VIEW_PADDING * 2;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    CGFloat innerIconPadding = 5;
    CGFloat iconSize = width - innerIconPadding * 2;
    UIView *innerIcon = [[UIView alloc] initWithFrame:CGRectMake(innerIconPadding, innerIconPadding, iconSize, iconSize)];
    innerIcon.backgroundColor = [UIColor darkGrayColor];
    innerIcon.layer.cornerRadius = 5;
    innerIcon.layer.masksToBounds = YES;
    
    [view addSubview:innerIcon];
    return view;
}

- (void)updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction
{
    // you can appy animations duration scrolling here
     CGFloat percentage = distance / CGRectGetWidth(self.view.bounds) * NUMBER_OF_VISIBLE_VIEWS;
    if (percentage == 0) {
        [self animateMenuOut:view];
    } else if(fabs(percentage) == 1) {
        [self animateMenuBack:view];
    }
    
}

- (void)animateMenuOut:(UIView *)view
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.56 initialSpringVelocity:0 options:0 animations:^{
        view.transform = CGAffineTransformMakeTranslation(0, -60);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateMenuBack:(UIView *)view
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.56 initialSpringVelocity:0 options:0 animations:^{
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

@end
