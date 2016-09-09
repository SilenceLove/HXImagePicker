//
//  HX_AddPhotoViewCell.h
//  测试
//
//  Created by 洪欣 on 16/8/22.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HX_PhotoModel.h"
#import "HX_AddPhotoView.h"
@interface HX_AddPhotoViewCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) HX_PhotoModel *model;
@property (copy, nonatomic) void(^deleteBlock)(UICollectionViewCell *cell);
@property (assign, nonatomic) NSInteger type;
@end
