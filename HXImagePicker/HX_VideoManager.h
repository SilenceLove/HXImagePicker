//
//  HX_VideoManager.h
//  城市2.0
//
//  Created by 洪欣 on 16/8/26.
//  Copyright © 2016年 NRH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HX_VideoManager : NSObject

/**
 *  获取的所有相册数组
 */
@property (strong, nonatomic) NSMutableArray *allAlbumAy;

/**
 *  获取的所有相册里的图片数组
 */
@property (strong, nonatomic) NSMutableArray *allGroup;

/**
 *  是否刷新
 */
@property (assign, nonatomic) BOOL ifRefresh;

/**
 *  已经添加的图片数组
 */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

/**
 *  存放视频压缩后的地址
 */
@property (strong, nonatomic) NSMutableArray *videoFileNames;

/**
 *  自定义相册的名称
 */
@property (copy, nonatomic) NSString *customName;

+ (instancetype)sharedManager;

/**
 *  获取所有相册信息
 */
- (void)getAllAlbumWithStart:(void(^)())start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;

/**
 *  保存通过相机拍摄的视频
 */
- (void)savePhotoWithVideo:(NSURL *)url completion:(void(^)())completion WithError:(void(^)())error;

/**
 *  获取通过相机拍摄的视频
 */
- (void)getJustTakeVideoWithCompletion:(void(^)(NSArray *array))completion;
@end
