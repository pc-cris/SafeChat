//
//  1-to-1ConversationViewController.h
//  SafeChat
//
//  Created by Cristina Pocol on 03/04/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "ChattingView.h"
#import "MessageDelegate.h"

@interface OneToOneConversationViewController : UIViewController<SBDConnectionDelegate, SBDChannelDelegate, ChattingViewDelegate, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) SBDGroupChannel *channel;

@end
