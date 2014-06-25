//
//  SignUpViewController.m
//  penncycle
//
//  Created by Peter Bryan on 11/23/13.
//  Copyright (c) 2013 PeterBryan. All rights reserved.
//

#import "SignUpViewController.h"
#import "JSONifyViewController.h"
#import "ASIFormDataRequest.h"

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

-(IBAction)submit:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/signup/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *penncard =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_penncard').value"];
    NSString *name =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_name').value"];
    NSString *phone =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_phone').value"];
    NSString *email =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_email').value"];
    NSString *last_two =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_last_two').value"];
    NSString *grad_year =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_grad_year').value"];
    NSString *living_location =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_living_location').value"];
    NSString *maleCheck =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_gender_1').checked"];
    NSString *femaleCheck =[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('id_gender_2').checked"];
    NSString *gender = [NSString string];
    
    if ([maleCheck isEqualToString:@"true"]){
        gender = @"M";
    }
    if ([femaleCheck isEqualToString:@"true"]){
        gender = @"F";
    }
    
    [request setPostValue:penncard forKey:@"penncard"];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:penncard forKey:@"penncard"];
    [request setPostValue:last_two forKey:@"last_two"];
    [request setPostValue:grad_year forKey:@"grad_year"];
    [request setPostValue:living_location forKey:@"living_location"];
    [request setPostValue:gender forKey:@"gender"];

    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        NSData *response = [request responseData];
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        [_webview loadHTMLString:[dict objectForKey:@"signup_form"] baseURL:nil];
    }
}

- (void)viewDidLoad
{
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    NSString *host = @"http://www.penncycle.org/mobile";
    NSString *action = @"check_for_student";
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", host, action]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    
     NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:_penncard forKey:@"penncard"];
    
    NSError *error;
    NSData *theBodyData =[NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&error];
    [request setHTTPBody:theBodyData];
    
    __block NSURLResponse* theResponse = nil;
    __block NSData *theData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        theResponse = response;
        theData = data;
        NSMutableDictionary *array = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
        
        [_webview loadHTMLString:[array objectForKey:@"signup_form"] baseURL:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
