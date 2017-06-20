//
//  ConversationMemberInformationViewController.h
//  SafeChat
//
//  Created by Cristina Pocol on 20/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>


@interface ConversationMemberInformationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) SBDGroupChannel *channel;

@end
