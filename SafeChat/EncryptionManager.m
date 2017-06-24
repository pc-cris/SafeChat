//
//  EncryptionManager.m
//  SafeChat
//
//  Created by Cristina Pocol on 17/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "EncryptionManager.h"

//testing
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

#pragma mark -
#pragma mark - Firebase methods

- (NSDictionary*)getReceiverPublicKeys:(NSString*)chattingPartner forUsername:(NSString*)user {
    
    __block NSDictionary *publicKeys = [NSDictionary new];
    //get them from Firebase db
    //TODO: Firebase
    
//    EncryptionManager *__weak weakSelf = self;
//    self.firebaseBlock = ^NSDictionary *(NSDictionary * keys) {
//        return [weakSelf transformStringDictionaryToBigIntegerDictionary:keys];
//    };
    
    dispatch_semaphore_t firebaseSemaphore = dispatch_semaphore_create(0);
    
    [[[[self.reference child:kSafeChatFirebaseRootUser] child:chattingPartner] child:user] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        publicKeys = dict;
        NSUInteger zero = 0;
        if(snapshot.childrenCount == zero) {
            
            [[[[self.reference child:kSafeChatFirebaseRootUser] child: chattingPartner] child:kSafeChatFirebaseDefaultKeys] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                publicKeys = dict;
                NSLog(@"%@",dict);
                dispatch_semaphore_signal(firebaseSemaphore);
                //self.firebaseBlock(dict);
                
            } withCancelBlock:^(NSError * _Nonnull error) {
                NSLog(@"%@", error.localizedDescription);
            }];
        } else {
            //self.firebaseBlock(dict);
            dispatch_semaphore_signal(firebaseSemaphore);
            
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    dispatch_semaphore_wait(firebaseSemaphore, DISPATCH_TIME_FOREVER);
    
    return [self transformStringDictionaryToBigIntegerDictionary:publicKeys];
}

- (NSDictionary*)getReceiverDefaultKeys:(NSString*)chattingPartner {
    
    __block NSDictionary *publicKeys = [NSDictionary new];
    //get them from Firebase db
    //TODO: Firebase
    [[[[self.reference child:kSafeChatFirebaseRootUser] child: chattingPartner] child:kSafeChatFirebaseDefaultKeys] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        publicKeys = dict;
        NSLog(@"%@",dict);

    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    return [self transformStringDictionaryToBigIntegerDictionary:publicKeys];
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
    //TODO: Firebase
    //TODO: MAKE SURE THIS DICT HAS THE PRIVATE KEY AS WELL
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
    
    //TODO: Firebase
    //TODO: MAKE SURE THIS DICT HAS THE PRIVATE KEY AS WELL
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
    
    //
    //TODO: in firebase and userdefaults -> will keep a default value used after the initial creation of the channel and then specific keys for each user: when entering the channel and wanting to read msgs - check in firebase if there is a key associated to that user: if no, use default, if yes, use that one; similarly, when we want to press the send button, check of there is a key associated to our channel: if yes, use it, if no, use default
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

//testing
- (void)generateKeysForTest {
    //[[PCBigNoGenerator sharedInstance] generateKeysAndExposePublicKeysOrUsePregenerated:YES];
    //if(![[[NSUserDefaults standardUserDefaults] valueForKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey] isEqualToString:@"sent"]) {
    BigInteger *privateKey = [[BigInteger alloc] initWithString:@"362008909771623727288212548032952239534395259800083419916" radix:10];
    BigInteger *primeNoKey = [[BigInteger alloc] initWithString:@"66853100275505147362599371325426178636949375166353934946040721080556341318514708808465558967444221878827459081686112246933519808328109817949203457716432893" radix:10];
    BigInteger *generatorKey = [[BigInteger alloc] initWithString:@"2" radix:10];
    BigInteger *thirdKey = [[BigInteger alloc] initWithString:@"27798465687732811764014863005962536388344562483507054993238327504860327962877040525147627927428627707065827163172661367152875187880952610230066501850572137" radix:10];
    
    BigInteger *privateKey2 = [[BigInteger alloc] initWithString:@"77825348746734673676432423656328883464635645637264834823658654658736" radix:10];
    BigInteger *primeNoKey2 = [[BigInteger alloc] initWithString:@"49692968912950770018208519992255398977900559548982780819965926004553666053631043137762676714635828112914291998027957524510229048130944976999118768461004859" radix:10];
    BigInteger *generatorKey2 = [[BigInteger alloc] initWithString:@"2" radix:10];
    BigInteger *thirdKey2 = [generatorKey2 exp:privateKey2 modulo:primeNoKey2];
    
    self.testKeysUserOne = @{
                      kPCPrivateKeyNSUserDefaultsKey:privateKey,
                      kPCPublicKeyPrimeNumberKey:primeNoKey,
                      kPCPublicKeyGeneratorKey:generatorKey,
                      kPCPublicKeyGMultiplyingRuleKey:thirdKey
                      };
    
    self.testKeysUserTwo = @{
                             kPCPrivateKeyNSUserDefaultsKey:privateKey2,
                             kPCPublicKeyPrimeNumberKey: primeNoKey2,
                             kPCPublicKeyGeneratorKey: generatorKey2,
                             kPCPublicKeyGMultiplyingRuleKey: thirdKey2
                             };
    
    
//    NSData *privateKeyData = [NSKeyedArchiver archivedDataWithRootObject:privateKey];
//    [[NSUserDefaults standardUserDefaults] setObject:privateKeyData forKey:kPCPrivateKeyNSUserDefaultsKey];
//    
//    NSData *keyData =       [NSKeyedArchiver archivedDataWithRootObject:primeNoKey];
//    [[NSUserDefaults standardUserDefaults] setObject:keyData       forKey:kPCPublicKeyPrimeNumberKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    //            //NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatUserDefaultsUsernameKey];
    //BOOL didSend = [[EncryptionManager sharedInstance] setUserPublicKeys:publicKeys user:user];
    //if (didSend) {
    //   [[NSUserDefaults standardUserDefaults] setObject:@"sent" forKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey];
    // }
    //}
}

@end
