//
//  YDHistoryHotViewController.m
//  ZhiHuFans_iOS
//
//  Created by bob on 17/3/22.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "YDHistoryHotViewController.h"
#import <Ono/Ono.h>
#import "CellDataModel.h"
#import <SafariServices/SafariServices.h>

@interface YDHistoryHotViewController ()
@property(nonatomic, strong) NSArray *dataSource;
@end

@implementation YDHistoryHotViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self initDataSource];
    }
    return self;
}

- (void)initDataSource {
    [self fetchData];
}

- (void)fetchData {
    NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://www.zhihufans.com/history.php"]];
    NSError *xmlError;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:&xmlError];
    if (xmlError) {
        NSLog(@"%@",xmlError);
        return ;
    }
    NSMutableArray *dataArray = [NSMutableArray array];
    [document enumerateElementsWithXPath:@"/html/body/div/div/div/ul/node()" usingBlock:^(ONOXMLElement *superelement, NSUInteger idx, BOOL *stop) {
        if ([superelement children].count > 0) {
            [superelement enumerateElementsWithXPath:@"//div/div[2]/div" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
//                NSLog(@"BBB%@",element);
                if ([element children].count > 0) {
                    for (ONOXMLElement *childElement in [element children]) {
                        NSString *urlLink = [childElement valueForAttribute:@"href"];
                        NSString *title = [YDHistoryHotViewController stringByTrimingLeadingWhiteSpace:[childElement stringValue]];
                        title = [YDHistoryHotViewController stringByTrimingTailingWhiteSpace:title];
                        [dataArray addObject:[[CellDataModel alloc]initWithTitle:title link:urlLink]];
                    }
                }
                
            }];
        }
    }];
    
    self.dataSource = dataArray;
}

+ (NSString *)stringByTrimingLeadingWhiteSpace:(NSString *)string {
    NSRange range = [string rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    return [string stringByReplacingCharactersInRange:range withString:@""];
}

+ (NSString *)stringByTrimingTailingWhiteSpace:(NSString *)string {
    NSRange range = [string rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
    return [string stringByReplacingCharactersInRange:range withString:@""];
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    self.title = @"历史热门";
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierNormal = @"cellNormal";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierNormal];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:self.tableView withStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierNormal];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CellDataModel *model = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = model.title;
    cell.textLabel.font = UIFontMake(15);
    cell.detailTextLabel.font = UIFontMake(13);
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellNormalHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CellDataModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *urlString = model.link;
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    //https://www.zhihu.com/question/19943830
    //    * 问题页面 `zhihu://questions/{id}`
    //    * 回答 `zhihu://answers/{id}`
    //    * 用户页 `zhihu://people/{id}`
    
    NSString *openString = [NSString stringWithFormat:@"zhihu://questions/%@",[urlString lastPathComponent]];
    NSURL *openURL = [[NSURL alloc] initWithString:openString];
    //先判断是否能打开该url
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        //打开url
        [[UIApplication sharedApplication] openURL:openURL];
    }else {
        if ([SFSafariViewController class]) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
            [self presentViewController:safari animated:YES completion:nil];
        }
    }
    // deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
