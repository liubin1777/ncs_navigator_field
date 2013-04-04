//
//  NUEndpointLiveService.m
//  NCSNavField
//
//  Created by Jacob Van Order on 2/14/13.
//  Copyright (c) 2013 Northwestern University. All rights reserved.
//

#import "NUEndpointLiveService.h"
#import "NUEndpoint.h"
#import "NUEndpointEnvironment.h"
#import "RKReachabilityObserver.h"
#import "RestKitSettings.h"
#import "ApplicationSettings.h"

@interface NUEndpointLiveService () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) void (^endpointBlock)(NSArray *endpointArray, NSError *endpointError);
@property (nonatomic, strong) NSURLConnection *endpointConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

-(NUEndpoint *)generateManualEndpoint;

@end

@implementation NUEndpointLiveService

#pragma mark delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.receivedData = [NSMutableData data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSArray *endpointArray = @[];
    NSError *jsonError = nil;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&jsonError];
    for (NSDictionary *endpointDictionary in dataDictionary[@"locations"]) {
        NUEndpoint *newEndpoint = [[NUEndpoint alloc] initWithDataDictionary:endpointDictionary];
        newEndpoint.isManualEndpoint = @NO;
        endpointArray = [endpointArray arrayByAddingObject:newEndpoint];
    }
    endpointArray = [endpointArray arrayByAddingObject:[self generateManualEndpoint]];
    if (self.endpointBlock) {
        self.endpointBlock (endpointArray, jsonError);
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.endpointBlock(nil, error);
}

#pragma mark customization

-(void)getEndpointArrayWithCallback:(void (^)(NSArray *, NSError *))endpointBlock {
        self.endpointBlock = endpointBlock;
        NSDictionary *endpointPrefDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCSNavField-environment" ofType:@"plist"]];
        NSURL *locationServiceURL = [NSURL URLWithString:endpointPrefDictionary[@"locationServiceURL"]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:locationServiceURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0f];
        self.endpointConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        [self.endpointConnection start];
}

-(BOOL)userDidChooseEndpoint:(NUEndpoint *)chosenEndpoint {
    NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    libraryDirectory = [libraryDirectory stringByAppendingFormat:@"/userEndpoint.plist"];
    BOOL wasSuccessful = [NSKeyedArchiver archiveRootObject:chosenEndpoint toFile:libraryDirectory];
    [chosenEndpoint writeToDisk];
    return wasSuccessful;
}

-(void)stopNetworkRequest {
    [self.endpointConnection cancel];
}

#pragma mark prototyping

-(NUEndpoint *)generateManualEndpoint {
    NUEndpoint *endpointOnDisk = [NUEndpoint userEndpointOnDisk];
    if ([endpointOnDisk.isManualEndpoint isEqualToNumber:@YES]) {
        return endpointOnDisk;
    }
    else {
        NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:@"ManualImage" withExtension:@".png"];
        NSDictionary *manualEndpointDictionary = @{@"name": @"Manual Mode",
                                                   @"logo_url" : [imageUrl absoluteString],
                                                   @"environments" : @[@{@"cas_base_url" : @"",
                                                                         @"cas_proxy_receive_url" : @"",
                                                                         @"cas_proxy_retrieve_url" : @"",
                                                                         @"cases_url" : @"",
                                                                         @"name" : @"staging"},
                                                                       @{@"cas_base_url" : @"",
                                                                         @"cas_proxy_receive_url" : @"",
                                                                         @"cas_proxy_retrieve_url" : @"",
                                                                         @"cases_url" : @"",
                                                                         @"name" : @"staging"}]};
        NUEndpoint *newEndpoint = [[NUEndpoint alloc] initWithDataDictionary:manualEndpointDictionary];
        newEndpoint.enviroment = [newEndpoint environmentBasedOnCurrentBuildFromArray:newEndpoint.environmentArray];
        newEndpoint.isManualEndpoint = @YES;
        return newEndpoint;
    }
}

#pragma mark stock code

-(instancetype)init {
    
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}


@end
