//
//  HX_AlbumModel.m
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AlbumModel.h"
#import "HX_AssetManager.h"
@implementation HX_AlbumModel

- (NSUInteger)photosNum
{
    if (_photosNum == 0) {
        _photosNum = [_group numberOfAssets];
    }
    return _photosNum;
}

- (NSString *)albumName
{
    if (!_albumName) {
        _albumName = [_group valueForProperty:ALAssetsGroupPropertyName];
        
        
        _albumName = [self getAblumTitle:_albumName];
        
        if (_albumName == nil) {
            _albumName = [_group valueForProperty:ALAssetsGroupPropertyName];
        }
    }
    return _albumName;
}

- (NSString *)getAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        if ([HX_AssetManager sharedManager].type == HX_SelectVideo) {
            return @"所有视频";
        }else {
            return @"所有照片";
        }
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"My Photo Stream"]){
        return @"我的照片流";
    }
    return nil;
}

@end
