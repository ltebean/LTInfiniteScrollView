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

@interface ViewController ()<LTInfiniteScrollViewDelegate,LTInfiniteScrollViewDataSource>
@property (nonatomic,strong) LTInfiniteScrollView* scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView = [[LTInfiniteScrollView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 200)];
    [self.view addSubview:self.scrollView];
    //self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    [self.scrollView reloadData];
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
    return 1000000000;
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
    
    UILabel *aView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    aView.backgroundColor = [UIColor blackColor];
    aView.layer.cornerRadius = 64 / 2;
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
         NSLog(@"%f",percent);
    }
    
    CATransform3D transform = CATransform3DIdentity;
    
    // scale
    CGFloat scale = 1.6 - 0.3*fabs(percent);
    transform = CATransform3DScale(transform, scale, scale, scale);
    
    // translate
    CGFloat translate = 16 * percent;
    transform = CATransform3DTranslate(transform,translate, 0, 0);
    
    // rotate
    if(fabs(percent) < 1){
        CGFloat angle = 0;
        angle =  M_PI * (1-fabs(percent));
        transform.m34 = 1.0/-600;
        if(fabs(percent) <= 0.5){
            angle =  M_PI * (fabs(percent));
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
