//
//  SYStickHeaderWaterFallLayout.m
//  SYStickHeaderWaterFall
//
//  Created by 张苏亚 on 16/3/4.
//  Copyright © 2016年 suya. All rights reserved.
//

#import "SYStickHeaderWaterFallLayout.h"
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define NSLog(format, ...) do { \
fprintf(stderr, "<%s : %d> %s\n", \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
__LINE__, __func__); \
(NSLog)((format), ##__VA_ARGS__); \
fprintf(stderr, "-------\n"); \
} while (0)

NSString* const SYStickHeaderWaterCellKind = @"WaterfallCell";
NSString* const SYStickHeaderWaterDecorationKind = @"Decoration";
@interface SYStickHeaderWaterFallLayout()
@property (nonatomic,strong) NSArray *topInsetArray;//每个section的top
@property (nonatomic,strong) NSArray *bottomInsetArray;//每个section的bottom
@property (nonatomic,strong) NSArray *itemInnerMarginArray;//
@property (nonatomic,strong) NSArray *columnsCountArray;//每个section的columncount
@property (nonatomic,strong) NSArray *itemsWidthArray;
@property (nonatomic,strong) NSArray *headerToTopArray;//每个section的停留时与顶部的距离
@property (nonatomic) NSDictionary *layoutInfo;//全部layoutAttribute信息
@property (nonatomic) NSArray *sectionsHeights;//
@property (nonatomic) NSArray *itemsInSectionsHeights;//每个section里cell的高度.
@end
@implementation SYStickHeaderWaterFallLayout
#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}



- (void)setup {
    self.fixTop = 0;
    self.isTopForHeader = NO;
    self.isStickyHeader = YES;
    [self invalidateLayout];

}

- (void)prepareLayout {
    if (self.collectionView.isDecelerating || self.collectionView.isDragging) {
        
    } else {
        [self calculateHeaderToTop];//计算每个section的停留时与顶部的距离通,过代理方法（collectionView:layout:headerToTopInSection:）获得
        [self calculateItemsWidth];//计算所在section的每个item的width（一个section只有一个width）.通过代理方法（collectionView:layout:widthForItemInSection:）获得
        [self calculateSectionsTopInsetAndBottomInset];//计算所在section与上一个section的间距和所在section与下一个section的间距.通过代理方法（collectionView:layout:topInSection:和collectionView:layout:bottomInSection:）获得
        [self calculateColumnsCount];//计算每个section的列数（根据itemsWidthArray计算列数，而itemsWidthArray是[self calculateItemsWidth]计算出来的）
        [self calculateItemsInnerMarginArray];//计算每个section中item之间的间距(上下左右的间距都是同一个数值)(根据itemsWidthArray计算列数)
        [self calculateItemsHeights];//计算item的高度
        [self calculateSectionsHeights];//计算每个section的高度
        [self calculateItemsAttributes];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame) || [elementIdentifier isEqualToString:UICollectionElementKindSectionHeader]) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    if(!self.isStickyHeader) {
        return allAttributes;
    }
    //保证section停留
    for (UICollectionViewLayoutAttributes *layoutAttributes in allAttributes) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            
            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame) + [self.itemInnerMarginArray[section] floatValue];
            CGFloat currentHeaderHeight = [self headerHeightForIndexPath:firstCellIndexPath];
            CGPoint origin = layoutAttributes.frame.origin;

            origin.y = MIN(
                           MAX(self.collectionView.contentOffset.y + self.fixTop +[self.headerToTopArray[section] floatValue], (CGRectGetMinY(firstCellAttrs.frame) - headerHeight) - (self.isTopForHeader?[self.topInsetArray[section] floatValue]:0.0f)) ,
                           CGRectGetMinY(firstCellAttrs.frame) - headerHeight + [[self.sectionsHeights objectAtIndex:section] floatValue] - currentHeaderHeight - (self.isTopForHeader?[self.topInsetArray[section] floatValue]:0.0f)                           ) + (self.isTopForHeader?[self.topInsetArray[section] floatValue]:0.0f) ;//
            CGFloat width = layoutAttributes.frame.size.width;
            if(self.collectionView.contentOffset.y > origin.y -self.fixTop -[self.headerToTopArray[section] floatValue]) {
                width = self.collectionView.bounds.size.width;
                origin.x = 0;
                origin.y = origin.y + [self.headerToTopArray[section] floatValue];
                NSLog(@"self.collectionView.contentOffset.y%@",@(self.collectionView.contentOffset.y));
                
            } else {
                
                width = kDeviceWidth;
                origin.x = 0;

            }
            
            layoutAttributes.zIndex = 1024 +section;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = CGSizeMake(width, layoutAttributes.frame.size.height)
            };
        }
    }
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[SYStickHeaderWaterCellKind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[UICollectionElementKindSectionHeader][indexPath];
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:
//(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
//    return self.layoutInfo[SYStickHeaderWaterDecorationKind][indexPath];
//}

- (CGSize)collectionViewContentSize {
    CGFloat height = 0;
    for (NSInteger i =0; i< [self.topInsetArray count]; i++) {
        height += [self.topInsetArray[i] floatValue];
    }
    NSLog(@"height%@",[NSString stringWithFormat:@"%f",[[NSNumber numberWithFloat:height] floatValue]]);
    for (NSNumber *h in self.sectionsHeights) {
        height += [h integerValue];
    }
    for (NSInteger i =0; i< [self.bottomInsetArray count]; i++) {
        height += [self.bottomInsetArray[i] floatValue];
    }
    NSLog(@"height%@",[NSString stringWithFormat:@"%li",(long)[[NSNumber numberWithFloat:height] integerValue]]);
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return self.isStickyHeader;
}

#pragma mark - Prepare layout calculation
//计算每个section的停留时与顶部的距离（此时不加上topInsetArray里的值）
-(void)calculateHeaderToTop
{
    NSMutableArray *headerToTopArray = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    for (NSInteger section = 0; section< self.collectionView.numberOfSections; section++) {
        [headerToTopArray addObject:[NSNumber numberWithFloat:[self headerToTopInSection:section]]];
    }
    self.headerToTopArray = [headerToTopArray copy];
}
//每个cell的高度.
- (void) calculateItemsHeights {
    NSMutableArray *itemsInSectionsHeights = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    NSIndexPath *itemIndex;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSMutableArray *itemsHeights = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfItemsInSection:section]];
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            itemIndex = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemHeight = [self.delegate collectionView:self.collectionView
                                                        layout:self
                                      heightForItemAtIndexPath:itemIndex];
            [itemsHeights addObject:[NSNumber numberWithFloat:itemHeight]];
        }
        [itemsInSectionsHeights addObject:itemsHeights];
    }
    
    self.itemsInSectionsHeights = itemsInSectionsHeights;
}
//每个section的列数
- (void) calculateColumnsCount {
    NSMutableArray *itemsInSectionsCount = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        [itemsInSectionsCount addObject:[NSNumber numberWithInteger:self.collectionView.bounds.size.width / [self.itemsWidthArray[section] floatValue]]];
    }
    self.columnsCountArray = [itemsInSectionsCount copy];
}
//每个section的topInset和bottomInset
-(void)calculateSectionsTopInsetAndBottomInset
{
    NSMutableArray *topInsetInSection = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    NSMutableArray *bottomInsetInSection = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        [topInsetInSection addObject:[NSNumber numberWithFloat:[self topInSection:section]]];
        [bottomInsetInSection addObject:[NSNumber numberWithFloat:[self bottomInSection:section]]];
    }
    self.topInsetArray = [topInsetInSection copy];
    self.bottomInsetArray = [bottomInsetInSection copy];
}
//每个section的ItemArray
-(void)calculateItemsWidth
{
    NSMutableArray *itemsWidthArray = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    
    for (NSInteger section = 0; section<self.collectionView.numberOfSections; section++) {
        [itemsWidthArray addObject:[NSNumber numberWithFloat:[self itemWidthInSection:section]]];
    }
    self.itemsWidthArray = [itemsWidthArray copy];
}
//ItemsInnerMarginArray
-(void)calculateItemsInnerMarginArray
{
    NSMutableArray *itemsInnerMarginArray = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    for (NSInteger section = 0; section < self.columnsCountArray.count; section++) {
        
        NSInteger columnsCount = [self.columnsCountArray[section] integerValue];

            [itemsInnerMarginArray addObject:[NSNumber numberWithFloat:(self.collectionView.bounds.size.width -
                                                                        columnsCount *[self.itemsWidthArray[section]floatValue])
                                              /
                                              (columnsCount + 1)]];
            
    }
    self.itemInnerMarginArray = [itemsInnerMarginArray copy];
}
- (void) calculateSectionsHeights {
    NSMutableArray *newSectionsHeights = [NSMutableArray array];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        [newSectionsHeights addObject:[self calculateHeightForSection:section]];
    }
    self.sectionsHeights = [NSArray arrayWithArray:newSectionsHeights];
}
//返回最高列的高度
- (NSNumber*) calculateHeightForSection: (NSInteger)section {
        NSInteger sectionColumns[[self.columnsCountArray[section] integerValue]];
        //为每一列初始化高度。sectionHeight
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        for (NSInteger column = 0; column < [self.columnsCountArray[section] integerValue]; column++) {
            CGFloat itemInnerMargin = [self.itemInnerMarginArray[section] floatValue];
            sectionColumns[column] = [self headerHeightForIndexPath:indexPath]
            + itemInnerMargin+[self.topInsetArray[section] floatValue] +[self.bottomInsetArray[section] floatValue];
        }
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            NSInteger currentColumn = 0;
            for (NSInteger column = 0; column < [self.columnsCountArray[section] integerValue]; column++) {
                if(sectionColumns[currentColumn] > sectionColumns[column]) {
                    currentColumn = column;
                }
            }
            
            sectionColumns[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:section]
                                               objectAtIndex:indexPath.item] floatValue];
            sectionColumns[currentColumn] += [self.itemInnerMarginArray[section] floatValue];
        }
        
        NSInteger biggestColumn = 0;
        for (NSInteger column = 0; column < [self.columnsCountArray[section] integerValue]; column++) {
            if(sectionColumns[biggestColumn] < sectionColumns[column]) {
                biggestColumn = column;
            }
        }
        
        return [NSNumber numberWithFloat: sectionColumns[biggestColumn]];
    
}
//预估每个单位的UICollectionViewLayoutAttributes
- (void) calculateItemsAttributes {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//    UICollectionViewLayoutAttributes *emblemAttributes =
//    [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SYStickHeaderWaterDecorationKind
//                                                                withIndexPath:indexPath];
    //    emblemAttributes.frame = [self frameForWaterfallDecoration];
    NSLog(@"%@",@([self.collectionView numberOfSections]));
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForWaterfallCellIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
            
            //Only one header in section, so we get only item at 0 position
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes
                                                                     layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                     withIndexPath:indexPath];
                titleAttributes.frame = [self frameForWaterfallHeaderAtIndexPath:indexPath];
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[SYStickHeaderWaterCellKind] = cellLayoutInfo;
    newLayoutInfo[UICollectionElementKindSectionHeader] = titleLayoutInfo;
    //    newLayoutInfo[SYStickHeaderWaterDecorationKind] = @{indexPath: emblemAttributes};
    
    self.layoutInfo = newLayoutInfo;
    
}

