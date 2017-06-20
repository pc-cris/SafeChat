//
//  PCEncryptor.m
//  BigNoGenerator
//
//  Created by Cristina Pocol on 16/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "PCEncryptor.h"
#import "PCConstantsAndKeys.h"

static PCEncryptor *instance   = nil;
static dispatch_once_t once_token   = 0;


@implementation PCEncryptor

#pragma mark -
#pragma mark Singleton methods

+ (PCEncryptor*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[PCEncryptor alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(PCEncryptor *)sharedInstance {
    
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

- (NSString*)transformMessageToPCASCII:(NSString*)message {
    
    NSMutableString *transformedMessage = [NSMutableString new];
    unsigned long long i;
    for (i = 0; i < [message length]; i++) {
        NSString *code = [[PCLookUpASCIITable sharedInstance] PCASCIIValueForKey:[NSString stringWithFormat:@"%C", [message characterAtIndex:i]]];
        if ([code length] != 0) {
            [transformedMessage appendString:code];
        }
    }
    
    return [NSString stringWithString:transformedMessage];
}

- (NSDictionary*)encryptMessage:(NSString*)message usingKeys:(NSDictionary*)keys {
    
    BigInteger *prime =  [keys valueForKey:kPCPublicKeyPrimeNumberKey];
    BigInteger *avalue = [keys valueForKey:kPCPublicKeyGMultiplyingRuleKey];
    BigInteger *pMinusTwo = [[BigInteger alloc] initWithString:@"0" radix:10];
    pMinusTwo = [prime sub:[[BigInteger alloc] initWithString:@"2" radix:10]];
    BigInteger *generator = [keys valueForKey:kPCPublicKeyGeneratorKey];
    BigInteger *random;
    
    BOOL isSmaller = NO;
    while (!isSmaller) {
         random = [[PCBigNoGenerator sharedInstance] generateRandomNumberOfRandomSize];
        if ([random compare:pMinusTwo] == NSOrderedAscending) {
            isSmaller = YES;
        }
    }
    
    BigInteger *alpha = [self computeAlphaWithGValue:generator andKValue:random andPValue:prime];
    BigInteger *beta = [self computeBetaWithMValue:[self transformMessageToPCASCII:message] andGAValue:avalue andKValue:random andPValue:prime];
    
    NSDictionary *encryptedMessage = @{ kPCMessageAlphaValueKey:[alpha toRadix:10],
                                          kPCMessageBetaValueKey:[beta toRadix:10]
                                        };
    
    return encryptedMessage;
}

- (BigInteger*)computeAlphaWithGValue:(BigInteger*)g andKValue:(BigInteger*)k andPValue:(BigInteger*)p {
    
    BigInteger *alpha = [g exp:k modulo:p];
    
    return alpha;
}

- (BigInteger*)computeBetaWithMValue:(NSString*)m andGAValue:(BigInteger*)ga andKValue:(BigInteger*)k andPValue:(BigInteger*)p {
    
    BigInteger *gakmodp = [ga exp:k modulo:p];
    BigInteger *mes = [[BigInteger alloc] initWithString:m radix:10];
    BigInteger *beta = [mes multiply:gakmodp];
    
    return [beta multiply:[[BigInteger alloc] initWithString:@"1" radix:10] modulo:p];
}


@end
