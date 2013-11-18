//
//  JSONModelBaseProtocol.h
//  JSON Test
//
//  Created by Sharma Elanthiraiyan on 7/5/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONModelBaseProtocol <NSObject>

@required
- (NSString*)getServletName;
- (NSString*)getServletGroup;
- (NSString*)getServletVersion;
- (NSString*)getClassNamePrefix;
- (NSDictionary*)toDict;
- (id)initWithDict:(NSDictionary*)dict;

//For validation purpose
- (BOOL)isValid:(NSError**)error;

@end