#pragma mark - Items frames
//每个item的frame
- (CGRect)frameForWaterfallCellIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self.itemsWidthArray[indexPath.section] floatValue];
    CGFloat height = [[[self.itemsInSectionsHeights objectAtIndex:indexPath.section]
                       objectAtIndex:indexPath.item] floatValue];
    
    CGFloat topInset = [self.topInsetArray[indexPath.section] floatValue];
    for (NSInteger section = 0; section < indexPath.section; section++) {
        topInset += [[self.sectionsHeights objectAtIndex:section] integerValue];
    }
    
    NSInteger columnsHeights[[self.columnsCountArray[indexPath.section] integerValue]];
    for (NSInteger column = 0; column < [self.columnsCountArray[indexPath.section] integerValue]; column++) {
        columnsHeights[column] = [self headerHeightForIndexPath:indexPath] + [self.itemInnerMarginArray[indexPath.section] floatValue];
    }
    
    for (NSInteger item = 0; item < indexPath.item; item++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
        NSInteger currentColumn = 0;
        for(NSInteger column = 0; column < [self.columnsCountArray[indexPath.section] integerValue]; column++) {
            if(columnsHeights[currentColumn] > columnsHeights[column]) {
                currentColumn = column;
            }
        }
        
        columnsHeights[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:ip.section]
                                           objectAtIndex:ip.item] floatValue];
        columnsHeights[currentColumn] += [self.itemInnerMarginArray[indexPath.section] floatValue];
    }
    
    NSInteger columnForCurrentItem = 0;
    for (NSInteger column = 0; column < [self.columnsCountArray[indexPath.section] integerValue]; column++) {
        if(columnsHeights[columnForCurrentItem] > columnsHeights[column]) {
            columnForCurrentItem = column;
        }
    }
    
    CGFloat originX = [self.itemInnerMarginArray[indexPath.section] floatValue] +
    columnForCurrentItem * [self.itemsWidthArray[indexPath.section] floatValue]+
    columnForCurrentItem * [self.itemInnerMarginArray[indexPath.section] floatValue];
    CGFloat originY =  columnsHeights[columnForCurrentItem] + topInset;
    
    return CGRectMake(originX, originY, width, height);
}
//headerView的frame
- (CGRect)frameForWaterfallHeaderAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width -
    [self.itemInnerMarginArray[indexPath.section] floatValue] * 2;
    CGFloat height = [self headerHeightForIndexPath:indexPath];
    //before
    //    CGFloat originY = self.topInset;
    CGFloat originY = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        originY += [[self.sectionsHeights objectAtIndex:i] floatValue];
    }
    
    CGFloat originX = [self.itemInnerMarginArray[indexPath.section] floatValue];
    return CGRectMake(originX, originY, width, height);
}

