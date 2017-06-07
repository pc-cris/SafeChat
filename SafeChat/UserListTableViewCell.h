//
//  UserListTableViewCell.h
//  SafeChat
//
//  Created by Cristina Pocol on 26/02/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface UserListTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDUser *)aUser;
//- (void)setSelectedUser:(BOOL)selected;

@end
