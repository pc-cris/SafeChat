//
//  Utils.h
//  SafeChat
//
//  Created by Cristina Pocol on 01/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface Utils : NSObject

+ (nullable UIImage *)imageFromColor:(UIColor * _Nonnull)color;
+ (nullable NSAttributedString *)generateNavigationTitle:(NSString * _Nonnull)mainTitle subTitle:(NSString * _Nullable)subTitle;
+ (void)dumpMessages:(NSArray<SBDBaseMessage *> * _Nonnull)messages resendableMessages:(NSDictionary<NSString *, SBDBaseMessage *> * _Nullable)resendableMessages resendableFileData:(NSDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> * _Nullable)resendableFileData preSendMessages:(NSDictionary<NSString *, SBDBaseMessage *> * _Nullable)preSendMessages channelUrl:(NSString * _Nonnull)channelUrl;
+ (void)dumpChannels:(NSArray<SBDBaseChannel *> * _Nonnull)channels;

+ (nullable NSArray<SBDBaseMessage *> *)loadMessagesInChannel:(NSString * _Nonnull)channelUrl;
+ (nullable NSArray<SBDGroupChannel *> *)loadGroupChannels;
@end

