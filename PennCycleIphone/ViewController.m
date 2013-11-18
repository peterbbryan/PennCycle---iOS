//
//  ViewController.m
//  PennCycleIphone
//
//  Created by Peter Bryan on 10/19/13.
//  Copyright (c) 2013 PeterBryan. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    NSString *host = @"http://www.penncycle.org/mobile";
    NSString *action = @"bike_data";
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", host, action]]];
    //[request setHTTPMethod:@"GET"];
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    //NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    //[requestDictionary setObject:[NSString stringWithString:@"12"] forKey:@"foo"];
    //[requestDictionary setObject:[NSString stringWithString:@"*"] forKey:@"bar"];
    
    //NSError *error;
    
    //NSString *theBodyString = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&error];
    //NSData *theBodyData = [theBodyString dataUsingEncoding:NSUTF8StringEncoding];
    //[request setHTTPBody:theBodyData];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    __block NSURLResponse* theResponse = nil;
    __block NSData *theData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        theResponse = response;
        theData = data;
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
        
        NSLog([array description]);
        
        NSMutableDictionary *location;
        for (location in array){
            
            CLLocationCoordinate2D coordinate;
            NSNumber *latitude = [location objectForKey:@"latitude"];
            coordinate.latitude = latitude.doubleValue;
            NSNumber *longitude = [location objectForKey:@"longitude"];
            coordinate.longitude = longitude.doubleValue;

            //_map.region = MKCoordinateRegionMakeWithDistance(coordinate, 3000, 3000);
            
            //[self queryGooglePlaces:[longitude stringValue] :[latitude stringValue]];
            
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = coordinate;
            annotation.title = [@"Bike " stringByAppendingString: [NSString stringWithFormat:@"%@", [location objectForKey:@"name"]]];
            annotation.subtitle = [@"Location: " stringByAppendingString: [NSString stringWithFormat:@"%@", [location objectForKey:@"location"]]];
            [_maps addAnnotation:annotation];

        }
        
    }];

    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(39.949, -75.195);
    MKCoordinateRegion adjustedRegion = [_maps regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 2000, 2000)];
    [_maps setRegion:adjustedRegion animated:YES];
    /*
    CLLocationCoordinate2D startCoord;
    startCoord.latitude = 39.57;
    startCoord.longitude = 75.11;
    [_maps setRegion:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200) animated:YES];*/
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
    NSLog(@"value");
    
    /*if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        NSURLCredential * credential = [[NSURLCredential alloc] initWithUser:@"1" password:@"1" persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
     */
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
    //NSHTTPURLResponse * res = (NSHTTPURLResponse *) response;
    //NSLog(@"response: %@",res);
    //NSLog(@"res %i\n",res.statusCode);
    //NSLog([response description]);
    
    // cast the response to NSHTTPURLResponse so we can look for 404 etc
    //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    //NSLog(httpResponse);
    
    //NSDictionary *contents = httpResponse;
    
    /*
    if ([httpResponse statusCode]) {
        // do error handling here
        NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    } else {
        // start recieving data
    }*/
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
