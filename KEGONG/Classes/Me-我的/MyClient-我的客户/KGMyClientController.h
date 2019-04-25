//
//  KGMyClientController.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/19.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KGMyClientControllerType) {
    KGMyClientControllerTypeMe,
    KGMyClientControllerTypeOrder,
};
NS_ASSUME_NONNULL_BEGIN
@class KGMyClientController;
@protocol KGMyClientControllerDelegate <NSObject>
@optional
- (void)myClientController:(KGMyClientController *)vc updataAddress:(NSDictionary *)address;
@end

@interface KGMyClientController : UIViewController
/** 获取数据的类型 */
@property (nonatomic, assign) KGMyClientControllerType type;
/** 代理 */
@property (nonatomic, assign) id <KGMyClientControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
