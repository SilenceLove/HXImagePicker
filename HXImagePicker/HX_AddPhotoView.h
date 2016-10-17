//
//  HX_AddPhotoView.h
//  测试
//
//  Created by 洪欣 on 16/8/18.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SelectPhoto,
    SelectVideo,
    SelectPhotoAndVideo
}SelectType;

@protocol HX_AddPhotoViewDelegate <NSObject>

@optional
/**
 *  更新frame
 */
- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view;
@end

@interface HX_AddPhotoView : UIView

/**
 *  每行显示的个数
 */
@property (assign, nonatomic) NSInteger lineNum;

/**
 *  当前选择的个数
 */
@property (assign, nonatomic) NSInteger selectNum;

/**
 *  collectionView距离顶部的大小 底部与顶部对称
 */
@property (assign, nonatomic) CGFloat margin_Top;

/**
 *  collectionView距离左边的大小 右边与左边对称
 */
@property (assign, nonatomic) CGFloat margin_Left;

/**
 *  每个itme之间的间距 最小为5
 */
@property (assign, nonatomic) CGFloat lineSpacing;

/**
 *  拍摄视频最大秒数
 */
@property (assign, nonatomic) CGFloat videoMaximumDuration;

/**
 *  自定义相册名称
 */
@property (copy, nonatomic) NSString *customName;

/**
 *  类型为 SelectPhotoAndVideo / SelectPhoto 时选择、删除、拖动图片之后调用 -- 注意用weak修饰,不然会循环引用
 */
@property (copy, nonatomic) void(^selectPhotos)(NSArray *array,NSArray *videoFileNames,BOOL ifOriginal);

/**
 *  类型为 SelectVideo 时选择、删除、拖动图片之后调用 -- 注意用weak修饰,不然会循环引用
 */
@property (copy, nonatomic) void(^selectVideo)(NSArray *array,NSArray *videoFileNames);

@property (weak, nonatomic) id<HX_AddPhotoViewDelegate> delegate;

/**
 *  num : 最大限制
 *  type: 选择的类型
 */
- (instancetype)initWithMaxPhotoNum:(NSInteger)num WithSelectType:(SelectType)type;
@end
