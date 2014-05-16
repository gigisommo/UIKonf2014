//
//  ViewController.m
//  TGFoursquareLocationDetail-Demo
//
//  Created by Thibault Guégan on 15/12/2013.
//  Copyright (c) 2013 Thibault Guégan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UHDPlace *place;

@end

@implementation ViewController

- (instancetype)initWithPlace:(UHDPlace *)place
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) {
        return nil;
    }
    
    _place = place;
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.tintColor = [UIColor whiteColor];
	
    self.locationDetail = [[TGFoursquareLocationDetail alloc] initWithFrame:self.view.bounds];
    self.locationDetail.tableViewDataSource = self;
    self.locationDetail.tableViewDelegate = self;
    
    self.locationDetail.delegate = self;
    self.locationDetail.parallaxScrollFactor = 0.3; // little slower than normal.
    
    [self.view addSubview:self.locationDetail];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view bringSubviewToFront:_headerView];
    
    UIButton *buttonPost = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPost setImage:[[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [buttonPost addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    buttonPost.frame = CGRectMake(self.view.bounds.size.width - 44, 0, 44, 44);
    [self.view addSubview:buttonPost];
    
    self.locationDetail.headerView = _headerView;

}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 90.0f;
    }
    else if(indexPath.row == 1){
        return 171.0f;
    }
    else if(indexPath.row == 2){
        return 138.0f;
    }
    else
        return 100.0f; //cell for comments, in reality the height has to be adjustable
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//categories =     (
//                  {
//                      icon =             {
//                          prefix = "https://ss1.4sqi.net/img/categories_v2/building/default_";
//                          suffix = ".png";
//                      };
//                      id = 4bf58dd8d48988d124941735;
//                      name = Office;
//                      pluralName = Offices;
//                      primary = 1;
//                      shortName = Office;
//                  }
//                  );
//contact =     {
//};
//hereNow =     {
//    count = 0;
//    groups =         (
//    );
//    summary = "0 people here";
//};
//id = 4ad92090f964a520581821e3;
//location =     {
//    address = "6 Infinite Loop";
//    cc = US;
//    city = Cupertino;
//    country = "United States";
//    crossStreet = "at Mariani";
//    distance = 162;
//    lat = "37.33089179946246";
//    lng = "-122.0309062148589";
//    postalCode = 95014;
//    state = CA;
//};
//name = "Apple - Infinite Loop 6";
//referralId = "v-1400251272";
//specials =     {
//    count = 0;
//    items =         (
//    );
//};
//stats =     {
//    checkinsCount = 3003;
//    tipCount = 1;
//    usersCount = 362;
//};
//verified = 0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        DetailLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailLocationCell"];
        
        if(cell == nil){
            cell = [DetailLocationCell detailLocationCell];
        }

        cell.lblTitle.text = self.place.name;
        cell.lblDescription.text = @"Just a place..";
        [cell.btnMore addTarget:self
                         action:@selector(actionGetDirections:)
               forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if(indexPath.row == 1){
        AddressLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressLocationDetail"];

        if(cell == nil){
            cell = [AddressLocationCell addressLocationDetailCell];
        }

        cell.nameLabel.text = self.place.location[@"city"];
        cell.adressFirstLabel.text = self.place.location[@"address"];
        cell.adressSecondLabel.text = [NSString stringWithFormat:@"%@ Km away", self.place.location[@"distance"]];
        cell.phoneNumberLabel.text = self.place.contact[@"formattedPhone"];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusable"];
        }
        
        cell.textLabel.text = @"Default cell";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - LocationDetailViewDelegate

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail imagePagerDidLoad:(KIImagePager *)imagePager
{
    imagePager.dataSource = self;
    imagePager.delegate = self;
    imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    imagePager.slideshowTimeInterval = 0.0f;
    imagePager.slideshowShouldCallScrollToDelegate = YES;
    
    self.locationDetail.nbImages = [self.locationDetail.imagePager.dataSource.arrayWithImages count];
    self.locationDetail.currentImage = 0;
}

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail tableViewDidLoad:(UITableView *)tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail headerViewDidLoad:(UIView *)headerView
{
    [headerView setAlpha:0.0];
    [headerView setHidden:YES];
}

#pragma mark - KIImagePager DataSource
- (NSArray *)arrayWithImages
{
    return self.place.mergedPhotos;
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *) captionForImageAtIndex:(NSUInteger)index
{
    return @[
             @"First screenshot",
             @"Another screenshot",
             @"Last one! ;-)"
             ][index];
}

#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

#pragma mark - Button actions

- (void)back
{
    NSLog(@"Here you should go back to previous view controller");
}

- (void)actionClose:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void)actionGetDirections:(UIButton *)sender
{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.place.coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem openInMapsWithLaunchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil]];
}

@end
