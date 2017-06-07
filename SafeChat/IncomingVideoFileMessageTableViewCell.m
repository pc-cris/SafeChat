//
//  IncomingVideoFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/14/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "IncomingVideoFileMessageTableViewCell.h"
#import "Utils.h"
#import "DesignConstants.h"

@interface IncomingVideoFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewHeight;

@property (strong, nonatomic) SBDFileMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation IncomingVideoFileMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)clickProfileImage {
    if (self.delegate != nil) {
        [self.delegate clickProfileImage:self user:self.message.sender];
    }
}

- (void)clickFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)aMessage {
    self.message = aMessage;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.message.sender.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:messageContainerTapRecognizer];
    
    /***********************************/
    /* Thumbnail is a premium feature. */
    /***********************************/
    if (self.message.thumbnails != nil && self.message.thumbnails.count > 0) {
        if (self.message.thumbnails[0].url.length > 0) {
            [self.fileImageView setImageWithURL:[NSURL URLWithString:self.message.thumbnails[0].url]];
        }
    }
    else {
        [self.fileImageView setImageWithURL:[NSURL URLWithString:self.message.url]];
    }
    
    // Message Date
    NSDictionary *messageDateAttribute = @{
                                           NSFontAttributeName: [DesignConstants messageDateFont],
                                           NSForegroundColorAttributeName: [DesignConstants messageDateColor]
                                           };
    
    NSTimeInterval messageTimestamp = (double)self.message.createdAt / 1000.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];
    NSString *messageDateString = [dateFormatter stringFromDate:messageCreatedDate];
    NSMutableAttributedString *messageDateAttributedString = [[NSMutableAttributedString alloc] initWithString:messageDateString attributes:messageDateAttribute];
    self.messageDateLabel.attributedText = messageDateAttributedString;
    
    // Seperator Date
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateSeperatorLabel.text = [seperatorDateFormatter stringFromDate:messageCreatedDate];
    
    // Relationship between the current message and the previous message
    self.profileImageView.hidden = NO;
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorView.hidden = NO;
            self.dateSeperatorViewHeight.constant = 24.0;
            self.dateSeperatorViewTopMargin.constant = 10.0;
            self.dateSeperatorViewBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorView.hidden = YES;
            self.dateSeperatorViewHeight.constant = 0;
            self.dateSeperatorViewBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateSeperatorViewTopMargin.constant = 10.0;
            }
            else {
                SBDUser *prevMessageSender = nil;
                SBDUser *currMessageSender = nil;
                
                if ([self.prevMessage isKindOfClass:[SBDUserMessage class]]) {
                    prevMessageSender = [(SBDUserMessage *)self.prevMessage sender];
                }
                else if ([self.prevMessage isKindOfClass:[SBDFileMessage class]]) {
                    prevMessageSender = [(SBDFileMessage *)self.prevMessage sender];
                }
                
                currMessageSender = [self.message sender];
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.dateSeperatorViewTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                    }
                    else {
                        // Set default margin.
                        self.profileImageView.hidden = NO;
                        self.dateSeperatorViewTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateSeperatorViewTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorView.hidden = NO;
        self.dateSeperatorViewHeight.constant = 24.0;
        self.dateSeperatorViewTopMargin.constant = 10.0;
        self.dateSeperatorViewBottomMargin.constant = 10.0;
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.fileImageViewHeight.constant;
    
    return height;
}

@end
