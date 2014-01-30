//
//  JSONifyViewController.h
//  penncycle
//
//  Created by Peter Bryan on 1/24/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSONifyViewController : UIViewController

+ (NSString *)addParam: (NSString *)oldName :(NSString *)paramName :(NSString *)value :(BOOL)boolean;

@end
