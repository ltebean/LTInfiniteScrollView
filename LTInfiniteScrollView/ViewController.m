//
//  ViewController.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import "LTInfiniteScrollView.h"

#define color [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]
#define scrollViewHeight 400

@interface ViewController ()<LTInfiniteScrollViewDelegate,LTInfiniteScrollViewDataSource>
@property (nonatomic,strong) LTInfiniteScrollView* scrollView;
@property (nonatomic) CGFloat viewSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.scrollView = [[LTInfiniteScrollView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), scrollViewHeight)];
    [self.view addSubview:self.scrollView];
    //self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.pagingEnabled= NO;
    
    
    self.viewSize = CGRectGetWidth(self.view.bounds) / 5.0f;
    [self.scrollView reloadData];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.scrollView addGestureRecognizer:recognizer];
}

-(void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint translation = [recognizer translationInView:self.scrollView];
    
    int centerIndex = self.scrollView.currentIndex;
    NSArray* indexNeeded = @[[NSNumber numberWithInt:centerIndex-2],[NSNumber numberWithInt:centerIndex-1],[NSNumber numberWithInt:centerIndex],[NSNumber numberWithInt:centerIndex+1],[NSNumber numberWithInt:centerIndex+2]];
    NSMutableArray* views = [NSMutableArray array];

    for (NSNumber *index in indexNeeded){
        UIView* view = [self.scrollView viewAtIndex:[index intValue]];
        [views addObject:view];
    }
    
    for (int i = 0; i< views.count;i++) {
        UIView* view = views[i];
        CGPoint center = view.center;
        center.y = center.y + translation.y * (1-fabs(i-2)*0.25);
        if(center.y< (scrollViewHeight-70) && center.y > 70){
            view.center = center;
        }
    }
    
    [recognizer setTranslation:CGPointZero inView:self.scrollView];
    
    [self.scrollView scrollToIndex:self.scrollView.currentIndex];
    self.scrollView.scrollEnabled = NO;
    if(recognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
            for (UIView* view in views) {
                CGPoint center = view.center;
                center.y = CGRectGetMidY(self.scrollView.bounds);
                view.center = center;
            }
        } completion:^(BOOL finished) {
            self.scrollView.scrollEnabled = YES;
        }];
    }
}

- (IBAction)reload:(id)sender {
    self.scrollView.delegate = nil;
    [self.scrollView reloadData];
}

- (IBAction)reloadWithFancyEffect:(id)sender {
    self.scrollView.delegate = self;
    [self.scrollView reloadData];
}

-(int) totalViewCount
{
    return 99999;
}

-(int) visibleViewCount
{
    return 5;
}

-(UIView*) viewAtIndex:(int)index reusingView:(UIView *)view;
{
    if(view){
        ((UILabel*)view).text = [NSString stringWithFormat:@"%d", index];
        return view;
    }
    
    UILabel *aView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.viewSize, self.viewSize)];
    aView.backgroundColor = [UIColor blackColor];
    aView.layer.cornerRadius = self.viewSize/2.0f;
    aView.layer.masksToBounds = YES;
    aView.backgroundColor = color;
    aView.textColor = [UIColor whiteColor];
    aView.textAlignment = NSTextAlignmentCenter;
    aView.text = [NSString stringWithFormat:@"%d", index];
    return aView;
}

-(void) updateView:(UIView*) view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction
{
    CGFloat percent = distance/CGRectGetWidth(self.view.bounds)*5;
    if(view.tag == 1){
         //NSLog(@"%f",percent);
    }
    
    CATransform3D transform = CATransform3DIdentity;
    
    // scale
    CGFloat size = self.viewSize;
    CGPoint center = view.center;
    view.center = center;
    size = size * (1.4-0.3*(fabs(percent)));
    view.frame = CGRectMake(0, 0, size, size);
    view.layer.cornerRadius = size/2;
    view.center = center;
    
    // translate
    CGFloat translate = self.viewSize/3 * percent;
    if(percent >1){
        translate = self.viewSize/3;
    }else if(percent < -1){
        translate = -self.viewSize/3;
    }
    transform = CATransform3DTranslate(transform,translate, 0, 0);
    
    // rotate
    if(fabs(percent) < 1){
        CGFloat angle = 0;
        if(percent>0){
            angle = - M_PI * (1-fabs(percent));
        }else{
            angle =  M_PI * (1-fabs(percent));
        }
        transform.m34 = 1.0/-600;
        if(fabs(percent) <= 0.5){
            angle =  M_PI * percent;
            UILabel *label = (UILabel*) view;
            label.text = @"back";
            label.backgroundColor = [UIColor darkGrayColor];
        }else{
            UILabel *label = (UILabel*) view;
            label.text = [NSString stringWithFormat:@"%d",(int)view.tag];
            label.backgroundColor = color;
        }
        transform = CATransform3DRotate(transform, angle , 0.0f, 1.0f, 0.0f);
    }else{
        UILabel *label = (UILabel*) view;
        label.text = [NSString stringWithFormat:@"%d",(int)view.tag];
        label.backgroundColor = color;
    }

    view.layer.transform = transform;
        
}

-(void) configureForegroundOfLabel:(UILabel*) label
{
    NSString* text = [NSString stringWithFormat:@"%d",(int)label.tag];
    if([label.text isEqualToString:text]){
        return;
    }
    label.text = text;
    label.backgroundColor = color;
}

-(void) configureBackgroundOfLabel:(UILabel*) label
{
    NSString* text = @"back";
    if([label.text isEqualToString:text]){
        return;
    }
    label.text = text;
    label.backgroundColor = [UIColor blackColor];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
