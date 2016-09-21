# HXImagePicker

## 喜欢的话可以给个star✨么?😘

##模仿QQ图片选择器,支持多选、选原图和视频的图片选择器，同时有预览功能,长按拖动改变顺序.通过相机拍照录制视频

<h3 color = red>当使用相机的时候会将拍下的照片和视频存放到自定义相册中</h3>

【手动导入】：将项目中的HX_ImagerPicker此文件夹拽入项目中，导入头文件：#import "HX_AddPhotoView.h"</br>
【使用CocoaPods】：pod 'HXImagePicker', '~> 0.0.1'----暂时不要用CocoaPods

<table border = "1">
<tr>
    <td><img src = "https://github.com/LoveZYForever/HXImagePicker/raw/master/screenshots/xuanzeqi.gif" width = "240" height = "425"></td>
    <td><img width = "50" height = "425"></td>
    <td><img src = "https://github.com/LoveZYForever/HXImagePicker/raw/master/screenshots/shipin.gif" width = "240" height = "425"></td>
</tr>
</table>
</br>
##例子: 
- 在有导航栏的控制器里需要设置设个这两个属性

    self.automaticallyAdjustsScrollViewInsets = NO; </br>
    self.navigationController.navigationBar.translucent = YES;

- 当一个界面有两个选择器的时候最好设置约束

###选择类型
- SelectPhoto,        // 只选择图片
- SelectVideo,        // 只选择视频        选择视频的时候内部强制的只能选择一个
- SelectPhotoAndVideo // 图片视频同时选择

###代码部分
```objc
HX_AddPhotoView *addPhotoView = [[HX_AddPhotoView alloc] initWithMaxPhotoNum:9 WithSelectType:SelectPhoto];

// 每行最大个数   不设置默认为4
addPhotoView.lineNum = 3;

// collectionView 距离顶部的距离  底部与顶部一样  不设置,默认为0
addPhotoView.margin_Top = 5;

// 距离左边的距离  右边与左边一样  不设置,默认为0
addPhotoView.margin_Left = 10;

// 每个item间隔的距离  如果最小不能小于5   不设置,默认为5
addPhotoView.lineSpacing = 5;

// 录制视频时最大秒数   默认为60;
addPhotoView.videoMaximumDuration = 60.f;

// 自定义相册的名称 - 不设置默认为自定义相册
addPhotoView.customName = @"";

addPhotoView.delegate = self;
addPhotoView.backgroundColor = [UIColor whiteColor];
addPhotoView.frame = CGRectMake(0, 150, width - 0, 0);
[self.view addSubview:addPhotoView];

// 当前选择的个数
addPhotoView.selectNum;
```

- 当选择类型为 SelectPhoto 或 SelectPhotoAndVideo 时 请用这个block 

```objc
[addPhotoView setSelectPhotos:^(NSArray *photos, NSArray *videoFileNames, BOOL iforiginal) {

    iforiginal 是否原图

    // 选择视频的沙盒文件路径  -  已压缩
    NSString *videoFileName = videoFileNames.firstObject;

    [photos enumerateObjectsUsingBlock:^(id *asset, NSUInteger idx, BOOL * _Nonnull stop) {

        // ios8.0 以下返回的是ALAsset对象 以上是PHAsset对象
        if (VERSION < 8.0f) {
            ALAsset *oneAsset = (ALAsset *)asset;
            // 缩略图
            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

            // 原图
            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];

            // url
            NSURL *url = [[asset defaultRepresentation] url];
        }else {
            PHAsset *twoAsset = (PHAsset *)asset;

            CGFloat scale = [UIScreen mainScreen].scale;

            // 根据输入的大小来控制返回的图片质量
            CGSize size = CGSizeMake(300 * scale, 300 * scale);
            [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:twoAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                // image为高清图时
                if (![info objectForKey:PHImageResultIsDegradedKey]) {
                    // 高清图
                    image;
                }
            }];
        }
    }];
}];
```
- 当选择类型为 SelectVideo 时 请用这个block

```objc
[addVideoView setSelectVideo:^(NSArray *video, NSArray *videoFileNames) {

    // 选择视频的沙盒文件路径  -  已压缩
    NSString *videoFileName = videoFileNames.firstObject;
    
    [video enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        // ios8.0 以下返回的是ALAsset对象
        if (VERSION < 8.0f) {
            ALAsset *oneAsset = (ALAsset *)asset;
            // 缩略图
            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

            // 原图
            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];

            // url
            NSURL *url = [[asset defaultRepresentation] url];
        }else {
            PHAsset *twoAsset = (PHAsset *)asset;

            CGFloat scale = [UIScreen mainScreen].scale;

            // 根据输入的大小来控制返回的图片质量
            CGSize size = CGSizeMake(300 * scale, 300 * scale);
            [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:twoAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                // image为高清图时
                if (![info objectForKey:PHImageResultIsDegradedKey]) {
                    // 高清图
                    image;
                }
            }];
        }
    }];
}];
```

- 代理->当每行个数超过最大限制的个数时 此方法就会更新AddPhotoView的高度

```objc
- (void)updateViewFrame:(CGRect)frame
{
    [self.view layoutSubviews];
}
```

项目里面还有视频压缩写入沙盒目录的代码可以参考下
具体代码看请下载项目

发现的哪里有不好或不对的地方麻烦请联系我,大家一起讨论一起学习进步... 
QQ : 294005139

![image](https://github.com/LoveZYForever/HXImagePicker/raw/master/screenshots/xuanzeqi.gif)
