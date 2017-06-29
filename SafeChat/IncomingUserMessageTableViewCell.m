//
//  IncomingTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "IncomingUserMessageTableViewCell.h"
#import "PCConstantsAndKeys.h"
#import "EncryptionManager.h"
#import "DesignConstants.h"

@interface IncomingUserMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewBottomMargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelRightMargin;

@property (strong, nonatomic) SBDUserMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (atomic) BOOL displayNickname;

@end

@implementation IncomingUserMessageTableViewCell

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

- (void)clickUserMessage {
    if (self.delegate != nil) {
//        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)setModel:(SBDUserMessage *)aMessage {
    self.message = aMessage;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.message.sender.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    [profileImageTapRecognizer setDelegate:self];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];

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
    self.dateSeperatorView.hidden = NO;
    self.dateSeperatorViewHeight.constant = 24.0;
    self.dateSeperatorViewTopMargin.constant = 10.0;
    self.dateSeperatorViewBottomMargin.constant = 10.0;
    self.displayNickname = YES;
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
                
                if ([self.message isKindOfClass:[SBDUserMessage class]]) {
                    currMessageSender = [(SBDUserMessage *)self.message sender];
                }
                else if ([self.message isKindOfClass:[SBDFileMessage class]]) {
                    currMessageSender = [(SBDFileMessage *)self.message sender];
                }
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.dateSeperatorViewTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                        self.displayNickname = NO;
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

    NSAttributedString *fullMessage = [self buildMessage];
    self.messageLabel.attributedText = fullMessage;
    self.messageLabel.userInteractionEnabled = YES;
    self.messageLabel.linkAttributes = @{
                                         NSFontAttributeName: [DesignConstants messageFont],
                                         NSForegroundColorAttributeName: [DesignConstants incomingMessageColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                         };
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error == nil) {
        NSArray *matches = [detector matchesInString:self.message.message options:0 range:NSMakeRange(0, self.message.message.length)];
        if (matches.count > 0) {
            self.messageLabel.delegate = self;
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            for (NSTextCheckingResult *match in matches) {
                NSRange rangeOfOriginalMessage = [match range];
                NSRange range;
                if (self.displayNickname == YES) {
                    range = NSMakeRange(self.message.sender.nickname.length + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length);
                }
                else {
                    range = rangeOfOriginalMessage;
                }

                [self.messageLabel addLinkToURL:[match URL] withRange:range];
            }
        }
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (NSAttributedString *)buildMessage {
    NSDictionary *nicknameAttribute = nil;
    switch(self.message.sender.nickname.length % 5) {
        case 0:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo0]
                                  };
            break;
        case 1:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo1]
                                  };
            break;
        case 2:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo2]
                                  };
            break;
        case 3:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo3]
                                  };
            break;
        case 4:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo4]
                                  };
            break;
        default:
            nicknameAttribute = @{
                                  NSFontAttributeName: [DesignConstants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [DesignConstants nicknameColorInMessageNo0]
                                  };
            break;
    }

    NSDictionary *messageAttribute = @{
                                       NSFontAttributeName: [DesignConstants messageFont],
                                       NSForegroundColorAttributeName: [DesignConstants incomingMessageColor]
                                       };
    
    NSString *nickname = self.message.sender.nickname;
    
    NSString *message;
    
    //CHECK IF MSG IS CACHED
    NSString *key = [NSString stringWithFormat:@"%@INIDS", self.message.channelUrl];
    NSString *key2 = [NSString stringWithFormat:@"%@INMSGS", self.message.channelUrl];
    
    NSArray *ids = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSDictionary *msgs = [[NSUserDefaults standardUserDefaults] objectForKey:key2];
    NSString *messageIdStr = [NSString stringWithFormat:@"%lld", self.message.messageId];
    message = [msgs valueForKey:messageIdStr];
    if (!message || [message length] == 0) {
       
        //IT'S PRLLY NEW MSG
        NSArray *elems = [self.message.message componentsSeparatedByString:@";"];

        if ([elems count] != 2) {
            message = @"Invalid";
            
        } else {
            
            NSString *nrOne = elems[0];
            NSString *nrtwo = elems[1];
            
            BigInteger *finalA = [[BigInteger alloc] initWithString:nrOne radix:10];
            BigInteger *finalB = [[BigInteger alloc] initWithString:nrtwo radix:10];
            
            NSDictionary *dict = @{
                                   kPCMessageAlphaValueKey: finalA,
                                   kPCMessageBetaValueKey: finalB
                                   };
            
            NSString *partner = self.message.sender.nickname;
            NSDictionary *keys = [[EncryptionManager sharedInstance] getMyKeysFromUserDefaultsForPartner:partner];
            NSString *txt  = [[EncryptionManager sharedInstance] decryptText:dict usingKeys:keys];
            message = txt;
            
            //if the id was added, we need to also add the decryption to the dict in userdef
            NSString *msgIdStr = [NSString stringWithFormat:@"%lld", self.message.messageId];
            if([ids containsObject:msgIdStr]) {
                NSDictionary *msgs = [[NSUserDefaults standardUserDefaults] objectForKey:key2];
                if(!msgs) {
                    msgs = [NSMutableDictionary new];
                }
                NSMutableDictionary *newMsgs = [NSMutableDictionary dictionaryWithDictionary:msgs];
                [newMsgs setValue:txt forKey:msgIdStr];
                NSDictionary *immutableDictionary = [NSDictionary dictionaryWithDictionary:newMsgs];
                [[NSUserDefaults standardUserDefaults] setObject:immutableDictionary forKey:key2];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                
                //add the whole message - user received msg while offline prlly
                NSArray *msgIds = [[NSUserDefaults standardUserDefaults] objectForKey: key];
                if (!msgIds) {
                    msgIds = [NSArray new];
                }
                NSString *msgIdStr = [NSString stringWithFormat:@"%lld", self.message.messageId];
                NSMutableArray *newIds = [NSMutableArray arrayWithArray:msgIds];
                [newIds addObject:msgIdStr];
                NSArray *immutableArray = [NSArray arrayWithArray:newIds];
                
                [[NSUserDefaults standardUserDefaults] setObject:immutableArray forKey:key];
                
                NSDictionary *msgs = [[NSUserDefaults standardUserDefaults] objectForKey:key2];
                if(!msgs) {
                    msgs = [NSMutableDictionary new];
                }
                NSMutableDictionary *newMsgs = [NSMutableDictionary dictionaryWithDictionary:msgs];
                [newMsgs setValue:txt forKey:msgIdStr];
                NSDictionary *immutableDictionary = [NSDictionary dictionaryWithDictionary:newMsgs];
                [[NSUserDefaults standardUserDefaults] setObject:immutableDictionary forKey:key2];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    
    
    NSMutableAttributedString *fullMessage = nil;
    if (self.displayNickname) {
        fullMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", nickname, message]];
        
        [fullMessage addAttributes:nicknameAttribute range:NSMakeRange(0, [nickname length])];
        [fullMessage addAttributes:messageAttribute range:NSMakeRange([nickname length] + 1, [message length])];
    }
    else {
        fullMessage = [[NSMutableAttributedString alloc] initWithString:message];
        [fullMessage addAttributes:messageAttribute range:NSMakeRange(0, [message length])];
    }
    
    return fullMessage;
}

- (CGFloat)getHeightOfViewCell {
    NSAttributedString *fullMessage = [self buildMessage];
    
    CGRect fullMessageRect;
    
    CGFloat messageLabelMaxWidth = self.frame.size.width - (self.profileImageLeftMargin.constant + self.profileImageWidth.constant + self.messageContainerLeftMargin.constant + self.messageContainerLeftPadding.constant + self.messageContainerRightPadding.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant + self.messageDateLabelRightMargin.constant);
    fullMessageRect = [fullMessage boundingRectWithSize:CGSizeMake(messageLabelMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGFloat cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageRect.size.height + self.messageContainerBottomPadding.constant;
    
    return cellHeight;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
