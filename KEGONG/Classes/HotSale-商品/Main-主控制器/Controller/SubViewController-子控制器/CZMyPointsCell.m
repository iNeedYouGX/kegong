//
//  CZMyPointsCell.m
//  BestCity
//
//  Created by JasonBourne on 2018/8/3.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZMyPointsCell.h"
#import "UIImageView+WebCache.h"

@interface CZMyPointsCell ()
/** 大图片 */
@property (nonatomic, weak) IBOutlet UIImageView *bigImage;
/** 标题 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;


@end

@implementation CZMyPointsCell
- (IBAction)buyButtonAction:(id)sender {
    [CZProgressHUD showProgressHUDWithText:@"积分不足!"];
    [CZProgressHUD hideAfterDelay:1];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setDicData:(NSDictionary *)dicData
{
    _dicData = dicData;
    [self.bigImage sd_setImageWithURL:[NSURL URLWithString:[KGIMAGEURL stringByAppendingPathComponent:dicData[@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"logo"]];
    self.titleLabel.text = dicData[@"gtname"];

}

@end
