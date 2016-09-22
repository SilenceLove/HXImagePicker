//
//  HX_AssetManager.h
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HX_PhotoModel.h"
#import "HX_AlbumModel.h"
typedef enum{
    HX_SelectPhoto,
    HX_SelectVideo,
    HX_SelectPhotoAndVieo
}HX_SelectType;

@interface HX_AssetManager : NSObject

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
 *  用于记录的数组
 */
@property (strong, nonatomic) NSMutableArray *recordPhotos;

/**
 *  记录是否原图
 */
@property (assign, nonatomic) BOOL recordOriginal;

/**
 *  选择的类型
 */
@property (assign, nonatomic) HX_SelectType type;

/**
 *  已经添加的图片数组
 */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

/**
 *  是否原图
 */
@property (assign, nonatomic) BOOL ifOriginal;

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
 *  根据PHAsset获取图片信息
 */
- (void)accessToImageAccordingToTheAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void(^)(UIImage *image,NSDictionary *info))completion;

/**
 *  保存通过相机拍摄的图片
 */
- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)())completion WithError:(void(^)())error;

/**
 *  获取通过相机拍摄的图片
 */
- (void)getJustTakePhotosWithCompletion:(void(^)(NSArray *array))completion;

/**
 *  保存通过相机拍摄的视频
 */
- (void)savePhotoWithVideo:(NSURL *)url completion:(void(^)())completion WithError:(void(^)())error;

/**
 *  获取通过相机拍摄的视频
 */
- (void)getJustTakeVideoWithCompletion:(void(^)(NSArray *array))completion;

/**
 *  获取图片原图的大小
 */
- (void)getPhotosBytes:(void(^)(NSString *bytes))by;
@end
