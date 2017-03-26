//
//  UserListTableViewCell.m
//  SafeChat
//
//  Created by Cristina Pocol on 26/02/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UserListTableViewCell.h"

@interface UserListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (strong, nonatomic) SBDUser *user;


@end

@implementation UserListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)setModel:(SBDUser *)aUser {
    self.user = aUser;
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.user.profileUrl] placeholderImage:[UIImage imageNamed:@"user_profile"]];
    self.userLabel.text = self.user.nickname;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
