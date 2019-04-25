//
//  CZHotTitleModel.h
//  BestCity
//
//  Created by JasonBourne on 2018/10/26.
//  Copyright © 2018 JasonBourne. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface CZHotTitleModel : NSObject
/** id */
@property (nonatomic, strong) NSString *gtid;
/** 名字 */
@property (nonatomic, strong) NSString *gtname;
/** 图片 */
@property (nonatomic, strong) NSString *thumbnail;

/** 辅助 */
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
