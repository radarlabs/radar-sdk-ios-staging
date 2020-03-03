//
//  RadarContext+Internal.h
//  RadarSDK
//
//  Created by Cory Pisano on 1/30/20.
//  Copyright © 2020 Radar Labs, Inc. All rights reserved.
//

#import "RadarContext.h"
#import "RadarGeofence.h"
#import "RadarUserInsights.h"
#import <Foundation/Foundation.h>

@interface RadarContext ()

- (instancetype _Nullable)initWithGeofences:(NSArray* _Nonnull)geofences
                                      place:(RadarPlace* _Nullable)place
                                    country:(RadarRegion* _Nullable)country
                                      state:(RadarRegion* _Nullable)state
                                        dma:(RadarRegion* _Nullable)dma
                                 postalCode:(RadarRegion* _Nullable)postalCode;

- (instancetype _Nullable)initWithObject:(id _Nonnull)object;

@end
