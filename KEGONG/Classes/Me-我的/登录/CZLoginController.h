//
//  CZLoginController.h
//  BestCity
//
//  Created by JasonBourne on 2018/8/7.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZLoginController : UIViewController
/** 是否登录 */
@property (nonatomic, assign) BOOL isLogin;
+ (instancetype)shareLoginController;
@end
