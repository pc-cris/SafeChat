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

- (NSString*)generateRandomDigitNumberWithSize:(NSUInteger)size {
    
    NSMutableString *key = [NSMutableString stringWithCapacity:size];
    int counter = 0;
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
    for (counter = (size - 3); counter >= 0; counter--) {
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
    BOOL isZero = NO;
    while (!isZero) {
        size = arc4random_uniform((uint32_t) KeyDigitLength);
        isZero = (size == 0);
    }
    
    NSString *stringNo = [self generateRandomDigitNumberWithSize:size];
    BigInteger *randomNumber = [[BigInteger alloc] initWithString:stringNo radix:10];
    
    return randomNumber;
}

- (BigInteger*)integerOne {
    
    return [[BigInteger alloc] initWithString:@"1" radix:10];
    
}

- (NSDictionary*)writeNForMillerRabinPrimalityTest:(BigInteger*)number {
    
//    BigInteger *nMinusOne = [number sub:[self integerOne]];
//    BigInteger *s = [self integerOne];
//    BOOL found = NO;
//    while (!found) {
//        BigInteger *twoPowerS = [[[BigInteger alloc] initWithString:@"2" radix:10] exp:s modulo:[self integerOne]];
//        BigInteger *t = [nMinusOne divide:twoPowerS];
//        NSArray *divResult = [t divideAndRemainder:[[JKBigInteger alloc]initWithString:@"2"]];
//        BigInteger *remainder = divResult[1];
//        if ([remainder compare:[self integerOne]] == NSOrderedSame) {
//            found = YES;
//            
//            return @{ @"s": s,
//                      @"t": t
//                      };
//        }
//        [s add:[self integerOne]];
//    }
    
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
    
    //for (factor = [[BigInteger alloc] initWithString:@"2" radix:10]; [factor compare:middleM] == NSOrderedSame; factor = [factor add:[self integerOne]]) {
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

- (BigInteger*)findGeneratorG:(BigInteger*)primeNumber {
    //PCTODO
    BigInteger *m = [primeNumber sub:[self integerOne]];
    NSArray *mFactors = [self primeFactorizationOfM:m];
    BigInteger *generator = [[BigInteger alloc] initWithString:@"2" radix:10];
    BOOL gFound = NO;
    while (!gFound) {
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
    
    
    //    JKBigInteger *i = [self integerOne];
    //    JKBigInteger *r = [[JKBigInteger alloc]initWithString:@""];
    //    JKBigInteger *n = [[JKBigInteger alloc]initWithString:@""];
    //
    //    for (i = [self integerOne]; [i compare:r] == NSOrderedSame; [i add:[self integerOne]]) {
    //        JKBigInteger *pi = [[JKBigInteger alloc]initWithString:@""];
    //        JKBigInteger *fraction = [n divide:pi];
    //        JKBigInteger *a = [gElem pow:fraction andMod:[self integerOne]];
    //        if ([a compare:[self integerOne]] == NSOrderedSame) {
    //            gElem = [[JKBigInteger alloc]initWithString:@""];
    //        }
    //    }
    //return gElem;
    
}

- (void)selectPrivateKeyAndSaveItToUserDefaults:(BigInteger*)primeNumber {
    
    //test
    BigInteger *privateKey; //= [[BigInteger alloc]initWithString:@"1751" radix:10];
    BOOL isSmaller = NO;
    while (!isSmaller) {
        privateKey = [self generateRandomNumberOfRandomSize];
        isSmaller = ([privateKey compare:primeNumber] == NSOrderedAscending);
    }
    
    NSData *privateKeyData = [NSKeyedArchiver archivedDataWithRootObject:privateKey];
    [[NSUserDefaults standardUserDefaults] setObject:privateKeyData forKey:kPCPrivateKeyNSUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSDictionary*)computePublicKeysAndOperationInG {
    
    BOOL isKeyPrime = NO;
    BigInteger *key; // = [[BigInteger alloc] initWithString:@"2357" radix:10];
    //generate keys until we find one that is a prime number
    while (!isKeyPrime) {
        key = [[BigInteger alloc] initWithString:[self generateRandomDigitNumberWithSize:KeyDigitLength] radix:10];
        isKeyPrime = [self checkIfRandomNumberIsPrime:key];
    }
    
    //generate and save the private key
    [self selectPrivateKeyAndSaveItToUserDefaults:key];
    
    BigInteger *generator = [self findGeneratorG:key];
    NSData *privateKeyData = [[NSUserDefaults standardUserDefaults] objectForKey:kPCPrivateKeyNSUserDefaultsKey];
    BigInteger *privateKey = [NSKeyedUnarchiver unarchiveObjectWithData:privateKeyData];
    
    ///!!!! PCTODO - MUST MAKE SURE generator pow power > KEY!!! IF NOT, GENERATE ANOTHER a
    BigInteger *thirdKey = [generator exp:privateKey modulo:key];
    
    NSData *keyData =       [NSKeyedArchiver archivedDataWithRootObject:key];
    NSData *generatorData = [NSKeyedArchiver archivedDataWithRootObject:generator];
    NSData *thirdKeyData =  [NSKeyedArchiver archivedDataWithRootObject:thirdKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:keyData       forKey:kPCPublicKeyPrimeNumberKey];
    [[NSUserDefaults standardUserDefaults] setObject:generatorData forKey:kPCPublicKeyGeneratorKey];
    [[NSUserDefaults standardUserDefaults] setObject:thirdKeyData  forKey:kPCPublicKeyGMultiplyingRuleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *publicKeys = @{ kPCPublicKeyPrimeNumberKey      : key,
                                   kPCPublicKeyGeneratorKey         : generator,
                                   kPCPublicKeyGMultiplyingRuleKey : thirdKey
                                  };
    
    return publicKeys;
}

- (BOOL)generateKeysAndExposePublicKeys {
    
    NSDictionary *publicKeys = [self computePublicKeysAndOperationInG];
    //send them to firebase server
    //With Firebase, the key is a URL and the value is arbitrary data that could be a number, string, boolean or object.
    //let ref = FIRDatabase.database().reference(withPath: "user-public-keys") -> json root
    //it will look like:
    
    // The root of the tree
    //    {
    //        // grocery-items
    //        "grocery-items": {
    //
    //            // grocery-items/milk
    //            "milk": {
    //
    //                // grocery-items/milk/name
    //                "name": "Milk",
    //
    //                // grocery-items/milk/addedByUser
    //                "addedByUser": "David"
    //            },
    //
    //            "pizza": {
    //                "name": "Pizza",
    //                "addedByUser": "Alice"
    //            },
    //        }
    //    }
    //https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
    //    let groceryItemRef = self.ref.child(text.lowercased()) - create a new child node -> we will use the username of the current user for this
    //
    //    // 4
    //    groceryItemRef.setValue(groceryItem.toAnyObject()) -  set the dictionary directly to save it to the db
    
    
    //refHandle = [_postRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //    NSDictionary *postDict = snapshot.value;
    //    // ...
    //}];
    
    
    return YES;
    
}


@end
