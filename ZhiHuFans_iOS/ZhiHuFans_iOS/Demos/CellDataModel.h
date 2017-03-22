//
//  CellDataModel.h
//  ZhiHuFans_iOS
//
//  Created by bob on 17/3/6.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellDataModel : NSObject

@property(nonatomic, strong, readwrite) NSString *title;
@property(nonatomic, strong, readwrite) NSString *link;

-(instancetype)initWithTitle:(NSString*)title link:(NSString*)link;

@end
