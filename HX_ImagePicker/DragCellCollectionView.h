//
//  DragCellCollectionView.h
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.


/**如何使用：
    1、继承与DragCellCollectionView；
    2、实现必须实现的DataSouce代理方法：（在该方法中返回整个CollectionView的数据数组用于重排）
    - (NSArray *)dataSourceArrayOfCollectionView:(DragCellCollectionView *)collectionView;
    3、实现必须实现的一个Delegate代理方法：（在该方法中将重拍好的新数据源设为当前数据源）(例如 :_data = newDataArray)
    - (void)dragCellCollectionView:(DragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;
 */



#import <UIKit/UIKit.h>
@class DragCellCollectionView;

@protocol  DragCellCollectionViewDelegate<UICollectionViewDelegate>

@required
/**
 *  当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
 *  @param newDataArray   更新后的数据源
 */
- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;

@optional

/**
 *  某个cell将要开始移动的时候调用
 *  @param indexPath      该cell当前的indexPath
 */
- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  某个cell正在移动的时候
 */
- (void)dragCellCollectionViewCellisMoving:(DragCellCollectionView *)collectionView;
/**
 *  cell移动完毕，并成功移动到新位置的时候调用
 */
- (void)dragCellCollectionViewCellEndMoving:(DragCellCollectionView *)collectionView;
/**
 *  成功交换了位置的时候调用
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol  DragCellCollectionViewDataSource<UICollectionViewDataSource>


@required
/**
 *  返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray *)dataSourceArrayOfCollectionView:(DragCellCollectionView *)collectionView;

@end

@interface DragCellCollectionView : UICollectionView

@property (nonatomic, assign) id<DragCellCollectionViewDelegate> delegate;
@property (nonatomic, assign) id<DragCellCollectionViewDataSource> dataSource;

/**长按多少秒触发拖动手势，默认0.2秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/**是否正开始编辑模式*/
@property (nonatomic, assign) BOOL beginEditing;

@property (assign, nonatomic) NSInteger maxNum;

@property (assign, nonatomic) BOOL ifVideo;

@end
