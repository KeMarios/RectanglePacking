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

@property (nonatomic, strong) NSMutableArray <Tile *> *tiles;
@property (nonatomic, strong) NSMutableArray <NSArray *> *packedTiles;
@property (nonatomic, assign) NSUInteger maxLine;

@property (nonatomic, assign) SizeTiles sizeTiles;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

@synthesize tiles, packedTiles;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *appName = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    [self.navigationItem setTitle:appName];
    
    self.navigationItem.rightBarButtonItem.action = @selector(refresh:);
    self.navigationItem.rightBarButtonItem.target = self;
    
    [self generateSize];
    [self generateTiles];
    [self changeOrientation];
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

- (NSMutableArray <Tile *> *)tiles
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
    CGSize big = CGSizeMake(3, 3);
    RatioSizeTiles ratioSizeBig = RatioSizeTilesMake(big, big.width/big.height);
    
    self.sizeTiles = SizeTilesMake(ratioSizeSmall, ratioSizeMedium, ratioSizeBig);
}

- (void)generateTiles
{
    NSUInteger max = RAND_FROM_TO(10, 50);
    //max = 6;
    [self.tiles removeAllObjects];
    RatioSizeTiles size;
    
    for (NSInteger i = 0; i < max; i++) {
        size = [self getSizeTileWithTileType:[self randomType]];
        
//        if(i == 0){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 1){
//            size = [self getSizeTileWithTileType:TileTypeMedium];
//        }else if(i == 2){
//            size = [self getSizeTileWithTileType:TileTypeMedium];
//        }else if(i == 3){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 4){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }else if(i == 5){
//            size = [self getSizeTileWithTileType:TileTypeBig];
//        }
        
        
        if(size.size.width == 0 || size.size.height == 0){
            continue;
        }
        
        Tile *tile = [[Tile alloc] initWithRemoteID:@(i) ratioSize:size];
        [self.tiles addObject:tile];
        //NSLog(@"tile: %@ size: %@, color: %@", tile.remote_id, NSStringFromCGSize(tile.ratioSize.size), tile.color);
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
    
    NSArray *sortedArrayOfString = [self.tiles sortedArrayUsingComparator:^NSComparisonResult(Tile * _Nonnull obj1, Tile * _Nonnull obj2) {
        
        float ration1 = obj1.ratioSize.ratio * (obj1.ratioSize.size.width + obj1.ratioSize.size.height) + (obj1.ratioSize.size.width + obj1.ratioSize.size.height);
        float ration2 = obj2.ratioSize.ratio * (obj2.ratioSize.size.width + obj2.ratioSize.size.height) + (obj2.ratioSize.size.width + obj2.ratioSize.size.height);
        NSLog(@"ratio: %f ratio: %f", ration1, ration2);
        if (ration1 > ration2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (ration1 < ration2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    [sortedArrayOfString enumerateObjectsUsingBlock:^(Tile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"idx: %lu size: %@ i: %lu w: %lu", (unsigned long)idx, NSStringFromCGSize(obj.ratioSize.size), (unsigned long)i, (unsigned long)w);
        if(w + obj.ratioSize.size.width > self.maxLine){
            ++i;
            if(i < self.packedTiles.count){
                w = [(NSArray *)self.packedTiles[i] count];
                while (w + obj.ratioSize.size.width > self.maxLine) {
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

- (void)addTileToPacking:(Tile *)tile index:(NSUInteger)i
{
    CGFloat width = tile.ratioSize.size.width;
    NSUInteger w = width;
    NSUInteger h = tile.ratioSize.size.height;
    
    NSUInteger j = i;
    
    while (w > 0) {
        [self.packedTiles addObject:tile toIndex:j];
        //NSLog(@"j: %lu count: %lu remote_id: %@",(unsigned long)j, (unsigned long)[(NSArray *)self.packedTiles[j] count], tile.remote_id);
        tile = [Tile new];
        --w;
    }
    
    while (h > 1) {
        ++j;
        --h;
        w = width;
        while (w > 0) {
            [self.packedTiles addObject:tile toIndex:j];
            --w;
        }
    }
}

#pragma mark
#pragma mark Size

- (TileType)randomType
{
    //return TileTypeBig;
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
#pragma mark Create

- (void)createTileView
{
    for (UIView *view in self.scrollView.subviews) {
        if([view isKindOfClass:[TileView class]]){
            [view removeFromSuperview];
        }
    }
    
    NSUInteger margin = 10;
    NSUInteger size = (self.view.bounds.size.width - margin * 2) / self.maxLine;
    __block TileView *view;
    
    [self.packedTiles enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(Tile * _Nonnull tile, NSUInteger j, BOOL * _Nonnull stop) {
            if(tile.remote_id){
                view = [[TileView alloc] init];
                view.backgroundColor = tile.color;
                view.frame = CGRectMake(margin + j * size, margin + i * size, tile.ratioSize.size.width * size, tile.ratioSize.size.height * size);
                [self.scrollView addSubview:view];
                NSLog(@"i: %lu j: %lu w: %lu h: %lu frame: %@", (unsigned long)i, (unsigned long)j, (unsigned long)tile.ratioSize.size.width, (unsigned long)tile.ratioSize.size.height, NSStringFromCGRect(view.frame));
            }
        }];
    }];
    NSLog(@"---------------");
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
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
