//
//  HX_PhotoModel.h
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum{
    HX_Photo,
    HX_Video,
    HX_Unknown
}HX_PhotoType;
@interface HX_PhotoModel : NSObject

@property (assign, nonatomic) HX_PhotoType type;

/**  是否选中  */
@property (assign, nonatomic) BOOL ifSelect;
//
@property (assign, nonatomic) BOOL ifAdd;

@property (assign, nonatomic) NSInteger tableViewIndex;
@property (assign, nonatomic) NSInteger collectionViewIndex;

/**  图片原图  */
@property (strong, nonatomic) UIImage *resolutionImage;

/**  图片的全屏图  */
@property (strong, nonatomic) UIImage *screenImage;
/**  展示图  */
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) ALAsset *asset;
///**  图片的宽高  */
@property (assign, nonatomic) CGSize imageSize;

/**  视频的时长  */
@property (copy, nonatomic) NSString *videoTime;

/**  图片的名称  */
@property (copy, nonatomic) NSString *fileName;
/**  图片的小大  */
//@property (assign, nonatomic) CGFloat size;
/**  图片的原数据  */
@property (strong, nonatomic) NSDictionary *imageDic;
/**  图片的旋转方向  */
//@property (assign, nonatomic) ALAssetOrientation <#名字#>;
/**  图片的URL  */
@property (strong, nonatomic) NSURL *url;
/**  图片的唯一标示符  */
@property (copy, nonatomic) NSString *uti;

@property (assign, nonatomic) NSInteger index;

@property (assign, nonatomic) NSInteger newIndex;

@end
