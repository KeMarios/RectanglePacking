//
//  ViewController.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "ViewController.h"
#import "Tile.h"
#import "Unit.h"
#import "NSMutableArray+MultiMutableArray.h"
#import "TileView.h"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))
#define MAX_LINE_LANDSCAPE 15
#define MAX_LINE_PORTRAIT 6

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray <TileView *> *tiles;
@property (nonatomic, strong) NSMutableArray <NSArray *> *packedTiles;
@property (nonatomic, assign) NSUInteger maxLine;

@property (nonatomic, assign) SizeTiles sizeTiles;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@end

@implementation ViewController

@synthesize tiles, packedTiles;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem.action = @selector(refresh:);
    self.navigationItem.rightBarButtonItem.target = self;
    
    [self autolayoutScrollView];
    [self setTitleWithTiles:0];
    
    [self generateSize];
    [self generateTiles];
    [self changeOrientation];
}

- (void)setTitleWithTiles:(NSUInteger)count
{
    NSString *appName = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ (%li)", appName, (unsigned long)count]];
}

- (void)changeOrientation
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        self.maxLine = MAX_LINE_LANDSCAPE;
    }else{
        self.maxLine = MAX_LINE_PORTRAIT;
    }
    
    [self algorithmTiles];
    [self createTileView];
}

#pragma mark
#pragma mark Handlers

- (IBAction)refresh:(id)sender
{
    [self generateTiles];
    [self algorithmTiles];
    [self createTileView];
}

#pragma mark
#pragma mark Array

- (NSMutableArray <TileView *> *)tiles
{
    if(!tiles){
        tiles = [[NSMutableArray alloc] init];
    }
    return tiles;
}

- (NSMutableArray <NSArray *> *)packedTiles
{
    if(!packedTiles){
        packedTiles = [[NSMutableArray alloc] init];
    }
    return packedTiles;
}

#pragma mark
#pragma mark Generate

- (void)generateSize
{
    CGSize small = CGSizeMake(1, 1);
    RatioSizeTiles ratioSizeSmall = RatioSizeTilesMake(small, small.width/small.height);
    CGSize medium = CGSizeMake(2, 1);
    RatioSizeTiles ratioSizeMedium = RatioSizeTilesMake(medium, medium.width/medium.height);
    CGSize big = CGSizeMake(4, 2);
    RatioSizeTiles ratioSizeBig = RatioSizeTilesMake(big, big.width/big.height);
    
    self.sizeTiles = SizeTilesMake(ratioSizeSmall, ratioSizeMedium, ratioSizeBig);
}

- (void)generateTiles
{
    NSUInteger max = RAND_FROM_TO(10, 50);
    //max = 10;
    [self setTitleWithTiles:max];
    
    for (UIView *view in self.containerView.subviews) {
        if([view isKindOfClass:[TileView class]]){
            [view removeFromSuperview];
        }
    }
    
    [self.tiles removeAllObjects];
    
    RatioSizeTiles size;
    __block Tile *tile;
    __block TileView *tView;
    
    for (NSInteger i = 0; i < max; i++) {
        size = [self getSizeTileWithTileType:[self randomType]];
        
//        if(i == 0){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 1){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 2){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 3){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 4){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 5){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }
//        size = [self getSizeTileWithTileType:TileTypeBig];
        
        if(size.size.width == 0 || size.size.height == 0){
            continue;
        }
        
        tile = [[Tile alloc] initWithRemoteID:@(i) ratioSize:size];
        tView = [[TileView alloc] initWithTile:tile];
        [self.tiles addObject:tView];
    }
    
    //NSLog(@"max: %li tiles: %li", (long)max, (long)self.tiles.count);
}

#pragma mark
#pragma mark

