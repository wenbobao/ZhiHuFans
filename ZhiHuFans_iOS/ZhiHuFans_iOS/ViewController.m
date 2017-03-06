//
//  ViewController.m
//  ZhiHuFans_iOS
//
//  Created by bob on 17/3/6.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "ViewController.h"
#import <Ono/Ono.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:@"http://www.zhihufans.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *xmlError;
        ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:&xmlError];
        if (xmlError) {
            NSLog(@"%@",xmlError);
            return ;
        }

        [document enumerateElementsWithXPath:@"/html/body/div/div[1]/div/div/div/ul/node()" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",element);
        }];
        
        [document enumerateElementsWithXPath:@"/html/body/div/div[2]/div/div/div/ol/node()" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",element);
        }];
        
    }] resume];
    
}

@end
