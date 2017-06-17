//
//  PCLookUpASCIITable.m
//  BigNoGenerator
//
//  Created by Cristina Pocol on 12/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "PCLookUpASCIITable.h"

static PCLookUpASCIITable *instance   = nil;
static dispatch_once_t once_token   = 0;

@implementation PCLookUpASCIITable

#pragma mark -
#pragma mark Singleton methods

+ (PCLookUpASCIITable*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[PCLookUpASCIITable alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(PCLookUpASCIITable *)sharedInstance {
    
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

- (NSDictionary*)textToASCIILookUpDictionary {
    NSDictionary *myASCIIDictionary = @{
                                        @" ":@"0",
                                        @"a":@"1",
                                        @"b":@"2",
                                        @"c":@"3",
                                        @"d":@"4",
                                        @"e":@"5",
                                        @"f":@"6",
                                        @"g":@"7",
                                        @"h":@"8",
                                        @"i":@"9",
                                        @"j":@"10",
                                        @"k":@"11",
                                        @"l":@"12",
                                        @"m":@"13",
                                        @"n":@"14",
                                        @"o":@"15",
                                        @"p":@"16",
                                        @"q":@"17",
                                        @"r":@"18",
                                        @"s":@"19",
                                        @"t":@"20",
                                        @"u":@"21",
                                        @"v":@"22",
                                        @"w":@"23",
                                        @"x":@"24",
                                        @"y":@"25",
                                        @"z":@"26",
                                        @"A":@"27",
                                        @"B":@"28",
                                        @"C":@"29",
                                        @"D":@"30",
                                        @"E":@"31",
                                        @"F":@"32",
                                        @"G":@"33",
                                        @"H":@"34",
                                        @"I":@"35",
                                        @"J":@"36",
                                        @"K":@"37",
                                        @"L":@"38",
                                        @"M":@"39",
                                        @"N":@"40",
                                        @"O":@"41",
                                        @"P":@"42",
                                        @"Q":@"43",
                                        @"R":@"44",
                                        @"S":@"45",
                                        @"T":@"46",
                                        @"U":@"47",
                                        @"V":@"48",
                                        @"W":@"49",
                                        @"X":@"50",
                                        @"Y":@"51",
                                        @"Z":@"52",
                                        @"0":@"53",
                                        @"1":@"54",
                                        @"2":@"55",
                                        @"3":@"56",
                                        @"4":@"57",
                                        @"5":@"58",
                                        @"6":@"59",
                                        @"7":@"60",
                                        @"8":@"61",
                                        @"9":@"62",
                                        @".":@"63",
                                        @"-":@"64",
                                        @"/":@"65",
                                        @":":@"66",
                                        @";":@"67",
                                        @"(":@"68",
                                        @")":@"69",
                                        @"$":@"70",
                                        @"&":@"71",
                                        @"@":@"72",
                                        @"\"":@"73",
                                        @",":@"74",
                                        @"?":@"75",
                                        @"!":@"76",
                                        @"'":@"77",
                                        @"[":@"78",
                                        @"]":@"79",
                                        @"{":@"80",
                                        @"}":@"81",
                                        @"#":@"82",
                                        @"%":@"83",
                                        @"^":@"84",
                                        @"*":@"85",
                                        @"+":@"86",
                                        @"=":@"87",
                                        @"_":@"88",
                                        @"\\":@"89",
                                        @"|":@"90",
                                        @"~":@"91",
                                        @"<":@"92",
                                        @">":@"93",
                                        @"€":@"94",
                                        @"£":@"95",
                                        @"¥":@"96",
                                        @"•":@"97"
                                            };
    return myASCIIDictionary;
}

- (NSDictionary*)ASCIIToTextLookUpDictionary {
    NSDictionary *myTextDictionary = @{
                                       @"0":@" ",
                                       @"1":@"a",
                                       @"2":@"b",
                                       @"3":@"c",
                                       @"4":@"d",
                                       @"5":@"e",
                                       @"6":@"f",
                                       @"7":@"g",
                                       @"8":@"h",
                                       @"9":@"i",
                                       @"10":@"j",
                                       @"11":@"k",
                                       @"12":@"l",
                                       @"13":@"m",
                                       @"14":@"n",
                                       @"15":@"o",
                                       @"16":@"p",
                                       @"17":@"q",
                                       @"18":@"r",
                                       @"19":@"s",
                                       @"20":@"t",
                                       @"21":@"u",
                                       @"22":@"v",
                                       @"23":@"w",
                                       @"24":@"x",
                                       @"25":@"y",
                                       @"26":@"z",
                                       @"27":@"A",
                                       @"28":@"B",
                                       @"29":@"C",
                                       @"30":@"D",
                                       @"31":@"E",
                                       @"32":@"F",
                                       @"33":@"G",
                                       @"34":@"H",
                                       @"35":@"I",
                                       @"36":@"J",
                                       @"37":@"K",
                                       @"38":@"L",
                                       @"39":@"M",
                                       @"40":@"N",
                                       @"41":@"O",
                                       @"42":@"P",
                                       @"43":@"Q",
                                       @"44":@"R",
                                       @"45":@"S",
                                       @"46":@"T",
                                       @"47":@"U",
                                       @"48":@"V",
                                       @"49":@"W",
                                       @"50":@"X",
                                       @"51":@"Y",
                                       @"52":@"Z",
                                       @"53":@"0",
                                       @"54":@"1",
                                       @"55":@"2",
                                       @"56":@"3",
                                       @"57":@"4",
                                       @"58":@"5",
                                       @"59":@"6",
                                       @"60":@"7",
                                       @"61":@"8",
                                       @"62":@"9",
                                       @"63":@".",
                                       @"64":@"-",
                                       @"65":@"/",
                                       @"66":@":",
                                       @"67":@";",
                                       @"68":@"(",
                                       @"69":@")",
                                       @"70":@"$",
                                       @"71":@"&",
                                       @"72":@"@",
                                       @"73":@"\"",
                                       @"74":@",",
                                       @"75":@"?",
                                       @"76":@"!",
                                       @"77":@"'",
                                       @"78":@"[",
                                       @"79":@"]",
                                       @"80":@"{",
                                       @"81":@"}",
                                       @"82":@"#",
                                       @"83":@"%",
                                       @"84":@"^",
                                       @"85":@"*",
                                       @"86":@"+",
                                       @"87":@"=",
                                       @"88":@"_",
                                       @"89":@"\\",
                                       @"90":@"|",
                                       @"91":@"~",
                                       @"92":@"<",
                                       @"93":@">",
                                       @"94":@"€",
                                       @"95":@"£",
                                       @"96":@"¥",
                                       @"97":@"•"
                                       };
    return myTextDictionary;
}

- (NSString*)PCASCIIValueForKey:(NSString*)key {
    
    if (![[[self textToASCIILookUpDictionary] allKeys] containsObject:key]) {
        return [NSString new];
    }
    if ([key isEqualToString:@"@"]) {
        return [NSString stringWithFormat:@"%lu", (unsigned long)72];
    }
    NSString *value = [[self textToASCIILookUpDictionary] valueForKey:key];
    NSUInteger code = [value integerValue] + 100;
    
    return [NSString stringWithFormat:@"%lu", (unsigned long)code];
}

- (NSString*)PCTextValueForKey:(NSString*)key {
    
    NSUInteger code = [key integerValue] - 100; 
    NSString *keyStr = [NSString stringWithFormat:@"%lu", (unsigned long)code];
    if([keyStr isEqualToString:@"72"]) {
        return [NSString stringWithFormat:@"%@", @"@"];
    }
    
    if (![[[self ASCIIToTextLookUpDictionary] allKeys] containsObject:keyStr]) {
        return [NSString new];
    }
    
    return [[self ASCIIToTextLookUpDictionary] valueForKey:keyStr];
}

@end
