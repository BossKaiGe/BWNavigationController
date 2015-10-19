//
//  ViewController.m
//  自定义NavigationController
//
//  Created by 静静静 on 15/7/25.
//  Copyright (c) 2015年 BossKai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton * push = [[UIButton alloc]init];
    [push setBackgroundColor:[UIColor whiteColor]];
    [push setTitle:@"push" forState:UIControlStateNormal];
    [push setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [push setFrame:CGRectMake(100, 100, 70, 30)];
    [push addTarget:self action:@selector(pushViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:push];
}

-(void)pushViewController
{
    ViewController * vc = [[ViewController alloc]init];
   
    [vc.view setBackgroundColor:[self randomColor]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)randomColor
{
    CGFloat r = arc4random() % 255 / 256.0;
    CGFloat g = arc4random() % 255 / 256.0;
    CGFloat b = arc4random() % 255 / 256.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}



@end
