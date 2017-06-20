//
//  ConversationMemberInformationTableViewCell.h
//  SafeChat
//
//  Created by Cristina Pocol on 20/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface ConversationMemberInformationTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDUser *)aUser;

@end
