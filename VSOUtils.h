/*
 *  VSOUtils.h
 *  GPS Body Paint
 *
 *  Created by François Lamboley on 7/16/09.
 *  Copyright 2009 VSO-Software. All rights reserved.
 *
 */

#include <stdlib.h>

#ifndef NDEBUG
#define NSDLog(format...) NSLog(format)
#else
#define NSDLog(format...) (void)NULL
#endif

void *mallocTable(unsigned int size, size_t sizeOfElementsInTable);
void **malloc2DTable(unsigned int xSize, unsigned int ySize, size_t sizeOfElementsInTable);
void ***malloc3DTable(unsigned int xSize, unsigned int ySize, unsigned int zSize, size_t sizeOfElementsInTable);

void free2DTable(void **b, unsigned int xSize);
void free3DTable(void ***b, unsigned int xSize, unsigned int ySize);
