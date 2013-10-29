//
//  Condition.m
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "Condition.h"

@implementation Condition

- (id)init
{
    self = [super init];
    if (self) {
        self.userInfoForError = @"This holds the description about the error.";
    }
    return  self;
}

@end
