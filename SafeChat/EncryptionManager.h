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

//- (NSDictionary*)getReceiverPublicKeys:(NSString*)chattingPartner forUsername:(NSString*)user;
- (NSDictionary*)getMyKeysFromUserDefaultsForPartner:(NSString*)partner;

- (NSDictionary*)transformStringDictionaryToBigIntegerDictionary:(NSDictionary*)keys ;

- (BOOL)setUserDefaultPublicKeys:(NSDictionary*)keys user:(NSString*)user;
- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user chattingPartner:(NSString*)partner;

- (NSDictionary*)generateKeysUsePregenerated:(BOOL)usePregenerated;
- (NSDictionary*)encryptText:(NSString*)text usingGeneratedKeys:(NSDictionary*)keys;
- (NSString*)decryptText:(NSDictionary*)text usingKeys:(NSDictionary*)keys;

@property (nonatomic, strong) FIRDatabaseReference *reference;
@property (nonatomic, copy, nullable)NSDictionary* (^firebaseBlock)(NSDictionary*);


//-(void)generateKeysForTest;
@property (nonatomic, strong) NSDictionary *testKeysUserOne;
@property (nonatomic, strong) NSDictionary *testKeysUserTwo;
@end
