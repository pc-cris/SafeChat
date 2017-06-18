//
//  EncryptionManager.h
//  SafeChat
//
//  Created by Cristina Pocol on 17/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCBigNoGenerator.h"
#import "PCEncryptor.h"
#import "PCDecryptor.h"

@interface EncryptionManager : NSObject

+ (EncryptionManager *)sharedInstance;
+ (void)setSharedInstance:(EncryptionManager *)sharedInstance;
+ (void)resetSharedInstance;
- (NSDictionary*)getReceiverPublicKeys:(NSString*)username;
- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user;
- (NSDictionary*)generateKeysUsePregenerated:(BOOL)usePregenerated;
- (NSDictionary*)encryptText:(NSString*)text usingGeneratedKeys:(NSDictionary*)keys;
- (NSString*)decryptText:(NSDictionary*)text;

@end
