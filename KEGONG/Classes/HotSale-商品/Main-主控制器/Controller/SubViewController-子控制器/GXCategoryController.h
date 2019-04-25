//
//  GXCategoryController.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/16.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZHotTitleModel.h"

@class GXCategoryController;
@protocol GXCategoryControllerDelegate <NSObject>
@optional
- (void)categoryController:(GXCategoryController *)categoryViewController didSelectedSubCategory:(CZHotTitleModel *)subCategory;
@end

NS_ASSUME_NONNULL_BEGIN

@interface GXCategoryController : UITableViewController
/** 所有的类别数据 */
@property (nonatomic, strong) NSArray<CZHotTitleModel *> *categories;

/** 几点的代理 */
@property (nonatomic, weak) id<GXCategoryControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
