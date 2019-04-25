//
//  CZNavigationView.h
//  BestCity
//
//  Created by JasonBourne on 2018/8/1.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZNavigationViewDelegate <NSObject>
@optional
- (void)popViewController;
@end
@class CZNavigationView;
typedef void(^rightBtnBlock)(CZNavigationView *);

typedef NS_ENUM(NSUInteger, CZNavigationViewType) {
    CZNavigationViewTypeBlack,
    CZNavigationViewTypeWhite,
};

@interface CZNavigationView : UIView
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title rightBtnTitle:(NSString *)rightBtnTitle rightBtnAction:(rightBtnBlock)rightBtnAction navigationViewType:(CZNavigationViewType)type;

@property (nonatomic, assign) id <CZNavigationViewDelegate> delegate;
/** 右边的按钮 */
@property (nonatomic, strong) UIButton *rightRecordBtn;
/** 右边显示的内容 */
@property (nonatomic, strong) NSString *rightText;
@end
