//
//  CZConst.h
//  BestCity
//
//  Created by JasonBourne on 2018/11/9.
//  Copyright © 2018 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 图片URL的全局路径 */
UIKIT_EXTERN NSString *KGIMAGEURL;
UIKIT_EXTERN NSString * const loginChangeUserInfo;

typedef NS_ENUM(NSInteger, CZJIPINModuleType){
    CZJIPINModuleHotSale,
    CZJIPINModuleDiscover,
    CZJIPINModuleEvaluation,
    CZJIPINModuleTrail,
    CZJIPINModuleTrailReport,
    CZJIPINModuleMe,
};
