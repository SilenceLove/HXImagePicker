//
//  HX_VideoContainerVC.h
//  测试
//
//  Created by 洪欣 on 16/8/23.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HX_PhotoModel.h"
@interface HX_VideoContainerVC : UIViewController
@property (strong, nonatomic) HX_PhotoModel *model;
@property (assign, nonatomic) BOOL ifPush;
@property (assign, nonatomic) BOOL ifVideo;
@end
