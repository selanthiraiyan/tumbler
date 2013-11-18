//
//  Condition.h
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Condition : NSObject

@property (strong) NSString *conditionStringInsideIf;
@property (strong) NSString *userInfoForError;
@property BOOL isCustomErrorMessageSpecified;

@end
