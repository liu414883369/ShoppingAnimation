//
//  ViewController.m
//  购物车动画
//
//  Created by liujianjian on 15/10/20.
//  Copyright © 2015年 rdg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *shoppingCar;
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic,strong)CALayer *layer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shoppingCar.layer.cornerRadius = 20.0;
    self.shoppingCar.layer.masksToBounds = YES;
    
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.imageView.image = [UIImage imageNamed:@"meizi.jpg"];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", (long)indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 拿到cell对应的rect
    CGRect cellRect_O = [tableView rectForRowAtIndexPath:indexPath];
    // cell的坐标系转成self.view中
    CGRect cellRect_D = [self.tableView convertRect:cellRect_O toView:self.view];
    NSLog(@"%@=%@", NSStringFromCGRect(cellRect_O), NSStringFromCGRect(cellRect_D));
    // 商品图片对应的坐标
    CGFloat pointX = 20.0;
    CGFloat pointY = cellRect_D.origin.y+20.0;
    
    // 创建贝塞尔曲线，添加起始点、结束的、控制点
    self.bezierPath = [UIBezierPath bezierPath];
    [_bezierPath moveToPoint:CGPointMake(pointX, pointY)]; // 起始点
    // 结束的：购物车图标那里， 控制点：x屏幕中心，y比起始点Y坐标高150像素
    [_bezierPath addQuadCurveToPoint:CGPointMake(self.view.frame.size.width-35, self.view.frame.size.height-60)
                        controlPoint:CGPointMake(self.view.frame.size.width/2.0, pointY-200.0)];
    
    // 在起始点创建layer，在layer上添加路径动画
    [self makeLayerWithOrigin:CGPointMake(pointX, pointY)];
}
- (void)makeLayerWithOrigin:(CGPoint)origin {
    self.layer = [CALayer layer];
    _layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"meizi.jpg"].CGImage);
    _layer.contentsGravity = kCAGravityResizeAspectFill;
    _layer.bounds = CGRectMake(0, 0, 20, 20);
    _layer.cornerRadius = 10;
    _layer.masksToBounds = YES;
    _layer.anchorPoint = CGPointZero; // 锚点设置未零,position就相当于x y坐标
    _layer.position = origin; // 定位到商品图片附件
    [self.view.layer addSublayer:_layer];
    
    [self makeAnimation];
}
- (void)makeAnimation {
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyframeAnimation.path = self.bezierPath.CGPath; // 添加路径
    keyframeAnimation.rotationMode = kCAAnimationRotateAuto; // 自动旋转
    
    CAAnimationGroup *animtaionGroup = [CAAnimationGroup animation];
    animtaionGroup.animations = @[keyframeAnimation];
    /*
     当group动画的时长 > 组中所有动画的最长时长, 动画的时长以组中最长的时长为准
     当group动画的时长 < 组中所有动画的最长时长, 动画的时长以group的时长为准
     最合适: group的时长 = 组中所有动画的最长时长
     */
    animtaionGroup.duration = 1.0f;
    animtaionGroup.removedOnCompletion = NO; // yes连续点击会有图片影像
    animtaionGroup.fillMode = kCAFillModeForwards;
    animtaionGroup.delegate = self;
    [self.layer addAnimation:animtaionGroup forKey:@"group"];
    
    [self performSelector:@selector(removeLayer:) withObject:self.layer afterDelay:1.0f];
    
}
- (void)removeLayer:(CALayer *)layer {
    [layer removeFromSuperlayer];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    if (self.layer) {
//        [self.layer removeFromSuperlayer];
//    }
//    if (anim == [self.layer animationForKey:@"group"]) {
        CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        basicAnim.duration = 0.2f;
        basicAnim.fromValue = [NSNumber numberWithFloat:1];
        basicAnim.toValue = [NSNumber numberWithFloat:1.5];
        basicAnim.autoreverses = YES;
        [self.shoppingCar.layer addAnimation:basicAnim forKey:nil];
//    }
}








@end
