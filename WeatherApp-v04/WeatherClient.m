//
//  WeatherClient.m
//  WeatherApp-v04
//
//  Created by Edward Apostol on 6/22/18.
//  Copyright © 2018 edward. All rights reserved.
//

#import "WeatherClient.h"
#import "WeatherAPIKey.h"
// noted here that the pch file is not associating properly. so manual import of core location framework may be needed
#import <CoreLocation/CoreLocation.h>

static NSString * const kWeatherUndergroundAPIBaseURLString = @"http://api.wunderground.com/api/";

@implementation WeatherClient
#pragma mark - Singleton
+ (instancetype)sharedClient
{
    static WeatherClient *sharedClient = nil;
    static dispatch_once_t onceToken;

        dispatch_once(&onceToken, ^{
            NSString *baseURLString = [kWeatherUndergroundAPIBaseURLString stringByAppendingString:kWeatherUndergroundAPIKey];
            sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        });
        
        return sharedClient;
}

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

- (void)getCurrentWeatherObservationForLocation:(CLLocation *)location completion:(void(^)(Observation *observation, NSError *error))completion
{
    if (location)
    {
        // We have to do this because their API is not exactly rest
        NSString *getPath = [NSString stringWithFormat:@"conditions/q/%.6f,%.6f.json", location.coordinate.latitude, location.coordinate.longitude];
        WeatherClient *client = [WeatherClient sharedClient];
        [client getPath:getPath
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    Observation *observation = [Observation observationWithDictionary:responseObject[@"current_observation"]];
                    completion(observation, nil);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    completion(nil, error);
                }
         ];
    }
    else
    {
        completion(nil, [NSError errorWithDomain:@"Invalid Location as argument" code:-1 userInfo:nil]);
    }
}

@end
