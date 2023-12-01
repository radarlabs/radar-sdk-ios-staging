//
//  RadarLogBuffer.m
//  RadarSDK
//
//  Copyright © 2021 Radar Labs, Inc. All rights reserved.
//

#import "RadarLogBuffer.h"
#import "RadarLog.h"
#import "RadarFileSystem.h"

static const int MAX_PERSISTED_BUFFER_SIZE = 500;
static const int MAX_MEMORY_BUFFER_SIZE = 200;
static const int PURGE_AMOUNT = 200;

static NSString *const kPurgedLogLine = @"----- purged oldest logs -----";
static NSString *const kDelimiter = @"\?";

@implementation RadarLogBuffer {
    NSMutableArray<RadarLog *> *mutableLogBuffer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        mutableLogBuffer = [NSMutableArray<RadarLog *> new];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *logFileName = @"RadarLogs.txt";
        self.logFilePath = [documentsDirectory stringByAppendingPathComponent:logFileName];
        self.fileHandler = [[RadarFileSystem alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(flushToPersistentStorage) userInfo:nil repeats:YES];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)write:(RadarLogLevel)level type:(RadarLogType)type message:(NSString *)message {
    RadarLog *radarLog = [[RadarLog alloc] initWithLevel:level type:type message:[self strip:message]];
    [mutableLogBuffer addObject:radarLog];
    NSUInteger logLength = [mutableLogBuffer count];
    if (logLength >= MAX_MEMORY_BUFFER_SIZE) {
        [self flushToPersistentStorage]; 
    }
}

- (void)flushToPersistentStorage {
    @synchronized (self) { 
        NSArray *flushableLogs = [mutableLogBuffer copy];
        [self addLogsToBuffer:flushableLogs];
        [mutableLogBuffer removeAllObjects]; 
    }
}

- (NSMutableArray<RadarLog *> *)readFromFileSystem {
    NSData *fileData = [self.fileHandler readFileAtPath:self.logFilePath];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    return [self jsonToLogs:fileString];
}

- (void) writeToFileSystem:(NSMutableArray<RadarLog *> * )logs {
    NSString *updatedLogString = [self logsToJSON:logs];
    NSData *updatedLogData = [updatedLogString dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileHandler writeData:updatedLogData toFileAtPath:self.logFilePath];
}

- (void) append:(RadarLogLevel)level type:(RadarLogType)type message:(NSString *)message {
    @synchronized (self) {
        RadarLog *log = [[RadarLog alloc] initWithLevel:level type:type message:[self strip:message]];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[log dictionaryValue] options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *logString = [NSString stringWithFormat:@"%@%@",kDelimiter ,jsonString];
        NSData *logData = [logString dataUsingEncoding:NSUTF8StringEncoding];
        [self.fileHandler appendData:logData toFileAtPath:self.logFilePath];
    }
}

//strip a message of a log of delimiter
- (NSString *)strip:(NSString *)message {
    return [message stringByReplacingOccurrencesOfString:kDelimiter withString:@""];
}

- (NSString *)logsToJSON:(NSMutableArray<RadarLog *> *)logs {
    NSMutableArray<NSString *> *jsonStrings = [NSMutableArray array];
    for (RadarLog *log in logs) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[log dictionaryValue] options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [jsonStrings addObject:jsonString];
    }
    return [jsonStrings componentsJoinedByString:kDelimiter];
}

- (NSMutableArray<RadarLog *> *)jsonToLogs:(NSString *)json {
    
    if([json length] == 0){
        return [NSMutableArray array];
    }
    if([json hasPrefix:kDelimiter]){
        json = [json substringFromIndex:1];
    }
    
    NSMutableArray<RadarLog *> *logs = [NSMutableArray array];
    NSArray<NSString *> *jsonStrings = [json componentsSeparatedByString:kDelimiter];
    for (NSString *jsonString in jsonStrings) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        RadarLog *log = [[RadarLog alloc] initWithDictionary:jsonDict];
        if(log && log.message){
            [logs addObject:log];
        }
    }
    return logs;
}

- (NSArray<RadarLog *> *)flushableLogs {
    @synchronized (self) {
        [self flushToPersistentStorage];
        NSArray *existingLogsArray = [self.readFromFileSystem copy];
        return existingLogsArray;
    }
}


- (void)removeLogsFromBuffer:(NSUInteger)numLogs {
    @synchronized (self) {
        NSMutableArray *existingLogs = [self readFromFileSystem];
        [existingLogs removeObjectsInRange:NSMakeRange(0, numLogs)];
        [self writeToFileSystem:existingLogs];
    }
}

- (void)addLogsToBuffer:(NSArray<RadarLog *> *)logs {
    @synchronized (self) {
        NSMutableArray *existingLogs = [self readFromFileSystem];
        [existingLogs addObjectsFromArray:logs];
        NSUInteger logLength = [existingLogs count];
        if (logLength >= MAX_PERSISTED_BUFFER_SIZE) {
            [existingLogs removeObjectsInRange:NSMakeRange(0, PURGE_AMOUNT)];
            RadarLog *purgeLog = [[RadarLog alloc] initWithLevel:RadarLogLevelDebug type:RadarLogTypeNone message:kPurgedLogLine];
            [existingLogs insertObject:purgeLog atIndex:0]; 
        }
        [self writeToFileSystem:existingLogs];
    }
}

-(void)clear {
    @synchronized (self) {
        [self.fileHandler deleteFileAtPath:self.logFilePath];
    }
}

@end
