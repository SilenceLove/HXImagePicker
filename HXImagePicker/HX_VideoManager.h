//
//  HX_VideoManager.h
//  城市2.0
//
//  Created by 洪欣 on 16/8/26.
//  Copyright © 2016年 NRH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HX_VideoManager : NSObject
@property (strong, nonatomic) NSMutableArray *allAlbumAy;
@property (strong, nonatomic) NSMutableArray *allGroup;

@property (assign, nonatomic) BOOL ifRefresh;

/**  已经添加的图片数组  */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
/**  存放视频压缩后的地址  */
@property (strong, nonatomic) NSMutableArray *videoFileNames;

/**  自定义相册的名称  */
@property (copy, nonatomic) NSString *customName;

@property (copy, nonatomic) NSString *totalBytes;

+ (instancetype)sharedManager;

/**  获取所有相册信息  */
- (void)getAllAlbumWithStart:(void(^)())start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;


- (void)savePhotoWithVideo:(NSURL *)url completion:(void(^)())completion WithError:(void(^)())error;
- (void)getJustTakeVideoWithCompletion:(void(^)(NSArray *array))completion;
@end