- (void)algorithmTiles
{
    __block NSUInteger i = 0;
    __block NSUInteger w = 0;
    
    [self.packedTiles removeAllObjects];
    
    // sortowanie ration
    NSArray *sortedArrayOfString = [self.tiles sortedArrayUsingComparator:^NSComparisonResult(TileView * _Nonnull obj1, TileView * _Nonnull obj2) {
        float ration1 = obj1.tile.ratioSize.ratio * (obj1.tile.ratioSize.size.width + obj1.tile.ratioSize.size.height) + (obj1.tile.ratioSize.size.width + obj1.tile.ratioSize.size.height);
        float ration2 = obj2.tile.ratioSize.ratio * (obj2.tile.ratioSize.size.width + obj2.tile.ratioSize.size.height) + (obj2.tile.ratioSize.size.width + obj2.tile.ratioSize.size.height);
        NSLog(@"ratio: %f ratio: %f", ration1, ration2);
        if (ration1 > ration2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (ration1 < ration2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    [sortedArrayOfString enumerateObjectsUsingBlock:^(TileView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"idx: %lu size: %@ i: %lu j: %lu frame: %@", (unsigned long)idx, NSStringFromCGSize(obj.tile.ratioSize.size), (unsigned long)i, (unsigned long)w, NSStringFromCGRect(obj.frame));
        if(w + obj.tile.ratioSize.size.width > self.maxLine){
            ++i;
            if(i < self.packedTiles.count){
                w = [(NSArray *)self.packedTiles[i] count];
                while (w + obj.tile.ratioSize.size.width > self.maxLine) {
                    ++i;
                    w = 0;
                    if(i < self.packedTiles.count){
                        w = [(NSArray *)self.packedTiles[i] count];
                    }
                }
            }
        }
        [self addTileToPacking:obj index:i];
        i = 0;
        w = [(NSArray *)self.packedTiles[i] count];
        //NSLog(@"i: %lu w: %lu",(unsigned long)i, (unsigned long)w);
    }];
    
    //NSLog(@"self.packedTiles: %@", self.packedTiles);
}

- (void)addTileToPacking:(TileView *)tileView index:(NSUInteger)i
{
    NSUInteger w = tileView.tile.ratioSize.size.width;
    NSUInteger h = tileView.tile.ratioSize.size.height;
    NSUInteger j = i;
    BOOL active = YES;
    
    while (w > 0) {
        //NSLog(@"add: %@", active ? @"YES" : @"NO");
        [self.packedTiles addObject:@{@"tileView" : tileView, @"active" : @(active)} toIndex:j];
        active = NO;
        --w;
    }
    
    while (h > 1) {
        ++j;
        --h;
        w =  tileView.tile.ratioSize.size.width;
        while (w > 0) {
            //NSLog(@"add: %@", active ? @"YES" : @"NO");
            [self.packedTiles addObject:@{@"tileView" : tileView, @"active" : @(active)} toIndex:j];
            active = NO;
            --w;
        }
    }
}

#pragma mark
#pragma mark Create

- (void)createTileView
{
    // czyszczenie constrains
    for (UIView *view in self.containerView.subviews) {
        if([view isKindOfClass:[TileView class]]){
            [view removeConstraints:view.constraints];
            [self.containerView removeConstraints:view.constraints];
            NSLog(@"tileView: %@", view.constraints);
        }
    }
    [self.containerView removeConstraints:self.containerView.constraints];
    NSLog(@"containerView: %@", self.containerView.constraints);
    
    __block TileView *tileView;
    __block TileView *oldTileView;
    
    NSUInteger margin = 10;
    NSUInteger size = (self.view.bounds.size.width - margin * 2) / self.maxLine;
    __block BOOL animation;
    
    [self.packedTiles enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger j, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger i, BOOL * _Nonnull stop) {
            if([[dic objectForKey:@"active"] boolValue]){
                tileView = [dic objectForKey:@"tileView"];
                animation = YES;
                
                if(![self.containerView.subviews containsObject:tileView]){
                    animation = NO;
                    tileView.translatesAutoresizingMaskIntoConstraints = NO;
                    [self.containerView addSubview:tileView];
                }
                [tileView autosize];
                
                NSLog(@"i: %lu j: %lu w: %lu h: %lu", (unsigned long)i, (unsigned long)j, (unsigned long)tileView.tile.ratioSize.size.width, (unsigned long)tileView.tile.ratioSize.size.height);
                
                if (i == 0) {
                    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[view]"
                                                                                               options:0
                                                                                               metrics:0
                                                                                                 views:@{@"view":tileView}]];
                }else{
                    NSUInteger w = [self getWidthTileViewWithIndexI:i-1 indexJ:j];
                    oldTileView = [self getTileViewWithIndexI:i-w indexJ:j];
                    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view]-0-[view2]"
                                                                                               options:0
                                                                                               metrics:0
                                                                                                 views:@{@"view":oldTileView,
                                                                                                         @"view2":tileView}]];
                }
                
                if(j == 0){
                    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[view]"
                                                                                               options:0
                                                                                               metrics:0
                                                                                                 views:@{@"view":tileView}]];
                }else{
                    NSUInteger h = [self getHeightTileViewWithIndexI:i indexJ:j-1];
                    oldTileView = [self getTileViewWithIndexI:i indexJ:j-h];
                    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-0-[view2]"
                                                                                               options:0
                                                                                               metrics:0
                                                                                                 views:@{@"view":oldTileView,
                                                                                                         @"view2":tileView}]];
                }
                
                if(j + tileView.tile.ratioSize.size.height >= self.packedTiles.count){
                    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-10-|"
                                                                                               options:0
                                                                                               metrics:0
                                                                                                 views:@{@"view":tileView}]];
                }
                
                [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(value)]"
                                                                                           options:0 metrics:@{@"value" : @(tileView.tile.ratioSize.size.width * size)} views:@{@"view":tileView}]];
                [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(value)]"
                                                                                           options:0 metrics:@{@"value" : @(tileView.tile.ratioSize.size.height * size)} views:@{@"view":tileView}]];
                
                [self.containerView setNeedsUpdateConstraints];
                [self performUIChanges:^{
                    [self.containerView layoutIfNeeded];
                } completion:nil animated:animation];
            }
        }];
    }];
    NSLog(@"---------------");
}

