//
//  ViewController.m
//  PennCycleIphone
//
//  Created by Peter Bryan on 10/19/13.
//  Copyright (c) 2013 PeterBryan. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "SignUpViewController.h"
#import "JSONifyViewController.h"
#import "ASIFormDataRequest.h"
#import "PINViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(IBAction)submitPennCard:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/check_for_student/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:_pennCardTextField.text forKey:@"penncard"];
    
    [request startSynchronous];
    NSError *error = [request error];
    NSLog([error description]);
    if (!error) {
        NSData *response = [request responseData];
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        
        NSLog([dict description]);
        
        if ([dict objectForKey:@"signup_form"]){
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign up!" message:@"Please visit www.penncycle.org to make an account!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alertView show];
            
            
            //SignUpViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"signup"];
            //begin.penncard = _pennCardTextField.text;
            //[self.navigationController pushViewController:begin animated:YES];
            
        }
        else{
            
            PINViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"pinView"];
            begin.penncard = _pennCardTextField.text;
            [self.navigationController pushViewController:begin animated:YES];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_pennCardTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSLog([prefs objectForKey:@"penncard"]);
    if ([prefs objectForKey:@"pin"]){
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"TabBar"];
        [self presentViewController:controller animated:NO completion:NULL];
        
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        
    }
}

- (void)viewDidLoad
{
    
    
    NSString *host = @"http://www.penncycle.org/mobile";
    NSString *action = @"bike_data";
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", host, action]]];
    
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    __block NSURLResponse* theResponse = nil;
    __block NSData *theData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        theResponse = response;
        theData = data;
        
        if (!error){
            
            NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
            
            NSMutableDictionary *location;
            for (location in array){
                
                CLLocationCoordinate2D coordinate;
                NSNumber *latitude = [location objectForKey:@"latitude"];
                coordinate.latitude = latitude.doubleValue;
                NSNumber *longitude = [location objectForKey:@"longitude"];
                coordinate.longitude = longitude.doubleValue;
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.title = [@"" stringByAppendingString: [NSString stringWithFormat:@"%@", [location objectForKey:@"location"]]];
                [_maps addAnnotation:annotation];
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
    
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(39.949, -75.195);
    MKCoordinateRegion adjustedRegion = [_maps regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 2000, 2000)];
    [_maps setRegion:adjustedRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
