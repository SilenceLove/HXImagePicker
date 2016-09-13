//
//  HX_AssetContainerViewCell.h
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HX_PhotoModel.h"
#import <MediaPlayer/MediaPlayer.h>
@interface HX_AssetContainerViewCell : UICollectionViewCell
//@property (weak, nonatomic) UIButton *playBtn;
@property (strong, nonatomic) HX_PhotoModel *model;
@property (copy, nonatomic) void(^didImgBlock)();
//@property (strong, nonatomic) MPMoviePlayerController *player;
@end
