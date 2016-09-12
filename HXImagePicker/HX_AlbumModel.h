//
//  HX_AlbumModel.h
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface HX_AlbumModel : NSObject
/**  封面图  */
@property (strong, nonatomic) UIImage *coverImage;

/**  缩略图  */
@property (strong, nonatomic) UIImage *thumbnail;

/**  相册名称  */
@property (copy, nonatomic) NSString *albumName;
/**  相册内容数量  */
@property (assign, nonatomic) NSUInteger photosNum;

@property (strong, nonatomic) ALAssetsGroup *group;
@end
