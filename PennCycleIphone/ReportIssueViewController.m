//
//  ReportIssueViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/29/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "ReportIssueViewController.h"
#import "ASIFormDataRequest.h"

@interface ReportIssueViewController ()

@end

@implementation ReportIssueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)submit:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/report/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    [request setPostValue:_issueDescription.text forKey:@"feedback"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        
        _issueDescription.text = @"";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Issue reported!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_issueDescription resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
