//
//  RadarState.m
//  RadarSDK
//
//  Copyright © 2019 Radar Labs, Inc. All rights reserved.
//

#import "RadarState.h"

#import "RadarUtils.h"

@implementation RadarState

static NSString *const kLastMovedLocation = @"radar-lastMovedLocation";
static NSString *const kLastMovedAt = @"radar-lastMovedAt";
static NSString *const kStopped = @"radar-stopped";
static NSString *const kLastSentAt = @"radar-lastSentAt";
static NSString *const kCanExit = @"radar-canExit";
static NSString *const kLastFailedStoppedLocation = @"radar-lastFailedStoppedLocation";

+ (CLLocation *)lastMovedLocation {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLastMovedLocation];
    CLLocation *lastMovedLocation = [RadarUtils locationForDictionary:dict];

    if (![RadarUtils validLocation:lastMovedLocation]) {
        return nil;
    }

    return lastMovedLocation;
}

+ (void)setLastMovedLocation:(CLLocation *)lastMovedLocation {
    if (!lastMovedLocation || ![RadarUtils validLocation:lastMovedLocation]) {
        return;
    }

    NSDictionary *dict = [RadarUtils dictionaryForLocation:lastMovedLocation];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLastMovedLocation];
}

+ (NSDate *)lastMovedAt {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastMovedAt];
}

+ (void)setLastMovedAt:(NSDate *)lastMovedAt {
    [[NSUserDefaults standardUserDefaults] setObject:lastMovedAt forKey:kLastMovedAt];
}

+ (BOOL)stopped {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kStopped];
}

+ (void)setStopped:(BOOL)stopped {
    [[NSUserDefaults standardUserDefaults] setBool:stopped forKey:kStopped];
}

+ (void)updateLastSentAt {
    NSDate *now = [NSDate new];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:kLastSentAt];
}

+ (NSDate *)lastSentAt {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kLastSentAt];
}

+ (BOOL)canExit {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCanExit];
}

+ (void)setCanExit:(BOOL)canExit {
    [[NSUserDefaults standardUserDefaults] setBool:canExit forKey:kCanExit];
}

+ (CLLocation *)lastFailedStoppedLocation {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLastFailedStoppedLocation];
    CLLocation *lastFailedStoppedLocation = [RadarUtils locationForDictionary:dict];

    if (!lastFailedStoppedLocation || ![RadarUtils validLocation:lastFailedStoppedLocation]) {
        return nil;
    }

    return lastFailedStoppedLocation;
}

+ (void)setLastFailedStoppedLocation:(CLLocation *)lastFailedStoppedLocation {
    if (!lastFailedStoppedLocation || ![RadarUtils validLocation:lastFailedStoppedLocation]) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLastFailedStoppedLocation];

        return;
    }

    NSDictionary *dict = [RadarUtils dictionaryForLocation:lastFailedStoppedLocation];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLastFailedStoppedLocation];
}

@end
