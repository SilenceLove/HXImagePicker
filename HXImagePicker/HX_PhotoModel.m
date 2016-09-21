//
//  HX_PhotoModel.m
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_PhotoModel.h"
#import "HX_AssetManager.h"
#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]
@implementation HX_PhotoModel

- (BOOL)ifSelect
{
    if (!_ifAdd) {
        return NO;
    }else {
        return YES;
    }
    return _ifSelect;
}

- (CGSize)imageSize
{
    if (_imageSize.width == 0 || _imageSize.height == 0) {
        if (VERSION < 8.0f) {
            _imageSize = [[_asset defaultRepresentation] dimensions];
        }else {
            _imageSize = CGSizeMake(_PH_Asset.pixelWidth, _PH_Asset.pixelHeight);
        }
    }
    return _imageSize;
}

- (NSString *)fileName
{
    if (!_fileName) {
        _fileName = [[_asset defaultRepresentation] filename];
    }
    return _fileName;
}

- (NSDictionary *)imageDic
{
    if (!_imageDic) {
        _imageDic = [[_asset defaultRepresentation] metadata];
    }
    return _imageDic;
}

- (NSString *)uti
{
    if (!_uti) {
        _uti = [[_asset defaultRepresentation] UTI];
    }
    return _uti;
}

- (NSURL *)url
{
    if (!_url) {
        if (VERSION < 8.0f) {
            _url = [[_asset defaultRepresentation] url];
        }
    }
    return _url;
}
@end
