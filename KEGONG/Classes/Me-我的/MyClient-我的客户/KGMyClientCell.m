//
//  KGMyClientCell.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/19.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGMyClientCell.h"
#import "UIImageView+WebCache.h"

@interface KGMyClientCell ()
/** 按钮 */
@property (nonatomic, weak) IBOutlet UIButton *btn;
/** 头像 */
@property (nonatomic, weak) IBOutlet UIImageView *headerImage;
/** 名字 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
/** 电话 */
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@end

@implementation KGMyClientCell
+ (instancetype)cellWithTableView:(UITableView *)tableView type:(KGMyClientCellType)type
{
    if (type == KGMyClientCellTypeDefault) {
        static NSString *cellId = @"KGMyClientCell";
        KGMyClientCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
        }
        return cell;
    } else {
        static NSString *cellId = @"KGMyClientCell1";
        KGMyClientCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
        }
        return cell;
    }
}

- (void)setModel:(NSDictionary *)model
{
    _model = model;
    /** 按钮 */
    self.btn;
    /** 头像 */
//    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[KGIMAGEURL stringByAppendingPathComponent:model[@"thumbnail"]]]];
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:model[@"userheadpath"]] placeholderImage:[UIImage imageNamed:@"head portrait-1"]];
    /** 名字 */
    self.nameLabel.text = model[@"username"];
    /** 电话 */
    self.numberLabel.text = model[@"mobile"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.imageView.image = [UIImage imageNamed:@"head portrait"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.btn.selected = selected;
    // Configure the view for the selected state
}

@end
