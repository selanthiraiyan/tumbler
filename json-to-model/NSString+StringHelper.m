//
//  NSString+StringHelper.m
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "NSString+StringHelper.h"

@implementation NSString (StringHelper)

- (NSString*)capitalizeFirstLetter {
    NSString *capitalized = [NSString stringWithFormat:@"%c%@", [[self capitalizedString] characterAtIndex:0], [self substringFromIndex:1]];
    return capitalized;
}

- (NSString*)addDoubleValueMethodCall {
    return [NSString stringWithFormat:@"[%@ doubleValue]", self];
}
@end
