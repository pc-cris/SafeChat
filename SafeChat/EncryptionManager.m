//
//  EncryptionManager.m
//  SafeChat
//
//  Created by Cristina Pocol on 17/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "EncryptionManager.h"
#import "SafeChatConstantsAndKeys.h"

static EncryptionManager *instance   = nil;
static dispatch_once_t once_token   = 0;

@implementation EncryptionManager

#pragma mark -
#pragma mark Singleton methods

+ (EncryptionManager*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[EncryptionManager alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(EncryptionManager *)sharedInstance {
    
    once_token = 0;
    instance = sharedInstance;
}

+ (void)resetSharedInstance {
    
    once_token  = 0; // resets the once_token so dispatch_once will run again
    instance    = nil;
}

+ (id)allocWithZone:(NSZone*)zone {
    
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    instance = self;
    self.reference = [[FIRDatabase database] reference];
    return instance;
}

- (NSDictionary*)getMyKeysFromUserDefaultsForPartner:(NSString*)partner {
    
    NSDictionary *keys = [[NSUserDefaults standardUserDefaults] objectForKey:partner];
    
    if (!keys) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatFirebaseDefaultKeys];
    } else {
        return keys;
    }
}

- (NSDictionary*)transformBigIntegerDictionaryToStringDictionary:(NSDictionary*)keys {
    
    NSString *primeNoString   = [[keys valueForKey:kPCPublicKeyPrimeNumberKey] toRadix:10];
    NSString *generatorString = [[keys valueForKey:kPCPublicKeyGeneratorKey] toRadix:10];
    NSString *thirdKeyString  = [[keys valueForKey:kPCPublicKeyGMultiplyingRuleKey] toRadix:10];
    
    NSDictionary *stringDictionary = @{
                                       kSafeChatFirebasePrimeNumberKey: primeNoString,
                                       kSafeChatFirebaseGeneratorKey: generatorString,
                                       kSafeChatFirebaseGMultiplyingRuleKey: thirdKeyString
                                       };
    
    return stringDictionary;
}

- (NSDictionary*)transformStringDictionaryToBigIntegerDictionary:(NSDictionary*)keys {
    
    BigInteger *primeNo   = [[BigInteger alloc] initWithString:[keys valueForKey:kSafeChatFirebasePrimeNumberKey] radix:10];
    BigInteger *generator = [[BigInteger alloc] initWithString:[keys valueForKey:kSafeChatFirebaseGeneratorKey] radix:10];
    BigInteger *thirdKey  = [[BigInteger alloc] initWithString:[keys valueForKey:kSafeChatFirebaseGMultiplyingRuleKey] radix:10];
    
    NSDictionary *bigIntegerDictionary = @{
                                           kPCPublicKeyPrimeNumberKey: primeNo,
                                           kPCPublicKeyGeneratorKey: generator,
                                           kPCPublicKeyGMultiplyingRuleKey: thirdKey
                                           };
    
    return bigIntegerDictionary;
    
}

- (BOOL)setUserDefaultPublicKeys:(NSDictionary*)keys user:(NSString*)user {
    
    //ONLY ONCE CALLED
    //MAKE SURE THIS DICT HAS THE PRIVATE KEY AS WELL
    NSDictionary *defaultKeys = [self transformBigIntegerDictionaryToStringDictionary:keys];
    [[[[self.reference child:kSafeChatFirebaseRootUser] child: user] child: kSafeChatFirebaseDefaultKeys] setValue: defaultKeys];
    
    NSString *privateKeyString = [[keys valueForKey:kPCPrivateKeyNSUserDefaultsKey] toRadix:10];
    
    NSDictionary *userDefaultsDictionary = @{
                                             kPCPrivateKeyNSUserDefaultsKey: privateKeyString,
                                             kPCPublicKeyPrimeNumberKey: [defaultKeys valueForKey:kSafeChatFirebasePrimeNumberKey],
                                             kPCPublicKeyGeneratorKey: [defaultKeys valueForKey:kSafeChatFirebaseGeneratorKey],
                                             kPCPublicKeyGMultiplyingRuleKey: [defaultKeys valueForKey:kSafeChatFirebaseGMultiplyingRuleKey]
                                             };
    
    [[NSUserDefaults standardUserDefaults] setObject:userDefaultsDictionary forKey:kSafeChatFirebaseDefaultKeys];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    return YES;
}

- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user chattingPartner:(NSString*)partner {
    
    //MAKE SURE THIS DICT HAS THE PRIVATE KEY AS WELL
    NSDictionary *stringKeys = [self transformBigIntegerDictionaryToStringDictionary:keys];
    
    [[[[self.reference child:kSafeChatFirebaseRootUser] child: user] child: partner] setValue: stringKeys];
    
    NSString *privateKeyString = [[keys valueForKey:kPCPrivateKeyNSUserDefaultsKey] toRadix:10];
    
    NSDictionary *userDefaultsDictionary = @{
                                             kPCPrivateKeyNSUserDefaultsKey: privateKeyString,
                                             kPCPublicKeyPrimeNumberKey: [stringKeys valueForKey:kSafeChatFirebasePrimeNumberKey],
                                             kPCPublicKeyGeneratorKey: [stringKeys valueForKey:kSafeChatFirebaseGeneratorKey],
                                             kPCPublicKeyGMultiplyingRuleKey: [stringKeys valueForKey:kSafeChatFirebaseGMultiplyingRuleKey]
                                             };
    
    [[NSUserDefaults standardUserDefaults] setObject:userDefaultsDictionary forKey:partner];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

#pragma mark -
#pragma mark - Facade methods

- (NSDictionary*)generateKeysUsePregenerated:(BOOL)usePregenerated {
    
    return [[PCBigNoGenerator sharedInstance] generateKeysAndExposePublicKeysOrUsePregenerated:usePregenerated];
}

- (NSDictionary*)encryptText:(NSString*)text usingGeneratedKeys:(NSDictionary*)keys {
    
    return [[PCEncryptor sharedInstance] encryptMessage:text usingKeys:keys];
}

- (NSString*)decryptText:(NSDictionary*)text usingKeys:(NSDictionary*)keys {
    
    return [[PCDecryptor sharedInstance] decryptMessage:text withKeys:keys];
}

@end
