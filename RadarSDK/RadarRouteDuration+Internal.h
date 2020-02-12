//
//  RadarRouteDuration+Internal.h
//  RadarSDK
//
//  Copyright © 2020 Radar Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadarRouteDuration.h"

@interface RadarRouteDuration ()

- (instancetype _Nullable)initWithValue:(double)value
                                   text:(nonnull NSString *)text;

- (instancetype _Nullable)initWithObject:(id _Nonnull)object;

@end
