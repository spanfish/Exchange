//
//  EXMainViewController.m
//  Exchange
//
//  Created by xiangwei wang on 2017/06/21.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "EXMainViewController.h"
#import "EXViewModel.h"
#import "RateTableViewCell.h"

@interface EXMainViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *oneUnitBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *tenUnitBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *hundredUnitBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *thousandUnitBarButtonItem;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (nonatomic, strong)  UIBarButtonItem *customUnitBarButtonItem;
@property (nonatomic, strong)  UITextField *textField;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) EXViewModel *viewModel;
@property (nonatomic, strong) UILabel *lastBuildDateLabel;
@property (nonatomic, strong) UIImageView *baseCurrencyImageView;
@end

@implementation EXMainViewController

-(void) showBaseImage {
    NSString *baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"base"];
    
    UIImage *image = [UIImage imageNamed:baseCurrency];
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    // リサイズする倍率を作成する。
    CGFloat scale = imageW / imageH;
    
    CGSize resizedSize = CGSizeMake(40 * scale, 40);
    UIGraphicsBeginImageContext(resizedSize);
    [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.baseCurrencyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, resizedImage.size.width, resizedImage.size.height)];
    self.baseCurrencyImageView.clipsToBounds = YES;
    self.baseCurrencyImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.baseCurrencyImageView.image = resizedImage;
    self.navigationItem.titleView = self.baseCurrencyImageView;
}

-(void) setupToolbar:(NSInteger) mode {
    if(mode == 0) {
        [self.textField setFrame:CGRectMake(0, 0, 40, 40)];
        [self.toolbar setItems:@[
                                 self.oneUnitBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 self.tenUnitBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 self.hundredUnitBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 self.thousandUnitBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 self.customUnitBarButtonItem
                                 ] animated:NO];
    } else {
        [self.textField setFrame:CGRectMake(0, 0, 120, 40)];
        [self.toolbar setItems:@[
                                 self.customUnitBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDone:)]
                                 ] animated:NO];
    }
    
}

-(void) toolbarDone:(id)sender {
    [self.textField resignFirstResponder];
    double unit = [self.textField.text doubleValue];
    [[NSUserDefaults standardUserDefaults] setDouble:unit forKey:@"unit"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.oneUnitBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tenUnitBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"10" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.hundredUnitBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"100" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.thousandUnitBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1000" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //textField.placeholder = NSLocalizedString(@"Enter", nil);
    self.textField.backgroundColor = [UIColor grayColor];
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.customUnitBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.textField];
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      map:^id _Nullable(NSNotification * _Nullable value) {
          NSValue *frameValue = [[value userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
        return frameValue;
    }] deliverOnMainThread]
     subscribeNext:^(NSValue * _Nullable x) {
         CGRect frame = [x CGRectValue];
         self.toolbarBottomConstraint.constant = CGRectGetHeight(frame);
         [self setupToolbar:1];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        self.toolbarBottomConstraint.constant = 0;
        [self setupToolbar:0];
    }];
    
    [self setupToolbar: 0];
    
    self.viewModel = [[EXViewModel alloc] init];
    
    @weakify(self);
    [[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"unit"] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
//        double unit = [[NSUserDefaults standardUserDefaults] doubleForKey:@"unit"];
//        self.textField.text = [NSString stringWithFormat:@"%.0f", unit];
        [self.tableView layoutIfNeeded];
        [self.tableView reloadData];
    }];
    
    [[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"base"] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSString *baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"base"];
        [self.viewModel fetchExchangeRateWithBaseCurrency:[baseCurrency lowercaseString]];
        [self showBaseImage];
    }];
    
    [[[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"favorites"] skip:0] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView layoutIfNeeded];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    [[self.viewModel.updatedContentSignal deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView layoutIfNeeded];
        [self.tableView reloadData];
#if DEBUG
        for(EXRateItem *rateItem in self.viewModel.rateArray) {
            NSLog(@"\"%@\"=\"%@\";", rateItem.foreignCurrency, rateItem.title);
        }
#endif
    }];
    
    self.oneUnitBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"unit"];
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.tenUnitBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"unit"];
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.hundredUnitBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        [[NSUserDefaults standardUserDefaults] setInteger:100 forKey:@"unit"];
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.thousandUnitBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"unit"];
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(EXRateItem *) rateItemForCurrency:(NSString *) currency {
    NSString *baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"base"];
    if([currency isEqualToString:baseCurrency]) {
        EXRateItem *item = [[EXRateItem alloc] init];
        item.baseCurrency = currency;
        item.foreignCurrency = currency;
        item.exchangeRate = 1;
        return item;
    }
    
    for (EXRateItem *rateItem in self.viewModel.rateArray) {
        if([rateItem.foreignCurrency isEqualToString:currency]) {
            return rateItem;
        }
    }
    return nil;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        NSArray *favorites = [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
        return [favorites count];
    }
    return [self.viewModel.rateArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rate" forIndexPath:indexPath];
    
    EXRateItem *rateItem = nil;
    if(indexPath.section == 0) {
        NSArray *favorites = [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
        rateItem = [self rateItemForCurrency:[favorites objectAtIndex:indexPath.row]];
    } else {
        rateItem = [self.viewModel.rateArray objectAtIndex:indexPath.row];
    }
    
    [cell setRateItem:rateItem];
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? NSLocalizedString(@"Favorites", nil) : NSLocalizedString(@"All Currencies", nil);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                          title:NSLocalizedString(@"Delete", @"Delete")
                                                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                            NSArray *favorites = [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
                                                                            NSMutableArray *array = [NSMutableArray arrayWithArray:favorites == nil ? @[] : favorites];
                                                                            [array removeObjectAtIndex:indexPath.row];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:(NSArray *)array forKey:@"favorites"];
                                                                        }];
        
        return @[action];
    } else {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                          title:NSLocalizedString(@"Favorite", @"Favorite")
                                                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                            NSArray *favorites = [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
                                                                            EXRateItem *rateItem = [self.viewModel.rateArray objectAtIndex:indexPath.row];
                                                                            if(![favorites containsObject:rateItem.foreignCurrency]) {
                                                                                NSMutableArray *array = [NSMutableArray arrayWithArray:favorites == nil ? @[] : favorites];
                                                                                
                                                                                [array addObject:rateItem.foreignCurrency];
                                                                                [[NSUserDefaults standardUserDefaults] setObject:(NSArray *)array forKey:@"favorites"];
                                                                            }
                                                                        }];
        UITableViewRowAction *baseAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                          title:NSLocalizedString(@"Base", @"Base")
                                                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                            EXRateItem *rateItem = [self.viewModel.rateArray objectAtIndex:indexPath.row];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:rateItem.foreignCurrency forKey:@"base"];
                                                                        }];
        return @[action, baseAction];
    }
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleInsert;
//}

//- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return @[@"Asia", @"Europe", @"Africa", @"America", @"Oceania"];
//}
@end
