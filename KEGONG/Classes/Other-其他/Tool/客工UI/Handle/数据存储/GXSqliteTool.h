//
//  GXSqliteTool.h
//  test2
//
//  Created by JasonBourne on 2019/3/23.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGShoppingTrolleyModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface GXSqliteTool : NSObject
+ (instancetype)sqliteTool;

- (BOOL)insert:(KGShoppingTrolleyModel *)stu;

- (void)deleteWithText:(NSString *)text;

- (void)delete;

- (NSArray *)select;

- (NSArray *)selectWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
