//
//  SafeChatConstantsAndKeys.h
//  SafeChat
//
//  Created by Cristina Pocol on 19/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey   @"com.pc.safechat.kDidSendInitialKey"
#define kSafeChatUserDefaultsLastMessageSent                  @"com.pc.safechat.kLastMessageSent" 
#define kSafeChatUserDefaultsUsernameKey                      @"com.pc.safechat.kUsername"
#define kSafeChatUserDefaultsPasswordKey                      @"com.pc.safechat.kPassword"

#define kSafeChatMaximumMessageLength                         50

#define kSafeChatFirebaseRootUser                             @"users"
#define kSafeChatFirebaseDefaultKeys                          @"defaultKeys"

#define kSafeChatFirebasePrimeNumberKey                       @"primeNumber"
#define kSafeChatFirebaseGeneratorKey                         @"generator"
#define kSafeChatFirebaseGMultiplyingRuleKey                  @"multiplyingRule"


@interface SafeChatConstantsAndKeys : NSObject

@end
