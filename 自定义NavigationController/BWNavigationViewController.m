//
//  BWNavigationViewController.m
//  自定义NavigationController
//
//  Created by 静静静 on 15/7/25.
//  Copyright (c) 2015年 BossKai. All rights reserved.
//

#import "BWNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface BWNavigationViewController ()
@property (nonatomic,assign,getter = isFirstTouch)BOOL firstTouch;
@property (nonatomic,assign )CGPoint startPoint;
@property (nonatomic,assign,getter= isMoving) BOOL moving;
@property (nonatomic,assign) NSInteger index;

//存储视图图像
@property (nonatomic,strong) NSMutableArray * imagePictureList;
@end

@implementation BWNavigationViewController


- (void)viewDidLoad {
    //注册手势
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector (paningGestureReceive:)];
    [self.view addGestureRecognizer:recognizer];
    
    //在第一次触摸屏幕时进行一些必要的初始化，以优化性能
    self.firstTouch = YES;
    
}


-(void)paningGestureReceive:(UIGestureRecognizer *)recognizer
{
    if (self.viewControllers.count <= 1)
        return;
    
    UIImage * img = [self.imagePictureList lastObject];
    UIImageView * backgroundView = [[UIImageView alloc]initWithImage:img];
    backgroundView.frame = [UIScreen mainScreen].bounds;
    
    //拖动开始将缓存池中父控制器视图截图，添加到当前控制器的视图之下
    [self.view.superview insertSubview:backgroundView belowSubview:self.view];
    
    if (self.firstTouch) {
        //重定位anchorPoint与Position以更改layer旋转中心点
        CALayer * layer = self.view.layer;
        CGPoint oldAnchorPoint = layer.anchorPoint;
        layer.anchorPoint = CGPointMake(0.5, 1);
        [layer setPosition:CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - oldAnchorPoint.x), layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y - oldAnchorPoint.y))];
        self.firstTouch = NO;
    }
    //手指滑动开始
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //记录拖动开始位置
        self.startPoint = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
        //跟踪状态
        self.moving = YES;
    }
    
    //手指滑动结束
    else if (recognizer.state == UIGestureRecognizerStateEnded){
        //获得拖动结束位置
        CGPoint endTouchPoint = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
        //获得拖动距离
        CGFloat distance = (endTouchPoint.x - self.startPoint.x)>0? (endTouchPoint.x - self.startPoint.x):- (endTouchPoint.x - self.startPoint.x);
        //距离大于150执行pop动画
        if (distance > 150) {
            [self pop];
            //移除缓存池中的图片
            [self.imagePictureList removeObject:img];
            //更改状态
            self.moving = NO;
            return;
        }
        //距离小于150，将控制器位置还原
        [UIView animateWithDuration:0.3 animations:^{
            CATransform3D transform = CATransform3DIdentity;
            [self.view.layer setTransform:transform];
            CGRect frame = [UIScreen mainScreen].bounds;
            frame.origin.x = 0;
            //将view的frame还原
            self.view.frame = frame;
            self.moving = NO;
            return ;
        }];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            self.moving = NO;
        }];
        
        return;
    }
    if(self.isMoving){
        //获取当前位置坐标
        CGPoint  touchPoint = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
        //根据当前位置坐标执行相应动画
        [self moveViewWithX: self.startPoint.x-touchPoint.x  ];
    }
    
}
-(void)addImagePicture
{
    //获取图片上下文，并截取图片
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    //图片缓存
    [self.imagePictureList addObject:img];
}

//在手指移动过程中，根据手指移动距离，按照重新定义的anchorPoint旋转
-(void)moveViewWithX:(float)x
{
    float balpha = x<0? - x:x;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform,(M_PI/180*(balpha/kDeviceWidth)*50), 0, 0, 1);
    [self.view.layer setTransform:transform];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.index !=0) {
        [self addImagePicture];
    }
    //缓存池中图片数量
    self.index++;
    [super pushViewController:viewController animated:animated];
}

- (void)pop
{
    [UIView animateWithDuration:0.3 animations:^{
        //将偏移后的视图移除到可见视图之外
        [self moveViewWithX:kDeviceWidth*2];
        CGRect frame = self.view.bounds;
        frame.origin.x = kDeviceWidth;
        frame.origin.y += 250;
        [self.view setFrame:frame];
        
    }completion:^(BOOL finished) {
        //调用父类pop操作并重新设置视图控制器位置
        [self popViewControllerAnimated:NO];
        CATransform3D transform = CATransform3DIdentity;
        [self.view.layer setTransform:transform];
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.origin.x = 0;
        self.view.frame = frame;
    }];
}

-(NSMutableArray *)imagePictureList{
    if (_imagePictureList == nil) {
        _imagePictureList = [NSMutableArray array];
    }
    return _imagePictureList;
}
@end
