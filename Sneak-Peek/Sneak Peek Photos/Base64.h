//
//  Base64.h
//  Lets Share Vacations
//
//  Created by Roland Thomas on 3/31/15.
//  Copyright (c) 2015 Jedisware, LLC. All rights reserved.
//
// Original Source Code is donated by Cyrus
// Public Domain License
// http://www.cocoadev.com/index.pl?BaseSixtyFour


#import <Foundation/Foundation.h>


@interface Base64 : NSObject {

}

+ (void) initialize;

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;

+ (NSString*) encode:(NSData*) rawBytes;

+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;

+ (NSData*) decode:(NSString*) string;

@end
