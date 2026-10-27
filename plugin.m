#import "../../srcs/HanamiPlugin.h"
#import "../../srcs/HanamiConfig.h"
#import <Mayushii.h>

@interface YzuPlugin: OFObject <HanamiPlugin>
@end

Class HanamiPluginClass(void) {
    return [YzuPlugin class];
}

@implementation YzuPlugin {
    OFMutableDictionary *__block results;
    OFMutableArray *ops;
}

- (void)createScheduledOperations {
    MYScheduledOperation *hostStatsOp = [MYScheduledOperation schedule:60 operation:^(void){
        OFDictionary *nanasakiStats;
        OFDictionary *yzus06Stats;
@try {
        nanasakiStats = [[OFString stringWithContentsOfFile:[[HanamiConfig instanceFor:@"yzuplugin"] valueForKey:@"nanasaki_stats_path" defaultValue:@""]] objectByParsingJSON];
} @catch (OFException *) {
        OFLog(@"YzuPlugin: Erm, did you set nanasaki_stats_path?");
}
@try {
        yzus06Stats = [[OFString stringWithContentsOfFile:[[HanamiConfig instanceFor:@"yzuplugin"] valueForKey:@"yzus06_stats_path" defaultValue:@""]] objectByParsingJSON];
} @catch (OFException *) {
        OFLog(@"YzuPlugin: Erm, did you set yzus06_stats_path?");
}
        [results setObject:[[yzus06Stats objectForKey:@"memory"] valueForKey:@"installed"] forKey:@"$yzuplugin::host::memory_total"];
        [results setObject:[[yzus06Stats objectForKey:@"memory"] valueForKey:@"used"] forKey:@"$yzuplugin::host::memory_used"];
        [results setObject:[[[yzus06Stats objectForKey:@"disk"] objectForKey:@"root"] valueForKey:@"total"] forKey:@"$yzuplugin::host::disk_total"];
        [results setObject:[[[yzus06Stats objectForKey:@"disk"] objectForKey:@"root"] valueForKey:@"used"] forKey:@"$yzuplugin::host::disk_used"];
        [results setObject:[yzus06Stats valueForKey:@"temperature"] forKey:@"$yzuplugin::host::temperature"];
        [results setObject:[yzus06Stats valueForKey:@"uptime"] forKey:@"$yzuplugin::host::uptime"];
        
    }];
    [ops addObject:hostStatsOp];
}

- (instancetype)init {
    self = [super init];
    self->results = [[OFMutableDictionary alloc] init];
    self->ops = [[OFMutableArray alloc] init];
    [self createScheduledOperations];
    return self;
}

- (void)transformMap:(OFMutableDictionary *)varMap {
    OFLog(@"before = %@", varMap);
    [varMap addEntriesFromDictionary:results];
    if ([varMap objectForKey:@"$lastfm::now_playing"] && [[varMap objectForKey:@"$lastfm::now_playing"] boolValue] == YES)
        [varMap setValue:@"Listening to" forKey:@"$yzuplugin::lastfm::playing_string"];
    else
        [varMap setValue:@"Listened to" forKey:@"$yzuplugin::lastfm::playing_string"];
}

- (HanamiPluginResult *)handleRequest:(id<HanamiPluginRequestContextProtocol>)requestContext {
    // if ([requestContext.request.IRI.path isEqual:@"/"])
    //     return [[HanamiPluginResult alloc] initWithStatusCode:303 headers:@{@"Location": @"/home.html"}]; // im abusing my own sw LOL
    return nil;
}

- (OFString *)name {
    return @"YzuPlugin";
}

- (OFString *)author {
    return @"Stella";
}

- (OFString *)version {
    return @"1.0";
}

@end