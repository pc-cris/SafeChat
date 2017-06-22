//
//  PCBigNoGenerator.m
//  BigNoGenerator
//
//  Created by Cristina Pocol on 16/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "PCBigNoGenerator.h"
#import "PCConstantsAndKeys.h"

static PCBigNoGenerator *instance         = nil;
static dispatch_once_t once_token         = 0;
static NSString *digits                   = @"0123456789";
static NSString *primeNoLastDigits        = @"1379";

@implementation PCBigNoGenerator

#pragma mark -
#pragma mark Singleton methods

+ (PCBigNoGenerator*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[PCBigNoGenerator alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(PCBigNoGenerator *)sharedInstance {
    
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
#pragma mark Key methods

- (NSDictionary*)pregeneratedPrimeNumbers {
    NSDictionary *primes = @{
                                    @"0": [self initializeBigIntWithStr:SmallFirstPrime] ,
                                    @"1": [self initializeBigIntWithStr:SmallSecondPrime],
                                    @"2": [self initializeBigIntWithStr:SmallThirdPrime],
                                    @"3": [self initializeBigIntWithStr:SmallFourthPrime],
                                    @"4": [self initializeBigIntWithStr:SmallFifthPrime],
                                    @"5": [self initializeBigIntWithStr:SmallSixthPrime],
                                    @"6": [self initializeBigIntWithStr:SmallSeventhPrime],
                                    @"7": [self initializeBigIntWithStr:SmallEighthPrime],
                                    @"8": [self initializeBigIntWithStr:SmallNinthPrime],
                                    @"9": [self initializeBigIntWithStr:SmallTenthPrime]
                            };
    
    return primes;
}

- (BigInteger*)initializeBigIntWithStr:(NSString*)str {
    
    return [[BigInteger alloc] initWithString:str radix:10];
    
}

- (NSDictionary*)pregeneratedPrimeFactorsForM {
    
    NSDictionary *primeFactors = @{
                                   SmallFirstPrime: [self initializePrimeFactorsArrayWithArray:SmallFirstPrimeMFactors],
                                   SmallSecondPrime: [self initializePrimeFactorsArrayWithArray:SmallSecondPrimeMFactors],
                                   SmallThirdPrime: [self initializePrimeFactorsArrayWithArray:SmallThirdPrimeMFactors],
                                   SmallFourthPrime: [self initializePrimeFactorsArrayWithArray:SmallFourthPrimeMFactors],
                                   SmallFifthPrime: [self initializePrimeFactorsArrayWithArray:SmallFifthPrimeMFactors],
                                   SmallSixthPrime: [self initializePrimeFactorsArrayWithArray:SmallSixthPrimeMFactors],
                                   SmallSeventhPrime: [self initializePrimeFactorsArrayWithArray:SmallSeventhPrimeMFactors],
                                   SmallEighthPrime: [self initializePrimeFactorsArrayWithArray:SmallEighthPrimeMFactors],
                                   SmallNinthPrime: [self initializePrimeFactorsArrayWithArray:SmallNinthPrimeMFactors],
                                   SmallTenthPrime: [self initializePrimeFactorsArrayWithArray:SmallTenthPrimeMFactors]
                                   };
    
    return  primeFactors;
}

- (NSArray*)initializePrimeFactorsArrayWithArray:(NSArray*)factors {
    
    NSMutableArray *bigIntFactors = [NSMutableArray new];
    for (int i = 0; i < [factors count]; i++) {
        BigInteger *bigInt = [[BigInteger alloc] initWithString:[factors[i] stringByReplacingOccurrencesOfString:@" " withString:@""] radix:10];
        [bigIntFactors addObject:bigInt];
    }
    
    return [NSArray arrayWithArray:bigIntFactors];
}

- (NSDictionary*)pregeneratedGeneratorsForPrime {
    
    NSDictionary *generators = @{
                                 SmallFirstPrime:   SmallFirstPrimeGenerator,
                                 SmallSecondPrime:  SmallSecondPrimeGenerator,
                                 SmallThirdPrime:   SmallThirdPrimeGenerator,
                                 SmallFourthPrime:  SmallFourthPrimeGenerator,
                                 SmallFifthPrime:   SmallFifthPrimeGenerator,
                                 SmallSixthPrime:   SmallSixthPrimeGenerator,
                                 SmallSeventhPrime: SmallSeventhPrimeGenerator,
                                 SmallEighthPrime:  SmallEighthPrimeGenerator,
                                 SmallNinthPrime:   SmallNinthPrimeGenerator,
                                 SmallTenthPrime:   SmallTenthPrimeGenerator
                                 };
    
    return generators;
}

- (NSString*)generateRandomDigitNumberWithSize:(NSUInteger)size {
    
    NSMutableString *key = [NSMutableString stringWithCapacity:size];
    unsigned long counter = 0;
    uint32_t r = 0;
    //generate the first digit - make sure it's not 0; then, generate the remaining digits
    while(r == 0) {
        r = arc4random_uniform((uint32_t)[digits length]);
        if (r != 0) {
            [key appendFormat:@"%C", [digits characterAtIndex:r]];
            r = 10;
        } else {
            r = 0;
        }
    }
    r = 0;
    
    for (counter = (size - 2); counter > 0; counter--) {
        //generate random digits and append them to key
        r = arc4random_uniform((uint32_t)[digits length]);
        [key appendFormat:@"%C", [digits characterAtIndex:r]];
    }
    
    //if we are generating the prime number, we make an improvement and allow the last digit to be only one belonging to primes
    if (size == 617) {
        r = arc4random_uniform((uint32_t)[primeNoLastDigits length]);
        [key appendFormat:@"%C", [digits characterAtIndex:r]];
    } else {
        r =  arc4random_uniform((uint32_t)[digits length]);
        [key appendFormat:@"%C", [digits characterAtIndex:r]];
    }
    
    return [NSString stringWithString:key];
}

- (BigInteger*)generateRandomNumberOfRandomSize {
    
    unsigned int size = 0;
    BOOL isZero = YES;
    while (isZero) {
        size = arc4random_uniform((uint32_t) KeyDigitLength);
        if (size != 0) {
            isZero = NO;
        }
    }
    
    NSString *stringNo = [self generateRandomDigitNumberWithSize:size];
    BigInteger *randomNumber = [[BigInteger alloc] initWithString:stringNo radix:10];
    
    return randomNumber;
}

- (BigInteger*)integerOne {
    
    return [[BigInteger alloc] initWithString:@"1" radix:10];
    
}

- (NSDictionary*)writeNForMillerRabinPrimalityTest:(BigInteger*)number {
    
    BigInteger *nMinusOne = [number sub:[self integerOne]];
    BigInteger *s = [self integerOne];
    BOOL found = NO;
    while (!found) {
        BigInteger *twoPowerS = [[[BigInteger alloc] initWithString:@"2" radix:10] exp:s modulo:[self integerOne]];
        BigInteger *t = [nMinusOne divide:twoPowerS];
        if ([t isOdd]) {
            found = YES;
            
            return @{ @"s": s,
                      @"t": t
                      };
        }
        [s add:[self integerOne]];
    }
    
    return @{};
}

- (BOOL)checkIfRandomNumberIsPrime:(BigInteger*)number {
    
    return [number isProbablePrime];
    
    //use rabin-miller test
//    NSDictionary *sAndT = [self writeNForMillerRabinPrimalityTest:number];
//    
//    if ([[sAndT allKeys] count] == 0) {
//        
//        return NO;
//    }
//    
//    BigInteger *s = [sAndT valueForKey:@"s"];
//    BigInteger *t = [sAndT valueForKey:@"t"];
//    
//    //pctodo - need to check if init with str 1 is ok and if add 1 and minus 2 is ok; seems to be ok
//    int k = 0;
//    for (k = 0; k < TimesToTestForPrimality; k++) {
//        BOOL isSmaller = NO;
//        BigInteger *b;
//        
//        while (!isSmaller) {
//            b = [self generateRandomNumberOfRandomSize];
//            isSmaller = ([b compare:[number subtract:[self integerOne]]] == NSOrderedAscending);
//        }
//        
//        BigInteger *r = [b pow:t andMod:number];
//        
//        if (([r compare:[self integerOne]] != NSOrderedSame) && ([r compare:[number subtract:[self integerOne]]] != NSOrderedSame)) {
//            BigInteger *j = [self integerOne];
//            
//            while (([j compare:[s subtract:[self integerOne]]] == NSOrderedAscending || [j compare:[s subtract:[self integerOne]]] ==  NSOrderedSame) && ([r compare:[number subtract:[self integerOne]]] != NSOrderedSame)) {
//                
//                r = [r pow:[[JKBigInteger alloc] initWithString:@"2"] andMod:number];
//                if ([r compare:[self integerOne]] == NSOrderedSame) {
//                    
//                    return NO;
//                }
//                j = [j add:[self integerOne]];
//            }
//            
//            if ([r compare:[number subtract:[self integerOne]]] != NSOrderedSame) {
//                
//                return NO;
//            }
//        }
//        
//    }
//    
//    return YES;
}

//- (void)selectCyclicGroupOfOrderNAndGeneratorG {
//    //PCTODO
//    NSString *generator = [self findGeneratorG];
//    
//}

- (NSArray*)primeFactorizationOfM:(BigInteger*)m {
    
    NSMutableArray *factors = [NSMutableArray new];
    BigInteger *mForDivision = [[BigInteger alloc] initWithBigInteger:m];
    BigInteger *factor = [[BigInteger alloc] initWithString:@"2" radix:10];
    BigInteger *middleM = [m divide:[[BigInteger alloc] initWithString:@"2" radix:10]];
    
    while (!([factor compare:middleM] == NSOrderedSame)) {
        BOOL shouldAdd = NO;
        BigInteger *copy = [[BigInteger alloc] initWithBigInteger:mForDivision];
        if ([factor isProbablePrime] && [[copy exp:[self integerOne] modulo:factor] isZero]) {
            BOOL stop = ![[mForDivision exp:[self integerOne] modulo:factor] isZero];
            shouldAdd = YES;
            while (!stop) {
                mForDivision = [mForDivision divide:factor];
                stop = [[mForDivision exp:[self integerOne] modulo:factor] isZero];
            }
        }
        
        if(shouldAdd) {
            [factors addObject:factor];
        }
        factor = [factor add:[self integerOne]];
    }
    
    return [[NSArray alloc]initWithArray:factors];
}

- (NSArray*)primeFactorsForMPrimeNumber:(BigInteger*)primeNumber {
    
    NSString *noKey = [NSString stringWithFormat:@"%@", [primeNumber toRadix:10]];
    return [[self pregeneratedPrimeFactorsForM] valueForKey:noKey];
}

- (BigInteger*)findGeneratorG:(BigInteger*)primeNumber {
    
    BigInteger *m = [primeNumber sub:[self integerOne]];
    NSArray *mFactors = [self primeFactorsForMPrimeNumber:primeNumber];
    BigInteger *generator = [[BigInteger alloc] initWithString:@"2" radix:10];
    BOOL gFound = NO;
    while (!gFound && ([generator compare:m] != NSOrderedSame)) {
        BOOL areAllDifferentFromOne = YES;
        unsigned long long index = 0;
        for (index = 0; index < [mFactors count]; index++) {
            BigInteger *exponent = mFactors[index];
            BigInteger *pow = [generator exp:exponent modulo:primeNumber];
            if ([pow compare:[self integerOne]] == NSOrderedSame) {
                areAllDifferentFromOne = NO;
                index = [mFactors count];
                generator = [generator add:[self integerOne]];
            }
        }
        if (areAllDifferentFromOne) {
            gFound = YES;
            return generator;
        }
    }
    
    return [self integerOne];
}

- (BigInteger*)selectPrivateKeyAndSaveItToUserDefaults:(BigInteger*)primeNumber generator:(BigInteger*)generator {
    
    BigInteger *privateKey; 
    BOOL isSmaller = NO;
    BOOL isPKLargeEnough = NO;
    while (!isSmaller && !isPKLargeEnough) {
        privateKey = [self generateRandomNumberOfRandomSize];
        isSmaller = ([privateKey compare:primeNumber] == NSOrderedAscending);
        isPKLargeEnough = ([[generator exp:privateKey modulo:[self integerOne]] compare:primeNumber] == NSOrderedDescending);
    }
    
    return privateKey;
    
//    NSData *privateKeyData = [NSKeyedArchiver archivedDataWithRootObject:privateKey];
//    [[NSUserDefaults standardUserDefaults] setObject:privateKeyData forKey:kPCPrivateKeyNSUserDefaultsKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSDictionary*)computePublicKeysAndOperationInGOrUsePreGenerated:(BOOL)usePregenerated {
    
    BigInteger *key;
    BigInteger *generator;
    
    //if we want to actually generate everything
    if(!usePregenerated) {
        BOOL isKeyPrime = NO;
        //generate keys until we find one that is a prime number
        while (!isKeyPrime) {
            key = [[BigInteger alloc] initWithString:[self generateRandomDigitNumberWithSize:KeyDigitLength] radix:10];
            isKeyPrime = [self checkIfRandomNumberIsPrime:key];
        }
        generator = [self findGeneratorG:key];
        
    } else {
        unsigned int r = arc4random_uniform((uint32_t)9);
        key = [[self pregeneratedPrimeNumbers] valueForKey:[NSString stringWithFormat:@"%d", r]];
        NSString *g = [[self pregeneratedGeneratorsForPrime] valueForKey: [NSString stringWithFormat:@"%@", [key toRadix:10]]];
        generator = [[BigInteger alloc] initWithString:g radix:10] ;
    }
    
    
    //generate the private key
    BigInteger *privateKey = [self selectPrivateKeyAndSaveItToUserDefaults:key generator:generator];
    
//    NSData *privateKeyData = [[NSUserDefaults standardUserDefaults] objectForKey:kPCPrivateKeyNSUserDefaultsKey];
//    BigInteger *privateKey = [NSKeyedUnarchiver unarchiveObjectWithData:privateKeyData];
    
    BigInteger *thirdKey = [generator exp:privateKey modulo:key];
    
//    NSData *keyData =       [NSKeyedArchiver archivedDataWithRootObject:key];
//    NSData *generatorData = [NSKeyedArchiver archivedDataWithRootObject:generator];
//    NSData *thirdKeyData =  [NSKeyedArchiver archivedDataWithRootObject:thirdKey];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:keyData       forKey:kPCPublicKeyPrimeNumberKey];
//    [[NSUserDefaults standardUserDefaults] setObject:generatorData forKey:kPCPublicKeyGeneratorKey];
//    [[NSUserDefaults standardUserDefaults] setObject:thirdKeyData  forKey:kPCPublicKeyGMultiplyingRuleKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *publicKeys = @{
                                   kPCPrivateKeyNSUserDefaultsKey  : privateKey,
                                   kPCPublicKeyPrimeNumberKey      : key,
                                   kPCPublicKeyGeneratorKey        : generator,
                                   kPCPublicKeyGMultiplyingRuleKey : thirdKey
                                  };
    
    return publicKeys;
}

- (NSDictionary*)generateKeysAndExposePublicKeysOrUsePregenerated:(BOOL)usePregenerated {
    
    NSDictionary *publicKeys = [self computePublicKeysAndOperationInGOrUsePreGenerated:usePregenerated];
    
    return publicKeys;
    
}


@end
