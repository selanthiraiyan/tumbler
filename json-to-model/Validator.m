//
//  Validator.m
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "Validator.h"
#import "Condition.h"

@implementation Validator

+ (NSString*)getValidationMethodContent:(NSArray*)conditions
{
    NSMutableString *validationString = [NSMutableString string];

    BOOL ifPrinted = NO;
    for (Condition *condition in conditions) {
        NSString *conditionString = [NSString stringWithFormat:@"%@ (%@)\n"
                                     "{\n"
                                     "NSMutableDictionary* details = [NSMutableDictionary dictionary];\n"
                                     "[details setValue:@\"%@\" forKey:NSLocalizedDescriptionKey];\n"
                                     "*error = [NSError errorWithDomain:@\"Tumbler\" code:200 userInfo:details];\n"
                                     "return NO;\n"
                                     "}\n", ifPrinted?@"else if":@"if", condition.conditionStringInsideIf, condition.userInfoForError];
        [validationString appendString:conditionString];
        ifPrinted = YES;
    }
    [validationString appendString:@"return YES;"];
    return validationString;
}

@end
