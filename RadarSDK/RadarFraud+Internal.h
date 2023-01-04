//
//  RadarFraud+Internal.h
//  RadarSDK
//
//  Copyright © 2021 Radar Labs, Inc. All rights reserved.
//

#import "RadarFraud+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface RadarFraud ()

- (instancetype _Nonnull)initWithProxy:(BOOL)proxy mocked:(BOOL)mocked compromised:(BOOL)compromised jumped:(BOOL)jumped;
- (instancetype _Nullable)initWithObject:(id _Nonnull)object;

@end

NS_ASSUME_NONNULL_END
