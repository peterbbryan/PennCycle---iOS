//
//  JSONifyViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/24/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "JSONifyViewController.h"

@interface JSONifyViewController ()

@end

@implementation JSONifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (NSString *)addParam: (NSString *)oldName :(NSString *)paramName :(NSString *)value :(BOOL)boolean{
    NSString *returnString = oldName;
    if ([oldName hasSuffix:@"/"]){
        if (boolean) returnString = [returnString stringByAppendingString:@"?"];
    }
    else{
        returnString = [returnString stringByAppendingString:@"&"];
    }
    returnString = [returnString stringByAppendingString:paramName];
    returnString = [returnString stringByAppendingString:@"="];
    returnString = [returnString stringByAppendingString:value];
    return returnString;
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
