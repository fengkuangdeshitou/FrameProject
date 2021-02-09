//
//  SYStickHeaderWaterFallLayout.h
//  SYStickHeaderWaterFall
//
//  Created by 张苏亚 on 16/3/4.
//  Copyright © 2016年 suya. All rights reserved.
//
//  Thank FRGWaterfallCollectionViewLayout😊.

#import <UIKit/UIKit.h>

@class SYStickHeaderWaterFallLayout;

@protocol SYStickHeaderWaterFallDelegate <NSObject>
//Inspired by UITableViewDelegate 😄
/**
 *  返回所在section的每个item的width（一个section只有一个width）
 *
 */
- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView
                   layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
   widthForItemInSection:( NSInteger )section;
/**
 *  返回所在indexPath的每个item的height（每个item有一个height，要不然怎么是瀑布流😄）
 *
 */
- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView
                   layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

@optional
/**
 *  返回所在indexPath的header的height
 *
*/
- (CGFloat) collectionView:(nonnull UICollectionView *)collectionView
                    layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(nonnull NSIndexPath *)indexPath;
/**
 *  返回所在section与上一个section的间距(表达的可能不够准确，但是你们都懂的)
 *
 */
- (CGFloat) collectionView:(nonnull UICollectionView *)collectionView
                    layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
topInSection:(NSInteger )section;
/**
 *  返回所在section与下一个section的间距(表达的可能不够准确，但是你们都懂的)
 *
 */
- (CGFloat) collectionView:(nonnull UICollectionView *)collectionView
                    layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
            bottomInSection:( NSInteger)section;
/**
 *  返回所在section的header停留时与顶部的距离（如果设置isTopForHeader ＝ yes ，则距离会叠加）
 *
 */
- (CGFloat) collectionView:(nonnull UICollectionView *)collectionView
                    layout:(nonnull SYStickHeaderWaterFallLayout *)collectionViewLayout
           headerToTopInSection:( NSInteger)section;
@end

@interface SYStickHeaderWaterFallLayout : UICollectionViewLayout

@property (nonatomic, assign,nonnull)  id<SYStickHeaderWaterFallDelegate> delegate;
//在此修正sectionheader停留的位置,默认64
@property (nonatomic,assign) CGFloat fixTop;

//是否设置sectionHeader停留,默认YES
@property (nonatomic) BOOL isStickyHeader;
//section停留的位置是否包括原来设置的top，默认NO
@property (nonatomic) BOOL isTopForHeader;
@end


// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com