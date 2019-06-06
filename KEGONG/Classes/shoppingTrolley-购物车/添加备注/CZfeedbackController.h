//
//  CZfeedbackController.h
//  BestCity
//
//  Created by JasonBourne on 2018/8/6.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CZfeedbackController;
@protocol CZfeedbackControllerDelegate <NSObject>

- (void)feedbackController:(CZfeedbackController *)vc commitWithText:(NSString *)text;

@end

@interface CZfeedbackController : UIViewController
/** 代理 */
@property (nonatomic, assign) id <CZfeedbackControllerDelegate> delegate;
@end
