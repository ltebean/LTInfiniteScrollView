//
//  ViewController.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "DemoViewController.h"
#import "LTInfiniteScrollView.h"

#define COLOR [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]

#define NUMBER_OF_VISIBLE_VIEWS 5

@interface DemoViewController ()<LTInfiniteScrollViewDelegate,LTInfiniteScrollViewDataSource>
@property (nonatomic,strong) LTInfiniteScrollView *scrollView;
@property (nonatomic) CGFloat viewSize;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
    self.scrollView = [[LTInfiniteScrollView alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 200)];
    [self.view addSubview:self.scrollView];
    //self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.maxScrollDistance = 5;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewSize = CGRectGetWidth(self.view.bounds) / NUMBER_OF_VISIBLE_VIEWS;
    [self.scrollView reloadData];
}

# pragma mark - IBAction
- (IBAction)reload:(id)sender {
    self.scrollView.delegate = nil;
    [self.scrollView reloadData];
}

- (IBAction)reloadWithFancyEffect:(id)sender {
    self.scrollView.delegate = self;
    [self.scrollView reloadData];
}

# pragma mark - LTInfiniteScrollView dataSource
- (NSInteger)numberOfViews
{
    return 9;
}

- (NSInteger)numberOfVisibleViews
{
    return NUMBER_OF_VISIBLE_VIEWS;
}

# pragma mark - LTInfiniteScrollView delegate
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
{
    if (view) {
        ((UILabel*)view).text = [NSString stringWithFormat:@"%ld", index];
        return view;
    }
    
    UILabel *aView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.viewSize, self.viewSize)];
    aView.backgroundColor = [UIColor blackColor];
    aView.layer.cornerRadius = self.viewSize/2.0f;
    aView.layer.masksToBounds = YES;
    aView.backgroundColor = COLOR;
    aView.textColor = [UIColor whiteColor];
    aView.textAlignment = NSTextAlignmentCenter;
    aView.text = [NSString stringWithFormat:@"%ld", (long)index];
    return aView;
}

- (void)updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction
{
    // you can appy animations duration scrolling here
    
    CGFloat percent = distance / CGRectGetWidth(self.view.bounds) * NUMBER_OF_VISIBLE_VIEWS;
    
    CATransform3D transform = CATransform3DIdentity;
    
    // scale
    CGFloat size = self.viewSize;
    CGPoint center = view.center;
    view.center = center;
    size = size * (1.4 - 0.3 * (fabs(percent)));
    view.frame = CGRectMake(0, 0, size, size);
    view.layer.cornerRadius = size / 2;
    view.center = center;
    
    // translate
    CGFloat translate = self.viewSize / 3 * percent;
    if (percent > 1) {
        translate = self.viewSize / 3;
    } else if (percent < -1) {
        translate = -self.viewSize / 3;
    }
    transform = CATransform3DTranslate(transform, translate, 0, 0);
    
    // rotate
    if (fabs(percent) < 1) {
        CGFloat angle = 0;
        if( percent > 0) {
            angle = - M_PI * (1-fabs(percent));
        } else {
            angle =  M_PI * (1-fabs(percent));
        }
        transform.m34 = 1.0/-600;
        if (fabs(percent) <= 0.5) {
            angle =  M_PI * percent;
            UILabel *label = (UILabel *)view;
            label.text = @"back";
            label.backgroundColor = [UIColor darkGrayColor];
        } else {
            UILabel *label = (UILabel*) view;
            label.text = [NSString stringWithFormat:@"%d", (int)view.tag];
            label.backgroundColor = COLOR;
        }
        transform = CATransform3DRotate(transform, angle , 0.0f, 1.0f, 0.0f);
    } else {
        UILabel *label = (UILabel *)view;
        label.text = [NSString stringWithFormat:@"%d", (int)view.tag];
        label.backgroundColor = COLOR;
    }

    view.layer.transform = transform;
        
}

# pragma mark - config views
- (void)configureForegroundOfLabel:(UILabel *)label
{
    NSString *text = [NSString stringWithFormat:@"%d",(int)label.tag];
    if ([label.text isEqualToString:text]) {
        return;
    }
    label.text = text;
    label.backgroundColor = COLOR;
}

- (void)configureBackgroundOfLabel:(UILabel *)label
{
    NSString *text = @"back";
    if ([label.text isEqualToString:text]) {
        return;
    }
    label.text = text;
    label.backgroundColor = [UIColor blackColor];
}
@end
