//
//  SFWaterFlowView.h
//  SFWaterFlowCustom
//
//  Created by lushengfu on 2017/3/12.
//  Copyright © 2017年 CM. All rights reserved.
//
//  模仿UITableView封装瀑布流控件

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, WaterFlowMarginType)
{
    WaterFlowMarginTypeTop,
    WaterFlowMarginTypeLeft,
    WaterFlowMarginTypeBottom,
    WaterFlowMarginTypeRight,
    WaterFlowMarginTypeRow,  //行间距
    WaterFlowMarginTypeColumn, //列间距
};

@class SFWaterFlowView, SFWaterFlowCell;

@protocol SFWaterFlowViewDataSource <NSObject>
@required
/**返回数据源的总数*/
- (NSUInteger)numberOfWaterFlowView:(SFWaterFlowView *)waterFlowView;
/**返回当前索引的index*/
- (SFWaterFlowCell *)waterFlowView:(SFWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index;

@optional
/**返回瀑布流的列数*/
- (NSUInteger)numberOfColumnInWaterFlowView:(SFWaterFlowView *)waterFlowView;

@end

@protocol SFWaterFlowViewDelegate <UIScrollViewDelegate>
@optional
/**返回瀑布流当前Item的高度*/
- (CGFloat)waterFlowView:(SFWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index;
/**返回边距及行和列的距离*/
- (CGFloat)waterFlowView:(SFWaterFlowView *)waterFlowView marginType:(WaterFlowMarginType)marginType;
/**点击单个Cell*/
- (void)waterFlowView:(SFWaterFlowView *)waterFlowView didSelectAtIndex:(NSUInteger)index;

@end

@interface SFWaterFlowView : UIScrollView
/**数据源的代理*/
@property (nonatomic, weak) id<SFWaterFlowViewDataSource> dataSource;
/**瀑布流的代理*/
@property (nonatomic, weak) id<SFWaterFlowViewDelegate> waterFlowdelegate;

/**加载数据源*/
- (void)reloadData;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
