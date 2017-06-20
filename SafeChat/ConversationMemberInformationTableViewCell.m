//
//  ConversationMemberInformationTableViewCell.m
//  SafeChat
//
//  Created by Cristina Pocol on 20/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "ConversationMemberInformationTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DesignConstants.h"

@interface ConversationMemberInformationTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineDateLabel;

@property (strong, nonatomic) SBDUser *user;

@end


@implementation ConversationMemberInformationTableViewCell

+ (UINib *)nib {
    
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    
    return NSStringFromClass([self class]);
}

- (void)setModel:(SBDUser *)aUser {
    self.user = aUser;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    self.nicknameLabel.text = self.user.nickname;
    
    if (self.user.connectionStatus == SBDUserConnectionStatusOnline) {
        self.onlineDateLabel.text = @"Online";
        self.onlineDateLabel.textColor = [DesignConstants memberOnlineTextColor];
    }
    else {
        // Last seen at
        NSDateFormatter *lastMessageDateFormatter = [[NSDateFormatter alloc] init];
        
        NSDate *lastMessageDate = nil;
        if ([NSString stringWithFormat:@"%lld", self.user.lastSeenAt].length == 10) {
            lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.user.lastSeenAt];
        }
        else {
            lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.user.lastSeenAt / 1000.0];
        }
        NSDate *currDate = [NSDate date];
        
        NSDateComponents *lastMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastMessageDate];
        NSDateComponents *currDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
        
        if (lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day) {
            [lastMessageDateFormatter setDateStyle:NSDateFormatterShortStyle];
            [lastMessageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
            self.onlineDateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
        }
        else {
            [lastMessageDateFormatter setDateStyle:NSDateFormatterNoStyle];
            [lastMessageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
            self.onlineDateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
        }
        
        self.onlineDateLabel.textColor = [DesignConstants memberOfflineDateTextColor];
    }
}


@end
