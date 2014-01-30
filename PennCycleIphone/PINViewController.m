//
//  PINViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/26/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "PINViewController.h"
#import "ASIFormDataRequest.h"

@interface PINViewController ()

@end

@implementation PINViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    
    
}

- (IBAction)login:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/verify/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:_penncard forKey:@"penncard"];
    [request setPostValue:_pinField.text forKey:@"pin"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
                
        if ([dict objectForKey:@"error"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect PIN" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:_pinField.text forKey:@"pin"];
            [prefs setObject:_pinField.text forKey:@"pin"];
            [prefs setObject:_penncard forKey:@"penncard"];
            [prefs synchronize];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"TabBar"];
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
}

- (void)viewDidLoad
{
    
    [_pinField becomeFirstResponder];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
