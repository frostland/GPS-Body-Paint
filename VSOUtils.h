/*
 * VSOUtils.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/16/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#include <stdlib.h>


#ifndef NDEBUG
#define NSDLog(format...) NSLog(format)
#else
#define NSDLog(format...) (void)NULL
#endif


void *mallocTable(size_t size, size_t sizeOfElementsInTable);
void **malloc2DTable(size_t xSize, size_t ySize, size_t sizeOfElementsInTable);
void ***malloc3DTable(size_t xSize, size_t ySize, size_t zSize, size_t sizeOfElementsInTable);

void free2DTable(void **b, size_t xSize);
void free3DTable(void ***b, size_t xSize, size_t ySize);
