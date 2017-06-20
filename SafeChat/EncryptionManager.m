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
    return instance;
}

#pragma mark -
#pragma mark - Firebase methods

- (NSDictionary*)getReceiverPublicKeys:(NSString*)username {
    
    NSDictionary *publicKeys = [NSDictionary new];
    //get them from Firebase db
    
    return publicKeys;
}

- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user {
    
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

- (NSString*)decryptText:(NSDictionary*)text {
    
    return [[PCDecryptor sharedInstance] decryptMessage:text];
}

//testing
- (void)generateKeysForTest {
    //[[PCBigNoGenerator sharedInstance] generateKeysAndExposePublicKeysOrUsePregenerated:YES];
        //if(![[[NSUserDefaults standardUserDefaults] valueForKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey] isEqualToString:@"sent"]) {
    BigInteger *privateKey = [[BigInteger alloc] initWithString:@"362008909771623727288212548032952239534395259800083419916" radix:10];
    BigInteger *primeNoKey = [[BigInteger alloc] initWithString:@"66853100275505147362599371325426178636949375166353934946040721080556341318514708808465558967444221878827459081686112246933519808328109817949203457716432893" radix:10];
    BigInteger *generatorKey = [[BigInteger alloc] initWithString:@"2" radix:10];
    BigInteger *thirdKey = [[BigInteger alloc] initWithString:@"27798465687732811764014863005962536388344562483507054993238327504860327962877040525147627927428627707065827163172661367152875187880952610230066501850572137" radix:10];
    
    self.testKeys = @{
                      kPCPrivateKeyNSUserDefaultsKey:privateKey,
                      kPCPublicKeyPrimeNumberKey:primeNoKey,
                          kPCPublicKeyGeneratorKey:generatorKey,
                          kPCPublicKeyGMultiplyingRuleKey:thirdKey
                      };
    
    NSData *privateKeyData = [NSKeyedArchiver archivedDataWithRootObject:privateKey];
    [[NSUserDefaults standardUserDefaults] setObject:privateKeyData forKey:kPCPrivateKeyNSUserDefaultsKey];
    
    NSData *keyData =       [NSKeyedArchiver archivedDataWithRootObject:primeNoKey];
    [[NSUserDefaults standardUserDefaults] setObject:keyData       forKey:kPCPublicKeyPrimeNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
//            //NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatUserDefaultsUsernameKey];
            //BOOL didSend = [[EncryptionManager sharedInstance] setUserPublicKeys:publicKeys user:user];
            //if (didSend) {
             //   [[NSUserDefaults standardUserDefaults] setObject:@"sent" forKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey];
           // }
        //}
}

@end
