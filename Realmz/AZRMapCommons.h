//
//  AZRGraphicsCommons.h
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGSize tileSize = {32.f,32.f};

struct AZRIntPoint {
  int x, y;
};
typedef struct AZRIntPoint AZRIntPoint;

static inline AZRIntPoint AZRIntPointMake(int x, int y) {
	AZRIntPoint p;
	p.x = x;
	p.y = y;
	return p;
}

// x = a + b
// y = (a - b) / 2
static inline CGPoint cartXYtoIsoXY(CGPoint isoXY) {
	CGPoint p;
	p.x = isoXY.x + isoXY.y;
	p.y = (isoXY.x - isoXY.y) / 2.f;
	return p;
}

// a = x - b
// y = (x - b - b) / 2
// y = (x - 2b) / 2
// y = x / 2 - b
// b = x / 2 - y
// a = x - x / 2 + y
// a = x / 2 + y
static inline CGPoint isoXYtoCartXY(CGPoint cartXY) {
	CGPoint p;
	p.x = cartXY.x / 2.f + cartXY.y;
	p.y = cartXY.x / 2.f - cartXY.y;
	return p;
}


