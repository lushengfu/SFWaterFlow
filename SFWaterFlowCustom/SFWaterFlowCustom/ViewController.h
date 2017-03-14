//
//  ViewController.h
//  SFWaterFlowCustom
//
//  Created by lushengfu on 2017/3/12.
//  Copyright © 2017年 CM. All rights reserved.
//

//自定义颜色
// 颜色
#define SFColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define SFColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

// 随机色
#define SFRandomColor SFColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController


@end

