//
//  SettingsViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/30/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)signOut:(id)sender{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"penncard"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pin"];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"navPage"];

    [self presentViewController:controller animated:YES completion:NULL];
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
