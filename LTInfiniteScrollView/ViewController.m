//
//  ViewController.m
//  LTInfiniteScrollView
//
//  Created by ltebean on 14/11/21.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import "LTInfiniteScrollView.h"
@interface ViewController ()<LTInfiniteScrollViewDelegate>
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
    
    self.scrollView = [[LTInfiniteScrollView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 64)];
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    [self.scrollView reloadData];
}

-(UIView*) viewAtIndex:(int)index reusingView:(UIView *)view;
{
    if(view){
        NSLog(@"reuse");
        ((UILabel*)view).text = [NSString stringWithFormat:@"%d", index];
        return view;
    }
    
    UILabel *aView = [[UILabel alloc]init];
    aView.backgroundColor = [UIColor blackColor];
    aView.layer.cornerRadius = 32;
    aView.layer.masksToBounds = YES;

    aView.textColor = [UIColor whiteColor];
    aView.textAlignment = NSTextAlignmentCenter;
    aView.text = [NSString stringWithFormat:@"%d", index];
    return aView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
