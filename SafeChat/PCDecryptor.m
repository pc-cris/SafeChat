//
//  PCDecryptor.m
//  BigNoGenerator
//
//  Created by Cristina Pocol on 16/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "PCDecryptor.h"
#import "PCConstantsAndKeys.h"

static PCDecryptor *instance   = nil;
static dispatch_once_t once_token   = 0;

@implementation PCDecryptor

#pragma mark -
#pragma mark Singleton methods

+ (PCDecryptor*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[PCDecryptor alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(PCDecryptor *)sharedInstance {
    
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
#pragma mark - Class methods

+ (NSString*)transformPCASCIIToMessage:(BigInteger*)message {
    
    NSString *stringMessage = [NSString stringWithFormat:@"%@", message];
    NSMutableString *transformedMessage = [NSMutableString new];
    unsigned long long i;
    
    if ([stringMessage length] % 3 != 0) {
        
        return [NSString new];
    }
    
    for (i = 0; i < [stringMessage length]; i = i + 3) {
        if (i + 3 > [stringMessage length] - 1) {
            return [NSString new];
        }
    
        NSString *keyChars = [stringMessage substringWithRange: NSMakeRange(i, 3)];
        NSString *character = [[PCLookUpASCIITable sharedInstance] PCTextValueForKey:keyChars];
        if ([character length] != 0) {
            [transformedMessage appendString:character];
        }
    }
    
    return transformedMessage;
}

+ (NSString*)decryptMessage:(NSDictionary*)message fromUser:(NSString*)username {
    
    BigInteger *alpha = [message objectForKey:kPCMessageAlphaValueKey];
    BigInteger *beta =  [message objectForKey:kPCMessageBetaValueKey];
    NSData *primeData =  [[NSUserDefaults standardUserDefaults] objectForKey:kPCPublicKeyPrimeNumberKey];
    BigInteger *prime = [NSKeyedUnarchiver unarchiveObjectWithData:primeData];
    NSData *privateKeyData = [[NSUserDefaults standardUserDefaults] objectForKey:kPCPrivateKeyNSUserDefaultsKey];
    BigInteger *privateKey = [NSKeyedUnarchiver unarchiveObjectWithData:privateKeyData];
    
    //JKBigInteger *pMinusOne = [prime subtract:[[JKBigInteger alloc] initWithString:@"1"]];
    //JKBigInteger *pMinusOneMinusA = [[JKBigInteger alloc] initWithString:@"0"];
    //pMinusOneMinusA = [pMinusOne subtract:privateKey];
    BigInteger *onePlusA = [privateKey add:[[BigInteger alloc] initWithString:@"1" radix:10]];
    BigInteger *pMinusOneMinusA = [[BigInteger alloc]init];
    pMinusOneMinusA = [prime sub:onePlusA];
    
    BigInteger *prePreM = [[BigInteger alloc] init];
    prePreM = [alpha exp:pMinusOneMinusA modulo:prime];
    
    BigInteger *preM = [prePreM multiply:beta];
    BigInteger *m = [preM multiply:[[BigInteger alloc] initWithString:@"1" radix:10] modulo:prime];
    
    return [self transformPCASCIIToMessage:m];
}

@end
