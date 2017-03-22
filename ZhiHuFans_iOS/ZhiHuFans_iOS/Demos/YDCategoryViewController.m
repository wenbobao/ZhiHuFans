//
//  YDCategoryViewController.m
//  ZhiHuFans_iOS
//
//  Created by bob on 17/3/22.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "YDCategoryViewController.h"
#import <Ono/Ono.h>
#import "CellDataModel.h"
#import "QDCommonUI.h"
#import <SafariServices/SafariServices.h>

@interface YDCategoryViewController ()

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) UIScrollView *scrollView;

@end

@interface QDCommonGridButton : QMUIButton

@end

@implementation YDCategoryViewController

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    self.title = @"知乎分类";
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initDataSource];
    }
    return self;
}

- (void)initDataSource
{
    [self fetchData];
}

- (void)fetchData {
    NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://www.zhihufans.com"]];
    NSError *xmlError;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:&xmlError];
    if (xmlError) {
        NSLog(@"%@",xmlError);
        return ;
    }
    NSMutableArray *dataArray = [NSMutableArray array];
    [document enumerateElementsWithXPath:@"/html/body/div/div[1]/div/div/div/ul/node()" usingBlock:^(ONOXMLElement *superelement, NSUInteger idx, BOOL *stop) {
        if ([superelement children].count > 0) {
//            NSLog(@"AAA%@",superelement);
            ONOXMLElement *childElement = [[superelement children] firstObject];
            NSString *urlLink = [childElement valueForAttribute:@"href"];
            NSString *title = [childElement stringValue];
            [dataArray addObject:[[CellDataModel alloc]initWithTitle:title link:urlLink]];
        }
    }];
    
    self.dataSource = dataArray;
}

- (void)initSubviews {
    [super initSubviews];
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    _gridView = [[QMUIGridView alloc] init];
    for (NSInteger i = 0, l = self.dataSource.count; i < l; i++) {
        [self.gridView addSubview:[self generateButtonAtIndex:i]];
    }
    [self.scrollView addSubview:self.gridView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    
    if (CGRectGetWidth(self.view.bounds) <= [QMUIHelper screenSizeFor55Inch].width) {
        self.gridView.columnCount = 3;
        CGFloat itemWidth = flat(CGRectGetWidth(self.scrollView.bounds) / self.gridView.columnCount);
        self.gridView.rowHeight = itemWidth;
    } else {
        CGFloat minimumItemWidth = flat([QMUIHelper screenSizeFor55Inch].width / 3.0);
        CGFloat maximumItemWidth = flat(CGRectGetWidth(self.view.bounds) / 5.0);
        CGFloat freeSpacingWhenDisplayingMinimumCount = CGRectGetWidth(self.scrollView.bounds) / maximumItemWidth - floor(CGRectGetWidth(self.scrollView.bounds) / maximumItemWidth);
        CGFloat freeSpacingWhenDisplayingMaximumCount = CGRectGetWidth(self.scrollView.bounds) / minimumItemWidth - floor(CGRectGetWidth(self.scrollView.bounds) / minimumItemWidth);
        if (freeSpacingWhenDisplayingMinimumCount < freeSpacingWhenDisplayingMaximumCount) {
            // 按每行最少item的情况来布局的话，空间利用率会更高，所以按最少item来
            self.gridView.columnCount = floor(CGRectGetWidth(self.scrollView.bounds) / maximumItemWidth);
            CGFloat itemWidth = floor(CGRectGetWidth(self.scrollView.bounds) / self.gridView.columnCount);
            self.gridView.rowHeight = itemWidth;
        } else {
            self.gridView.columnCount = floor(CGRectGetWidth(self.scrollView.bounds) / minimumItemWidth);
            CGFloat itemWidth = floor(CGRectGetWidth(self.scrollView.bounds) / self.gridView.columnCount);
            self.gridView.rowHeight = itemWidth;
        }
    }
    
    CGFloat gridViewHeight = [self.gridView sizeThatFits:CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGFLOAT_MAX)].height;
    self.gridView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), gridViewHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetMaxY(self.gridView.frame));
}

- (QDCommonGridButton *)generateButtonAtIndex:(NSInteger)index {
    CellDataModel *model = self.dataSource[index];
    NSString *keyName = model.title;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:keyName attributes:@{NSForegroundColorAttributeName: UIColorGray6, NSFontAttributeName: UIFontMake(11), NSParagraphStyleAttributeName: [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:12 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]}];
    UIImage *image = [UIImage imageNamed:@""];
    
    QDCommonGridButton *button = [[QDCommonGridButton alloc] init];
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    button.tag = index;
    [button addTarget:self action:@selector(handleGirdButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)handleGirdButtonEvent:(QDCommonGridButton *)button {
    CellDataModel *model = self.dataSource[button.tag];
    NSString *urlString = @"https://www.zhihu.com/people/geng-di-71";
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    people.php?id=geng-di-71&name=乔维里
    //https://www.zhihu.com/question/19943830
    //    * 问题页面 `zhihu://questions/{id}`
    //    * 回答 `zhihu://answers/{id}`
    //    * 用户页 `zhihu://people/{id}`
    
    NSString *openString = @"zhihu://people/geng-di-71";
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
}

@end


@implementation QDCommonGridButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.numberOfLines = 2;
        self.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
        self.qmui_needsTakeOverTouchEvent = YES;
        self.qmui_borderPosition = QMUIBorderViewPositionRight | QMUIImageBorderPositionBottom;
    }
    return self;
}

- (void)layoutSubviews {
    // 不用父类的，自己计算
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    CGPoint center = CGPointMake(flat(self.contentEdgeInsets.left + contentSize.width / 2), flat(self.contentEdgeInsets.top + contentSize.height / 2));
    
    self.imageView.center = CGPointMake(center.x, center.y - 12);
    
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:contentSize];
    self.titleLabel.frame = CGRectFlatMake(self.contentEdgeInsets.left, center.y + PreferredVarForDevices(27, 27, 21, 21), contentSize.width, titleLabelSize.height);
}

@end
