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

@import FirebaseDatabase;


@interface EncryptionManager : NSObject

+ (EncryptionManager *)sharedInstance;
+ (void)setSharedInstance:(EncryptionManager *)sharedInstance;
+ (void)resetSharedInstance;

- (NSDictionary*)getReceiverPublicKeys:(NSString*)chattingPartner forUsername:(NSString*)user;
- (NSDictionary*)getMyKeysFromUserDefaultsForPartner:(NSString*)partner;

- (BOOL)setUserDefaultPublicKeys:(NSDictionary*)keys user:(NSString*)user;
- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user chattingPartner:(NSString*)partner;

- (NSDictionary*)generateKeysUsePregenerated:(BOOL)usePregenerated;
- (NSDictionary*)encryptText:(NSString*)text usingGeneratedKeys:(NSDictionary*)keys;
- (NSString*)decryptText:(NSDictionary*)text;

@property (nonatomic, strong) FIRDatabaseReference *reference;


-(void)generateKeysForTest;
@property(nonatomic, strong)NSDictionary *testKeys;

@end