//- (CGRect) frameForWaterfallDecoration {
//    CGSize size = [FRGWaterfallDecorationReusableView defaultSize];
//    CGFloat originX = floorf((self.collectionView.bounds.size.width - size.width) * 0.5f);
//    CGFloat originY = -size.height - 30.0f;
//    return CGRectMake(originX, originY, size.width, size.height);
//}
//headerView的height。通过代理返回，如果没有实现代理，返回0
- (CGFloat) headerHeightForIndexPath:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderAtIndexPath:)]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                  heightForHeaderAtIndexPath:indexPath];
    }
    
    return 0.0f;
}
//返回headerView（如果有）与cell之间的距离。通过代理返回，如果没有实现代理，返回0
- (CGFloat) topInSection:(NSInteger )section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:topInSection:)]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                                topInSection:section];
    }
    return 0.0f;
}
//返回cell与下一个section的headerView（如果有）之间的距离。通过代理返回，如果没有实现代理，返回0
-(CGFloat) bottomInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:bottomInSection:)]) {
        return [self.delegate collectionView:self.collectionView
                                      layout:self
                             bottomInSection:section];
    }
    return 0.0f;
}
//每个section里的item的width,默认返回屏幕的宽度
-(CGFloat) itemWidthInSection :(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:widthForItemInSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self widthForItemInSection:section];
    }
    return kDeviceWidth;
}
/**
 *返回所在section的header停留时与顶部的距离（如果设置isTopForHeader ＝ yes ，则距离会叠加），默认返回0
 *
 */
-(CGFloat)headerToTopInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:headerToTopInSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self headerToTopInSection:section];
    }
    return 0.0f;
}
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
