/*
 * VSOUtils.c
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/16/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#include <stdio.h>

#include "VSOUtils.h"



void *mallocTable(size_t size, size_t sizeOfElementsInTable) {
	void *b = malloc(size*sizeOfElementsInTable);
	if (b == NULL) {
		fprintf(stderr, "Cannot malloc %ld bytes. Exiting now.\n", size*sizeOfElementsInTable);
		exit(1);
	}
	
	return b;
}

void **malloc2DTable(size_t xSize, size_t ySize, size_t sizeOfElementsInTable) {
	void **b = mallocTable(xSize, sizeof(void*));
	
	for (size_t i = 0; i<xSize; i++)
		b[i] = mallocTable(ySize, sizeOfElementsInTable);
	
	return b;
}

void ***malloc3DTable(size_t xSize, size_t ySize, size_t zSize, size_t sizeOfElementsInTable) {
	void ***b = (void ***)malloc2DTable(xSize, ySize, sizeof(void*));
	
	for (size_t i = 0; i<xSize; i++)
		for (size_t j = 0; j<ySize; j++)
			b[i][j] = mallocTable(zSize, sizeOfElementsInTable);
	
	return b;
}

void free2DTable(void **b, size_t xSize) {
	for (size_t i = 0; i<xSize; i++)
		free(b[i]);
	
	free(b);
}

void free3DTable(void ***b, size_t xSize, size_t ySize) {
	for (size_t i = 0; i<xSize; i++)
		free2DTable(b[i], ySize);
	
	free(b);
}
