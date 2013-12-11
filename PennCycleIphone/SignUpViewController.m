//
//  SignUpViewController.m
//  penncycle
//
//  Created by Peter Bryan on 11/23/13.
//  Copyright (c) 2013 PeterBryan. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSString *host = @"http://www.penncycle.org/mobile";
    NSString *action = @"check_for_student";
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", host, action]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(_penncard);
    
     NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:_penncard forKey:@"penncard"];
    
    NSError *error;
    NSData *theBodyData =[NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&error];
    [request setHTTPBody:theBodyData];
    
    //NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    //[requestDictionary setObject:[NSString stringWithString:@"12"] forKey:@"foo"];
    //[requestDictionary setObject:[NSString stringWithString:@"*"] forKey:@"bar"];
    
    //NSError *error;

    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    __block NSURLResponse* theResponse = nil;
    __block NSData *theData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        NSLog([error description]);
        theResponse = response;
        theData = data;
        NSMutableDictionary *array = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
        
        NSLog([array description]);
        [_webview loadHTMLString:[array objectForKey:@"signup_form"] baseURL:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
