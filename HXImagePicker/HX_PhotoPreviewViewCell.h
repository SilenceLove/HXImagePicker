//
//  HX_AddPhotoCollectionViewCell.h
//  测试
//
//  Created by 洪欣 on 16/8/19.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class HX_PhotoModel;
@interface HX_PhotoPreviewViewCell : UICollectionViewCell
@property (strong, nonatomic) HX_PhotoModel *model;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) void(^didPHBlock)(UICollectionViewCell *cell);
@property (assign, nonatomic) NSInteger maxNum;
@end
