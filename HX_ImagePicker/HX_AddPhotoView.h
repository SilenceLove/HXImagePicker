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
- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view;

@end

@interface HX_AddPhotoView : UIView
@property (assign, nonatomic) NSInteger lineNum;
@property (assign, nonatomic) NSInteger selectNum;
@property (assign, nonatomic) CGFloat margin_Top;
@property (assign, nonatomic) CGFloat margin_Left;
@property (assign, nonatomic) CGFloat lineSpacing;
@property (assign, nonatomic) CGFloat videoMaximumDuration;
@property (copy, nonatomic) void(^selectPhotos)(NSArray *array,BOOL ifOriginal);
@property (copy, nonatomic) void(^selectVideo)(NSArray *array);
@property (weak, nonatomic) id<HX_AddPhotoViewDelegate> delegate;

/**
 *  num : 最大限制
 *  type: 选择的类型
 */
- (instancetype)initWithMaxPhotoNum:(NSInteger)num WithSelectType:(SelectType)type;
@end
