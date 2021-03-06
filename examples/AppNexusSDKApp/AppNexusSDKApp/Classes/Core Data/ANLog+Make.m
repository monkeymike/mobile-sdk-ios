/*   Copyright 2013 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ANLog+Make.h"

#define LOG_LIMIT 2000
#define LOG_NUM_TO_DEL 200

@implementation ANLog (Make)

static int logCount = LOG_LIMIT;

+ (void)storeLogOutput:(NSString *)output
              withName:(NSString *)name
                onDate:(NSDate *)date
  withOriginatingClass:(NSString *)originatingClass
          fromAppNexus:(BOOL)isAppNexus
         withProcessID:(NSInteger)processID
inManagedObjectContext:(NSManagedObjectContext *)context {
    ANLog *log = nil;
    if (context) {
        log = [NSEntityDescription insertNewObjectForEntityForName:@"ANLog" inManagedObjectContext:context];
        log.datetime = date;
        log.originatingClass = originatingClass;
        log.isAppNexus = [NSNumber numberWithBool:isAppNexus];
        log.output = output;
        log.name = name;
        log.processID = [NSNumber numberWithInteger:processID];
        log.text = [ANLog generateTextWithLogOutput:output
                                           withName:name
                                             onDate:date
                               withOriginatingClass:originatingClass
                                       fromAppNexus:isAppNexus
                                      withProcessID:processID];
        
        logCount++;
        [ANLog deleteExcessLogs:context];
    }
}

+ (NSString *)generateTextWithLogOutput:(NSString *)output
                               withName:(NSString *)name
                                 onDate:(NSDate *)date
                withOriginatingClass:(NSString *)originatingClass
                        fromAppNexus:(BOOL)isAppNexus
                        withProcessID:(NSInteger)processID {
    NSString *d = date ? [NSString stringWithFormat:@"%@\n", date] : @"";
    NSString *n = name || [name length] ? [NSString stringWithFormat:@"%@\n", name] : @"";
    NSString *cn = originatingClass || [originatingClass length] ? [NSString stringWithFormat:@"%@\n", originatingClass] : @"";
    NSString *pid = processID ? [NSString stringWithFormat:@"PID: %d\n", processID] : @"";
    NSString *o = output || [output length] ? output : @"";
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",d,n,cn,pid,o];
    return text;
}

+ (void)deleteExcessLogs:(NSManagedObjectContext *)context {
    // keep a counter in memory so that we don't do heavy stuff every time
    if (logCount < LOG_LIMIT) {
        return;
    }
    
    // first time, or we're past the log limit
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ANLog"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // delete so that we have (LOG_LIMIT - LOG_NUM_TO_DEL) logs in the store
    if (matches) {
        NSLog(@"%@ %@ | Logs Count before deleting: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [matches count]);
        int limitIndex = [matches count] - (LOG_LIMIT - LOG_NUM_TO_DEL);
        for (int i = 0; i < limitIndex; i++) {
            [context deleteObject:[matches objectAtIndex:i]];
        }
    }

    // update log count
    matches = [context executeFetchRequest:request error:&error];
    if (matches) {
        NSLog(@"%@ %@ | Logs Count after deleting: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [matches count]);
        logCount = [matches count];
    }
}


@end