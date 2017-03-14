//
//  SFWaterFlowView.m
//  SFWaterFlowCustom
//
//  Created by lushengfu on 2017/3/12.
//  Copyright © 2017年 CM. All rights reserved.
//  模仿UITableView封装瀑布流控件

//cell的默认高度
#define kSFWaterFlowViewDefaultHeight 70
//间距
#define kSFWaterFlowViewDefaultMargin 10

#define kSFWaterFlowViewDefaultColumn 3

#import "SFWaterFlowView.h"
#import "UIView+Extension.h"
#import "SFWaterFlowCell.h"

@interface SFWaterFlowView ()

/**保存所有cell的frame*/
@property (nonatomic, strong)NSMutableArray *cellFrames;
/**保存已显示的cell*/
@property (nonatomic, strong)NSMutableDictionary *displayCells;
/**缓存重用的cell*/
@property (nonatomic, strong)NSMutableSet *reusableCells;

@end

@implementation SFWaterFlowView
#pragma mark - init method
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - 公共接口,加载数据源
- (void)reloadData
{
    //保存显示Cell的总数
    NSUInteger totalCount = [self.dataSource numberOfWaterFlowView:self];
    //获取间距
    CGFloat leftMargin = [self marginForType:WaterFlowMarginTypeLeft];
    CGFloat rightMargin = [self marginForType:WaterFlowMarginTypeRight];
    CGFloat topMargin = [self marginForType:WaterFlowMarginTypeTop];
    CGFloat bottomMargin = [self marginForType:WaterFlowMarginTypeBottom];
    CGFloat rowMargin = [self marginForType:WaterFlowMarginTypeRow];
    CGFloat columnMargin = [self marginForType:WaterFlowMarginTypeColumn];
    //获取总列数
    NSUInteger columns = [self columnForWaterFlow];
    //获取cell的宽度
    CGFloat cellWidth = (self.width - leftMargin - rightMargin - (columns - 1)*rowMargin)/columns;
    //利用C语言数组缓存高度
    CGFloat columnCellHeight[columns];
    //初始化数组
    for (NSInteger i = 0; i < columns; i++) {
        columnCellHeight[i] = 0.0;
    }
    
    for (NSUInteger i = 0; i < totalCount; i++) {
        //获取cell的高度
        CGFloat cellHeight = [self heightForCell:i];
        //保存最小高度的列数
        NSUInteger minColumn = 0;
        CGFloat minColumnHeight = columnCellHeight[0];
        for (NSUInteger j = 1; j < columns; j++) {
            if (minColumnHeight > columnCellHeight[j]) {
                minColumn = j;
                minColumnHeight = columnCellHeight[j];
            }
        }
        
        CGFloat cellX = leftMargin + minColumn * (cellWidth + columnMargin);
        CGFloat cellY = 0.0;
        if (columnCellHeight[minColumn] == 0.0) {
            cellY = topMargin;
        }
        else
        {
            cellY = columnCellHeight[minColumn] + bottomMargin;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
        //缓存所有cell的frame
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        //更新最短一列的最大值
        columnCellHeight[minColumn] = CGRectGetMaxY(cellFrame);
    }
    //获取列的最大值
    CGFloat maxColumnsHeight = columnCellHeight[0];
    for (NSInteger j = 1; j < columns; j++) {
        if (columnCellHeight[j] > maxColumnsHeight) {
            maxColumnsHeight = columnCellHeight[j];
        }
    }
    //加上底部间距
    maxColumnsHeight += bottomMargin;
    self.contentSize = CGSizeMake(0, maxColumnsHeight);
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block SFWaterFlowCell *waterFlowCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(SFWaterFlowCell *  _Nonnull cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            waterFlowCell = cell;
            *stop = YES;
        }
    }];
    if (waterFlowCell) {
        [self.reusableCells removeObject:waterFlowCell];
    }
    
    return waterFlowCell;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger cellFramesCount = self.cellFrames.count;
    
    for (NSUInteger i = 0; i < cellFramesCount; i++) {
        
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        //从字典中获取cell
        SFWaterFlowCell *waterFlowCell = self.displayCells[@(i)];
        if ([self isInScreen:cellFrame]) { //当前的cell在屏幕上
            if (!waterFlowCell) {
                waterFlowCell = [self.dataSource waterFlowView:self cellAtIndex:i];
                waterFlowCell.frame = cellFrame;
                [self addSubview:waterFlowCell];
                //加入到字典
                self.displayCells[@(i)] = waterFlowCell;
            }
        }
        else //不在屏幕上
        {
            if (waterFlowCell) {
                //cell从scrollView和字典中移除
                [waterFlowCell removeFromSuperview];
                [self.displayCells removeObjectForKey:@(i)];
                //加入到缓存中
                [self.reusableCells addObject:waterFlowCell];
            }
            
           
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}

#pragma mark - 事件处理
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.waterFlowdelegate respondsToSelector:@selector(waterFlowView:didSelectAtIndex:)]) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectNumber = nil;
    [self.displayCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *  _Nonnull key, SFWaterFlowCell *  _Nonnull cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectNumber = key;
            *stop = YES;
        }
    }];
    if (selectNumber) {
        [self.waterFlowdelegate waterFlowView:self didSelectAtIndex:selectNumber.unsignedIntegerValue];
    }
}

#pragma mark - private method
//判断当前的cell是否在屏幕上
- (BOOL)isInScreen:(CGRect)cellFrame
{
    if (CGRectGetMaxY(cellFrame) > self.contentOffset.y && CGRectGetMinY(cellFrame) < self.contentOffset.y + self.height) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)columnForWaterFlow
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnInWaterFlowView:)]) {
        return [self.dataSource numberOfColumnInWaterFlowView:self];
    }
    return kSFWaterFlowViewDefaultColumn;
}

- (CGFloat)marginForType:(WaterFlowMarginType)marginType
{
    if ([self.waterFlowdelegate respondsToSelector:@selector(waterFlowView:marginType:)]) {
        return [self.waterFlowdelegate waterFlowView:self marginType:marginType];
    }
    return kSFWaterFlowViewDefaultMargin;
}

- (CGFloat)heightForCell:(NSUInteger)index
{
    if ([self.waterFlowdelegate respondsToSelector:@selector(waterFlowView:heightAtIndex:)]) {
        return [self.waterFlowdelegate waterFlowView:self heightAtIndex:index];
    }
    else
    {
        return kSFWaterFlowViewDefaultHeight;
    }
}

#pragma mark - getter and setter

- (NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [[NSMutableSet alloc] init];
    }
    return _reusableCells;
}


- (NSMutableDictionary *)displayCells
{
    if (!_displayCells) {
        _displayCells = [[NSMutableDictionary alloc] init];
    }
    return _displayCells;
}


- (NSMutableArray *)cellFrames
{
    if (!_cellFrames) {
        _cellFrames = [[NSMutableArray alloc] init];
    }
    return _cellFrames;
}

@end