- (TileView *)getTileViewWithIndexI:(NSUInteger)i indexJ:(NSUInteger)j
{
    NSDictionary *dic = self.packedTiles[j][i];
    return [dic objectForKey:@"tileView"];
}

- (NSUInteger)getWidthTileViewWithIndexI:(NSUInteger)i indexJ:(NSUInteger)j
{
    NSDictionary *dic = self.packedTiles[j][i];
    TileView *tile = [dic objectForKey:@"tileView"];
    return tile.tile.ratioSize.size.width;
}

- (NSUInteger)getHeightTileViewWithIndexI:(NSUInteger)i indexJ:(NSUInteger)j
{
    NSDictionary *dic = self.packedTiles[j][i];
    TileView *tile = [dic objectForKey:@"tileView"];
    return tile.tile.ratioSize.size.height;
}

- (void)performUIChanges:(void(^)(void))changes completion:(void(^)(void))completion animated:(BOOL)animated
{
    if ( animated ){
        [UIView animateWithDuration:1.25 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.9 options:0 animations:^{
            if(changes)changes();
        } completion:^(BOOL finished) {
            if(completion)completion();
        }];
    }
    else{
        if(changes)changes();
        if(completion)completion();
    }
}

#pragma mark
#pragma mark Size

- (TileType)randomType
{
    return arc4random_uniform(3);
}

- (RatioSizeTiles)getSizeTileWithTileType:(TileType)type
{
    RatioSizeTiles size;
    switch (type) {
        case TileTypeSmall:
            size = self.sizeTiles.small;
            break;
            
        case TileTypeMedium:
            size = self.sizeTiles.medium;
            break;
            
        case TileTypeBig:
            size = self.sizeTiles.big;
            break;
            
        default:
            break;
    }
    return size;
}

#pragma mark
#pragma mark Autolayout

- (void)autolayoutScrollView
{
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.containerView];
    
    [self.scrollView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|"
                                             options:0 metrics:nil
                                               views:@{@"containerView":self.containerView}]];
    [self.scrollView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|"
                                             options:0 metrics:nil
                                               views:@{@"containerView":self.containerView}]];
    
    [self.scrollView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView(==scrollView)]|"
                                             options:0
                                             metrics:nil
                                               views:@{@"containerView":self.containerView,
                                                       @"scrollView":self.scrollView}]];
    
    self.scrollView.backgroundColor = [UIColor redColor];
    self.containerView.backgroundColor = [UIColor yellowColor];
}

#pragma mark
#pragma mark Orientations

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskAll);
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
//        //NSLog(@"i am in landscape mode");
//        [self changeOrientation];
//    }
//    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)){
//        //NSLog(@"i am in portrait mode");
//        [self changeOrientation];
//    }
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        //NSLog(@"i am in landscape mode");
        [self changeOrientation];
    }
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)){
        //NSLog(@"i am in portrait mode");
        [self changeOrientation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
