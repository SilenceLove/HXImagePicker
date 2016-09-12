//
//  HX_AssetContainerVC.h
//  测试
//
//  Created by 洪欣 on 16/8/19.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HX_AssetContainerVC : UIViewController
@property (copy, nonatomic) NSArray *photoAy;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger maxNum;
@property (copy, nonatomic) void(^didRgihtBtnBlock)(NSInteger index);
@property (copy, nonatomic) void(^didOriginalBlock)();

@property (assign, nonatomic) BOOL ifPreview;

@property (assign, nonatomic) BOOL ifLookPic;
@end
