//
//  AZRMapLayer.m
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMapLayer.h"
#import "AZRMapLayerCellShortcut.h"

@implementation AZRMapLayer
@synthesize shortcuts = _shortcuts;
@synthesize gridData = _gridData;
@synthesize width = _width;
@synthesize height = _height;

- (AZRMapLayerCellShortcut *) addShortcut:(int)uid forIdentifier:(NSString *)identifier {
	if (!_shortcuts)
		_shortcuts = [NSMutableDictionary dictionary];

	AZRMapLayerCellShortcut *shortcut = _shortcuts[@(uid)];
	if (!shortcut) {
		shortcut = [AZRMapLayerCellShortcut new];
		[shortcut setUid:uid];
		[shortcut setIdentifier:identifier];
		_shortcuts[@(uid)] = shortcut;
	} else {
		[shortcut setIdentifier:identifier];
	}
	return shortcut;
}

- (void) setGridData:(NSMutableArray *)gridData {
	if (!_gridData)
		_gridData = [NSMutableArray array];
	else
		[_gridData removeAllObjects];

	_height = [gridData count];
	NSUInteger w = 0;
	for (NSString *row in gridData) {
    w = MAX(w, [row length]);
		[_gridData addObject:[row mutableCopy]];
	}
	[self makeSureGridContainsPoint:AZRIntPointMake(ceil(w / 2.f), ceil(_height / 2.f))];
}

- (void) pointToRelativeGridPoint:(AZRIntPoint *)point {
	point->x += _width / 2;
	point->y += _height / 2;
}

- (void) makeSureGridContainsPoint:(AZRIntPoint)point {
	int newW = CONSTRAINT((ABS(point.x) + 1) * 2, _width, INT_MAX);
	int newH = CONSTRAINT((ABS(point.y) + 1) * 2, _height, INT_MAX);

	if (!_gridData)
		_gridData = [NSMutableArray array];

	// expand rows if needed
	if (newW != _width) {
		NSMutableArray *rows = [NSMutableArray array];
		for (NSString *row in _gridData) {
			NSUInteger oldLength = [row length];
			NSString *added = [@"" stringByPaddingToLength:(newW - oldLength) withString:@"0" startingAtIndex:0];
			NSString *newRow = [[added stringByReplacingCharactersInRange:NSMakeRange((newW - oldLength) / 2, 0) withString:row] mutableCopy];
			[rows addObject:newRow];
		}
		_gridData = rows;
		_width = newW;
	}

	// add rows if needed
	if (newH != _height) {
		int toAdd = newH - [_gridData count];
		NSString *added = [@"" stringByPaddingToLength:newW withString:@"0" startingAtIndex:0];
		while (toAdd-- > 0) {
			[_gridData addObject:[added mutableCopy]];
			if (toAdd-- > 0)
				[_gridData insertObject:[added mutableCopy] atIndex:0];
		}
		_height = newH;
	}
}

- (NSMutableString *) gridRow:(int)row {
	return _gridData[row + _height / 2];
}

- (int) gridCellRelativeToX:(int)x andY:(int)y {
	unichar c = [_gridData[y] characterAtIndex:x];
	int cell = 0;
	if ((c >= '0') && (c <= '9'))
		cell = c - '0';
	else if ((c >= 'A') && (c <= 'Z'))
		cell = (c - 'A') + 10;
	else if ((c >= 'a') && (c <= 'z'))
		cell = (c - 'a') + 10;

	return cell;
}

- (int) gridCellAtXY:(AZRIntPoint)point {
	[self pointToRelativeGridPoint:&point];
	return [self gridCellRelativeToX:point.x andY:point.y];
}

- (void) setGridCell:(int)cell atXY:(AZRIntPoint)point {
	[self makeSureGridContainsPoint:point];

	[self pointToRelativeGridPoint:&point];
	NSMutableString *row = _gridData[point.y];
	[row replaceCharactersInRange:NSMakeRange(point.x, 1) withString:[@(cell) stringValue]];
}

@end
