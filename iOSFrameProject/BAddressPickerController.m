//
//  BAddressPickerController.m
//  Bee
//
//  Created by 林洁 on 16/1/12.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import "BAddressPickerController.h"
#import "ChineseToPinyin.h"
#import "BAddressHeader.h"
#import "BCurrentCityCell.h"
#import "BRecentCityCell.h"
#import "BHotCityCell.h"


@interface BAddressPickerController ()<UISearchResultsUpdating, UISearchControllerDelegate>{
    UITableView *_tableView;
    UISearchController *_displayController;
    NSArray *hotCities;
    NSMutableArray *cities;
    NSMutableArray *titleArray;
    NSMutableArray *resultArray;
}

@property(nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation BAddressPickerController

/**
 初始化方法

 @param frame Frame
 @return id
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.view.frame = frame;
        [self initData];
        [self initTableView];
        [self initSearchBar];
    }
    return self;
}

#pragma mark - Getter and Setter
- (void)setDataSource:(id<BAddressPickerDataSource>)dataSource{
    hotCities = [dataSource arrayOfHotCitiesInAddressPicker:self];
    [_tableView reloadData];
}

#pragma mark - UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}
    
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}
    

/**
 UISearchResultsUpdating

 @param searchController searchController
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *inputStr = searchController.searchBar.text ;
    [resultArray removeAllObjects];
    for (int i = 0; i < cities.count; i++) {
        if ([[ChineseToPinyin pinyinFromChiniseString:cities[i]] hasPrefix:[inputStr uppercaseString]] || [cities[i] hasPrefix:inputStr]) {
            [resultArray addObject:[cities objectAtIndex:i]];
        }
    }
    
    [_tableView reloadData];
}



#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!_displayController.active) {
        return [[self.dictionary allKeys] count] + 3;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!_displayController.active) {
        if (section > 2) {
            NSString *cityKey = [titleArray objectAtIndex:section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            return [array count];
        }
        return 1;
    }else{
        return [resultArray count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"Cell";
    UITableViewCellSelectionStyle selectStyle = UITableViewCellSelectionStyleNone;
    if (!_displayController.active) {
        if (indexPath.section == 0) {
            BCurrentCityCell *currentCityCell = [tableView dequeueReusableCellWithIdentifier:@"currentCityCell"];
            if (currentCityCell == nil) {
                currentCityCell = [[BCurrentCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"currentCityCell"];
            }
//            if (!currentCityCell.activityIndicatorView.isAnimating && currentCityCell.GPSButton.titleLabel.text.length > 0) {
//                [currentCityCell.activityIndicatorView startAnimating];
//            }
            
            currentCityCell.selectionStyle = selectStyle;
            return currentCityCell;
        }else if (indexPath.section == 1){
            BRecentCityCell *recentCityCell = [tableView dequeueReusableCellWithIdentifier:@"recentCityCell"];
            if (recentCityCell == nil) {
                recentCityCell = [[BRecentCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recentCityCell"];
            }
            recentCityCell.selectionStyle = selectStyle;
            //如果第一次使用没有最近访问的城市则赢该行
            if (![[NSUserDefaults standardUserDefaults] objectForKey:currentCity]) {
                recentCityCell.frame = CGRectMake(0, 0, 0, 0);
                [recentCityCell setHidden:YES];
            }
            return recentCityCell;
        }else if (indexPath.section == 2){
            BHotCityCell *hotCell = [tableView dequeueReusableCellWithIdentifier:@"hotCityCell"];
            
            if (hotCell == nil) {
                hotCell = [[BHotCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hotCityCell" array:hotCities];
            }
            hotCell.selectionStyle = selectStyle;
            return hotCell;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            //cell.selectionStyle = selectStyle;
            return cell;
        }
    }else{
        static NSString *Identifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        cell.selectionStyle = selectStyle;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_displayController.active) {
        if ([cell isKindOfClass:[BCurrentCityCell class]]) {
            BCurrentCityCell *mycell = (BCurrentCityCell*)cell;
            if (mycell.isLocaling) {
                [mycell.activityIndicatorView startAnimating];
            } else {
                [mycell.activityIndicatorView stopAnimating];
            }
            [mycell buttonWhenClick:^(UIButton *button) {
                if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                    [self saveCurrentCity:button.titleLabel.text];
                    [self.delegate addressPicker:self didSelectedCity:button.titleLabel.text];
                }
            }];
        }else if ([cell isKindOfClass:[BRecentCityCell class]]){
            [(BRecentCityCell*)cell buttonWhenClick:^(UIButton *button) {
                if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                    [self saveCurrentCity:button.titleLabel.text];
                    [self.delegate addressPicker:self didSelectedCity:button.titleLabel.text];
                }
            }];
        }else if([cell isKindOfClass:[BHotCityCell class]]){
            [(BHotCityCell*)cell buttonWhenClick:^(UIButton *button) {
                if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                    [self saveCurrentCity:button.titleLabel.text];
                    [self.delegate addressPicker:self didSelectedCity:button.titleLabel.text];
                }
            }];
        }else{
            NSString *cityKey = [titleArray objectAtIndex:indexPath.section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            cell.textLabel.text = [array objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        }

    }else{
        cell.textLabel.text = [resultArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
}

//右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!_displayController.active) {
        NSMutableArray *titleSectionArray = [NSMutableArray arrayWithObjects:@"当前",@"热门", nil]; // @"最近",
        for (int i = 0; i < [titleArray count]; i++) {
            NSString *title = [NSString stringWithFormat:@"    %@",[titleArray objectAtIndex:i]];
            [titleSectionArray addObject:title];
        }
        return titleSectionArray;
    }else{
        return nil;
    }

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!_displayController.active) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 28)];
        headerView.backgroundColor = UIColorFromRGBA(235, 235, 235, 1.0);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth - 15, 28)];
        label.font = [UIFont systemFontOfSize:14.0];
        [headerView addSubview:label];
        if (section == 0) {
            label.text = @"当前所在城市";
        }else if (section == 1){
            //如果第一次使用没有最近访问的城市则赢该行
            if (![[NSUserDefaults standardUserDefaults] objectForKey:currentCity]) {
                return nil;
            }
            label.text = @"最近访问城市";
        }else if (section == 2){
            label.text = @"热门城市";
        }else{
            label.text = [titleArray objectAtIndex:section - 3];
        }
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (!_displayController.active) {
        if (section == 1) {
            //如果第一次使用没有最近访问的城市则赢该行
            if (![[NSUserDefaults standardUserDefaults] objectForKey:currentCity]) {
                return 0.01;
            }
        }
        return 28;
    }else{
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        //如果第一次使用没有最近访问的城市则赢该行
        if (![[NSUserDefaults standardUserDefaults] objectForKey:currentCity]) {
            return 0.01;
        }
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_displayController.active) {
        if (indexPath.section == 2) {
            return ceil((float)[hotCities count] / 3) * (BUTTON_HEIGHT + 15) + 15;
        }else if (indexPath.section > 2){
            return 42;
        }else if (indexPath.section == 1){
            //如果第一次使用没有最近访问的城市则赢该行
            if (![[NSUserDefaults standardUserDefaults] objectForKey:currentCity]) {
                return 0;
            }
        }
        return BUTTON_HEIGHT + 30;
    }else{
        return 42;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_displayController.active) {
        if (indexPath.section > 2) {
            NSString *cityKey = [titleArray objectAtIndex:indexPath.section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                NSString *selectCity = [array objectAtIndex:indexPath.row];
                [self saveCurrentCity:selectCity];
                [self.delegate addressPicker:self didSelectedCity:selectCity];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
            NSString *selectCity = [resultArray objectAtIndex:indexPath.row];
            [self saveCurrentCity:selectCity];
            [self.delegate addressPicker:self didSelectedCity:selectCity];
        }
        
        
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_displayController.searchBar resignFirstResponder];
    
}

//保存访问过的城市
- (void)saveCurrentCity:(NSString*)city{
    NSMutableArray *currentArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:currentCity]];
    if (currentArray == nil) {
        currentArray = [NSMutableArray array];
    }
    if ([currentArray count] < 2 && ![currentArray containsObject:city]) {
        [currentArray addObject:city];
    }else{
        if (![currentArray containsObject:city]) {
            currentArray[1] = currentArray[0];
            currentArray[0] = city;
        }
    }
//    [[NSUserDefaults standardUserDefaults] setObject:currentArray forKey:currentCity];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - init
- (void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    [self.view addSubview:_tableView];
    [self.view sendSubviewToBack:_tableView];
}

- (void)initSearchBar{
    resultArray = [[NSMutableArray alloc] init];
    _displayController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _displayController.delegate = self;
    _displayController.searchBar.placeholder = @"输入城市名或拼音";
    _displayController.searchResultsUpdater = self;
    
    // 设置searchBar
    UIView *headerView = [[UIView alloc] initWithFrame:_displayController.searchBar.frame];
    [headerView addSubview:_displayController.searchBar];
    _displayController.searchBar.tintColor = UIColorFromRGBA(251, 81, 81, 1);
    _tableView.tableHeaderView = headerView;
    
    self.definesPresentationContext = YES;
    
    //是否添加半透明覆盖层
    _displayController.dimsBackgroundDuringPresentation = NO;
    //是否隐藏导航栏
    _displayController.hidesNavigationBarDuringPresentation = YES;
    
    // 去除 sectionIndex 和 searchBar冲突
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    
}

- (void)initData{
    cities = [[NSMutableArray alloc] init];
    NSArray *allCityKeys = [self.dictionary allKeys];
    for (int i = 0; i < [self.dictionary count]; i++) {
        [cities addObjectsFromArray:[self.dictionary objectForKey:[allCityKeys objectAtIndex:i]]];
    }
    titleArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 26; i++) {
        if (i == 8 || i == 14 || i == 20 || i== 21) {
            continue;
        }
        NSString *cityKey = [NSString stringWithFormat:@"%c",i+65];
        [titleArray addObject:cityKey];
    }
}

#pragma mark - Getter and Setter
- (NSMutableDictionary*)dictionary{
    if (_dictionary == nil) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"CityName" ofType:@"plist"];
//        _dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        
        // 统一的城市数据选择
        NSMutableArray *citysMuArray = [NSMutableArray array];
        NSDictionary *cityCodeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"citysCode"];
        
        if (cityCodeDict == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"CityName" ofType:@"plist"];
            _dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            return _dictionary;
        }
        
        // 网络城市数据
        for (NSDictionary *dictData in [cityCodeDict objectForKey:@"children"]) {
            NSArray *subCitysArray = [dictData objectForKey:@"children"];
            if (subCitysArray.count == 0 || [subCitysArray isEqual:@""]) {   // 直辖市
                [citysMuArray addObject:[dictData objectForKey:@"regionName"]];
            } else {
                for (NSDictionary *dictDataSub in subCitysArray) {
                    [citysMuArray addObject:[dictDataSub objectForKey:@"regionName"]];
                }
            }
        }
        
        // 将城市按照 A-Z 进行排序 并加入到字典中
        _dictionary = [NSMutableDictionary dictionary];
        for (NSString *city in citysMuArray) {
            char myLetter = [ChineseToPinyin sortSectionTitle:city];
            NSString *keyStr = [NSString stringWithFormat:@"%c", myLetter];
            NSMutableArray *keyStrToArray = [_dictionary objectForKey:keyStr];
            if (keyStrToArray == nil) {
                keyStrToArray = [NSMutableArray array];
            }
            [keyStrToArray addObject:city];
            
            [_dictionary setObject:keyStrToArray forKey:keyStr];
        }
        
    }
    return _dictionary;
}

@end
