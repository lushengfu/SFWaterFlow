//
//  ViewController.m
//  SFWaterFlowCustom
//
//  Created by lushengfu on 2017/3/12.
//  Copyright © 2017年 CM. All rights reserved.
//

#import "ViewController.h"
#import "SFWaterFlowView.h"
#import "SFWaterFlowCell.h"

@interface ViewController () <SFWaterFlowViewDelegate, SFWaterFlowViewDataSource>

/**自定义瀑布流View*/
@property (nonatomic, strong)SFWaterFlowView *waterFlowView;

@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.waterFlowView];
    
//    [self.waterFlowView reloadData];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.waterFlowView.frame = self.view.bounds;
}

#pragma mark - SFWaterFlowViewDataSource代理
- (NSUInteger)numberOfWaterFlowView:(SFWaterFlowView *)waterFlowView
{
    return 40;
}

- (NSUInteger)numberOfColumnInWaterFlowView:(SFWaterFlowView *)waterFlowView
{
    return 3;
}

- (SFWaterFlowCell *)waterFlowView:(SFWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index
{
    static NSString *identifier = @"identifier";
    SFWaterFlowCell *waterFlowCell = [waterFlowView dequeueReusableCellWithIdentifier:identifier];
    if (!waterFlowCell) {
        waterFlowCell = [[SFWaterFlowCell alloc] init];
        waterFlowCell.identifier = identifier;
        waterFlowCell.backgroundColor = SFRandomColor;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 0, 20, 30);
        label.tag = 100;
        [waterFlowCell addSubview:label];
    }
    UILabel *label = [waterFlowCell viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%lu", index];
    return waterFlowCell;
}

#pragma mark - SFWaterFlowViewDelegate代理
- (CGFloat)waterFlowView:(SFWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index
{
    switch (index%3) {
        case 0:
            return 70;
            break;
        case 1:
            return 100;
            break;
        case 2:
            return 80;
            break;
        default:
            return 120;
            break;
    }
}

- (CGFloat)waterFlowView:(SFWaterFlowView *)waterFlowView marginType:(WaterFlowMarginType)marginType
{
    switch (marginType) {
        case WaterFlowMarginTypeTop:
        case WaterFlowMarginTypeLeft:
        case WaterFlowMarginTypeBottom:
        case WaterFlowMarginTypeRight:
            return 10;
            break;
        case WaterFlowMarginTypeRow:
        case WaterFlowMarginTypeColumn:
            return 5;
            break;
        default:
            return 10;
            break;
    }
}

- (void)waterFlowView:(SFWaterFlowView *)waterFlowView didSelectAtIndex:(NSUInteger)index
{
    NSLog(@"点击的第 %lu 个cell", index);
}

#pragma mark - getter and setter
- (SFWaterFlowView *)waterFlowView
{
    if (!_waterFlowView) {
        _waterFlowView = [[SFWaterFlowView alloc] initWithFrame:self.view.bounds];
        _waterFlowView.dataSource = self;
        _waterFlowView.waterFlowdelegate = self;
    }
    return _waterFlowView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
