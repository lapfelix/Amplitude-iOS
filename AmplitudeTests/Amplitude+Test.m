//
//  Amplitude+Test.m
//  Amplitude
//
//  Created by Allan on 3/11/15.
//  Copyright (c) 2015 Amplitude. All rights reserved.
//

#import "Amplitude.h"
#import "Amplitude+Test.h"
#import "AMPDatabaseHelper.h"

@implementation Amplitude (Test)

@dynamic backgroundQueue;
@dynamic initializerQueue;
@dynamic eventsData;
@dynamic initialized;
@dynamic sessionId;
@dynamic lastEventTime;

- (void)flushQueue {
    [self flushQueueWithQueue:[self backgroundQueue]];
}

- (void)flushQueueWithQueue:(NSOperationQueue*) queue {
    [queue waitUntilAllOperationsAreFinished];
}

- (NSDictionary *)getEvent:(NSInteger) fromEnd {
    NSDictionary *result = [[AMPDatabaseHelper getDatabaseHelper] getEvents:-1 limit:-1];
    NSArray *events = [result objectForKey:@"events"];
    return [events objectAtIndex:[events count] - fromEnd - 1];
}

- (NSDictionary *)getLastEvent {
    NSDictionary *result = [[AMPDatabaseHelper getDatabaseHelper] getEvents:-1 limit:-1];
    NSArray *events = [result objectForKey:@"events"];
    return [events lastObject];
}

- (NSUInteger)queuedEventCount {
    // return [[self eventsData][@"events"] count];
    return [[AMPDatabaseHelper getDatabaseHelper] getEventCount];
}

- (void)flushUploads:(void (^)())handler {
    [self performSelector:@selector(uploadEvents)];
    [self flushQueue];

    // Wait a second for the upload response to get into the queue.
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self flushQueue];
        handler();
    });
}

@end

