#include <stdio.h>
#include <stdlib.h>
#include "defs.h"
#include <immintrin.h>

/* 
 * Please fill in the following team struct 
 */
who_t who = {
    "Barron Bloomfield",           /* Scoreboard name */

    "Winston Zhang",      /* First member full name */
    "wyz5rge@virginia.edu",     /* First member email address */
};

/*** UTILITY FUNCTIONS ***/

/* You are free to use these utility functions, or write your own versions
 * of them. */

/* A struct used to compute averaged pixel value */
typedef struct {
    unsigned short red;
    unsigned short green;
    unsigned short blue;
    unsigned short alpha;
    unsigned short num;
} pixel_sum;

/* Compute min and max of two integers, respectively */
static int min(int a, int b) { return (a < b ? a : b); }
static int max(int a, int b) { return (a > b ? a : b); }

/* 
 * initialize_pixel_sum - Initializes all fields of sum to 0 
 */
static void initialize_pixel_sum(pixel_sum *sum) 
{
    sum->red = sum->green = sum->blue = sum->alpha = 0;
    sum->num = 0;
    return;
}

/* 
 * accumulate_sum - Accumulates field values of p in corresponding 
 * fields of sum 
 */
static void accumulate_sum(pixel_sum *sum, pixel p) 
{
    sum->red += (int) p.red;
    sum->green += (int) p.green;
    sum->blue += (int) p.blue;
    sum->alpha += (int) p.alpha;
    sum->num++;
    return;
}

/* 
 * assign_sum_to_pixel - Computes averaged pixel value in current_pixel 
 */
static void assign_sum_to_pixel(pixel *current_pixel, pixel_sum sum) 
{
    current_pixel->red = (unsigned short) (sum.red/sum.num);
    current_pixel->green = (unsigned short) (sum.green/sum.num);
    current_pixel->blue = (unsigned short) (sum.blue/sum.num);
    current_pixel->alpha = (unsigned short) (sum.alpha/sum.num);
    return;
}

/* 
 * avg - Returns averaged pixel value at (i,j) 
 */
static pixel avg(int dim, int i, int j, pixel *src) 
{
    pixel_sum sum;
    pixel current_pixel;

    initialize_pixel_sum(&sum);
    for(int jj=max(j-1, 0); jj <= min(j+1, dim-1); jj++) 
	for(int ii=max(i-1, 0); ii <= min(i+1, dim-1); ii++) 
	    accumulate_sum(&sum, src[RIDX(ii,jj,dim)]);

    assign_sum_to_pixel(&current_pixel, sum);
 
    return current_pixel;
}

/*
 * computes averaged pixel value for an edge pixel
 */
/*
static void assign_sum_to_edge_pixel(pixel *current pixel, pixel_sum sum)
{
  sum.num = 6;
  
  current_pixel->red = (unsigned short) (sum.red/sum.num);
  urrent_pixel->green = (unsigned short) (sum.green/sum.num);
  current_pixel->blue = (unsigned short) (sum.blue/sum.num);
  current_pixel->alpha = (unsigned short) (sum.alpha/sum.num);
  return;
}
*/

/******************************************************
 * Your different versions of the smooth go here
 ******************************************************/

/* 
 * naive_smooth - The naive baseline version of smooth
 */
char naive_smooth_descr[] = "naive_smooth: Naive baseline implementation";
void naive_smooth(int dim, pixel *src, pixel *dst) 
{
    for (int i = 0; i < dim; i++)
	for (int j = 0; j < dim; j++)
            dst[RIDX(i,j, dim)] = avg(dim, i, j, src);
}
/* 
 * smooth - Your current working version of smooth
 *          Our supplied version simply calls naive_smooth
 */
char another_smooth_descr[] = "another_smooth: Another version of smooth";
void another_smooth(int dim, pixel *src, pixel *dst) 
{
    naive_smooth(dim, src, dst);
}

char smooth_checkpoint_descr[] = "smooth_checkpoint: my implementation of smooth for smooth checkpoint submission";
void smooth_checkpoint(int dim, pixel *src, pixel *dst)
{
  pixel_sum s;

  // Handling for top left corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(0, 0, dim)]);
  accumulate_sum(&s, src[RIDX(0, 1, dim)]);
  accumulate_sum(&s, src[RIDX(1, 0, dim)]);
  accumulate_sum(&s, src[RIDX(1, 1, dim)]);
  assign_sum_to_pixel(&dst[RIDX(0, 0, dim)], s);
  
  // Handling for top right corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(0, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(0, dim - 2, dim)]);
  accumulate_sum(&s, src[RIDX(1, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(1, dim - 2, dim)]);
  assign_sum_to_pixel(&dst[RIDX(0, dim - 1, dim)], s);

  // Handling for bottom left corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(dim - 1, 0, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 1, 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, 0, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, 1, dim)]);
  assign_sum_to_pixel(&dst[RIDX(dim - 1, 0, dim)], s);

  // Handling for bottom right corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(dim - 1, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 1, dim - 2, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, dim - 2, dim)]);
  assign_sum_to_pixel(&dst[RIDX(dim - 1, dim - 1, dim)], s);

  // Handling for top edge
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(0, i, dim)]);
      accumulate_sum(&s, src[RIDX(0, i - 1, dim)]);
      accumulate_sum(&s, src[RIDX(0, i + 1, dim)]);
      accumulate_sum(&s, src[RIDX(1, i - 1, dim)]);
      accumulate_sum(&s, src[RIDX(1, i, dim)]);
      accumulate_sum(&s, src[RIDX(1, i + 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(0, i, dim)], s);
    }

  // Handling for left edge
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(i, 0, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1,  0, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, 0, dim)]);
      accumulate_sum(&s, src[RIDX(i, 1, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1, 1, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(i, 0, dim)], s);

    }

  // Handling for right edge
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(i, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i, dim - 2, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1, dim - 2, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, dim - 2, dim)]);
      assign_sum_to_pixel(&dst[RIDX(i, dim - 1, dim)], s);

    }

  // Handling for bottom edge0
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(dim - 1, i, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 1, i - 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 1, i + 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, i, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, i - 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, i + 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(dim - 1, i, dim)], s);
    }

  // Handling for middle pixels
  for (int i = 1; i < dim - 1; i++)
    {
      for (int j = 1; j < dim - 1; j++)
	{
	  initialize_pixel_sum(&s);
	  accumulate_sum(&s, src[RIDX(i - 1, j - 1, dim)]);
	  accumulate_sum(&s, src[RIDX(i - 1, j, dim)]);
	  accumulate_sum(&s, src[RIDX(i - 1, j + 1, dim)]);
	  accumulate_sum(&s, src[RIDX(i, j - 1, dim)]);
	  accumulate_sum(&s, src[RIDX(i, j, dim)]);
	  accumulate_sum(&s, src[RIDX(i, j + 1, dim)]);
	  accumulate_sum(&s, src[RIDX(i + 1, j - 1, dim)]);
	  accumulate_sum(&s, src[RIDX(i + 1, j, dim)]);
	  accumulate_sum(&s, src[RIDX(i + 1, j + 1, dim)]);
	  assign_sum_to_pixel(&dst[RIDX(i, j, dim)], s);
	}
    }
}

char smooth_final_descr[] = "smooth_final: final implementation for smooth function";
void smooth_final(int dim, pixel *src, pixel *dst)
{    
  // Middle pixels
  for (int i = 1; i < dim - 1; i++)
    {
      for (int j = 1; j < dim - 1; j += 4)
	{
	  __m256i pixel_sum = _mm256_setzero_si256();
	  
	  /* General algorithm: load pixel at 128-bit vector then convert to 256-bit vector
	   *         then use vector instrinsic to add values
	   */
	  
	  // Center pixel
	  __m128i pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i, j, dim)]);
	  __m256i pixel_C = _mm256_cvtepu8_epi16(pixel);
	  pixel_sum = _mm256_add_epi16(pixel_C, pixel_sum);

	  // Top left pixel
	  pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i - 1, j - 1, dim)]);
	  __m256i pixel_TL = _mm256_cvtepu8_epi16(pixel);
	  pixel_sum = _mm256_add_epi16(pixel_TL, pixel_sum);

	  // Top middle pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i - 1, j, dim)]);
          __m256i pixel_TM = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_TM, pixel_sum);

	  // Top right pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i - 1, j + 1, dim)]);
          __m256i pixel_TR = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_TR, pixel_sum);

	  // Middle left pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i, j - 1, dim)]);
          __m256i pixel_ML = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_ML, pixel_sum);

	  // Middle right pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i, j + 1, dim)]);
          __m256i pixel_MR = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_MR, pixel_sum);

	  // Bottom left pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i + 1, j - 1, dim)]);
          __m256i pixel_BL = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_BL, pixel_sum);

	  // Bottom middle pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i + 1, j, dim)]);
          __m256i pixel_BM = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_BM, pixel_sum);

	  // Bottom right pixel
          pixel = _mm_loadu_si128((__m128i*) &src[RIDX(i + 1, j + 1, dim)]);
          __m256i pixel_BR = _mm256_cvtepu8_epi16(pixel);
          pixel_sum = _mm256_add_epi16(pixel_BR, pixel_sum);

	  // Assign accumulation of values
	  unsigned short pixel_RGBA[16];
	  _mm256_storeu_si256((__m256i*) pixel_RGBA, pixel_sum);

	  dst[RIDX(i, j, dim)].red = (pixel_RGBA[0] * 7282) >> 16;
	  dst[RIDX(i, j, dim)].green = (pixel_RGBA[1] * 7282) >> 16;
	  dst[RIDX(i, j, dim)].blue = (pixel_RGBA[2] * 7282) >> 16;
	  dst[RIDX(i, j, dim)].alpha = (pixel_RGBA[3] * 7282) >> 16;

	  dst[RIDX(i, j + 1, dim)].red = (pixel_RGBA[4] * 7282) >> 16;
          dst[RIDX(i, j + 1, dim)].green = (pixel_RGBA[5] * 7282) >> 16;
          dst[RIDX(i, j + 1, dim)].blue = (pixel_RGBA[6] * 7282) >> 16;
          dst[RIDX(i, j + 1, dim)].alpha = (pixel_RGBA[7] * 7282) >> 16;

	  dst[RIDX(i, j + 2, dim)].red = (pixel_RGBA[8] * 7282) >> 16;
          dst[RIDX(i, j + 2, dim)].green = (pixel_RGBA[9] * 7282) >> 16;
          dst[RIDX(i, j + 2, dim)].blue = (pixel_RGBA[10] * 7282) >> 16;
          dst[RIDX(i, j + 2, dim)].alpha = (pixel_RGBA[11] * 7282) >> 16;

	  dst[RIDX(i, j + 3, dim)].red = (pixel_RGBA[12] * 7282) >> 16;
          dst[RIDX(i, j + 3, dim)].green = (pixel_RGBA[13] * 7282) >> 16;
          dst[RIDX(i, j + 3, dim)].blue = (pixel_RGBA[14] * 7282) >> 16;
          dst[RIDX(i, j + 3, dim)].alpha = (pixel_RGBA[15] * 7282) >> 16;
	}
    }

  pixel_sum s;

  // Top left corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(0, 0, dim)]);
  accumulate_sum(&s, src[RIDX(0, 1, dim)]);
  accumulate_sum(&s, src[RIDX(1, 0, dim)]);
  accumulate_sum(&s, src[RIDX(1, 1, dim)]);
  assign_sum_to_pixel(&dst[RIDX(0, 0, dim)], s);

  // Top right corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(0, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(0, dim - 2, dim)]);
  accumulate_sum(&s, src[RIDX(1, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(1, dim - 2, dim)]);
  assign_sum_to_pixel(&dst[RIDX(0, dim - 1, dim)], s);

  // Bottom left corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(dim - 1, 0, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 1, 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, 0, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, 1, dim)]);
  assign_sum_to_pixel(&dst[RIDX(dim - 1, 0, dim)], s);

  // Bottom right corner
  initialize_pixel_sum(&s);
  accumulate_sum(&s, src[RIDX(dim - 1, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 1, dim - 2, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, dim - 1, dim)]);
  accumulate_sum(&s, src[RIDX(dim - 2, dim - 2, dim)]);
  assign_sum_to_pixel(&dst[RIDX(dim - 1, dim - 1, dim)], s);

  // Top edge
  for (int j = 1; j < dim - 1; j++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(0, j, dim)]);
      accumulate_sum(&s, src[RIDX(0, j - 1, dim)]);
      accumulate_sum(&s, src[RIDX(0, j + 1, dim)]);
      accumulate_sum(&s, src[RIDX(1, j - 1, dim)]);
      accumulate_sum(&s, src[RIDX(1, j, dim)]);
      accumulate_sum(&s, src[RIDX(1, j + 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(0, j, dim)], s);
    }
  
  // Left edge
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(i - 1, 0, dim)]);
      accumulate_sum(&s, src[RIDX(i, 0, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, 0, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1, 1, dim)]);
      accumulate_sum(&s, src[RIDX(i, 1, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(i, 0, dim)], s);
    }

  // Right edge
  for (int i = 1; i < dim - 1; i++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(i - 1, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, dim - 1, dim)]);
      accumulate_sum(&s, src[RIDX(i - 1, dim - 2, dim)]);
      accumulate_sum(&s, src[RIDX(i, dim - 2, dim)]);
      accumulate_sum(&s, src[RIDX(i + 1, dim - 2, dim)]);
      assign_sum_to_pixel(&dst[RIDX(i, dim - 1, dim)], s);
    }

  // Bottom edge
  for (int j = 1; j < dim - 1; j++)
    {
      initialize_pixel_sum(&s);
      accumulate_sum(&s, src[RIDX(dim - 1, j, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 1, j - 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 1, j + 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, j, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, j - 1, dim)]);
      accumulate_sum(&s, src[RIDX(dim - 2, j + 1, dim)]);
      assign_sum_to_pixel(&dst[RIDX(dim - 1, j, dim)], s);
    }
}

/*********************************************************************
 * register_smooth_functions - Register all of your different versions
 *     of the smooth function by calling the add_smooth_function() for
 *     each test function. When you run the benchmark program, it will
 *     test and report the performance of each registered test
 *     function.  
 *********************************************************************/

void register_smooth_functions() {
    add_smooth_function(&naive_smooth, naive_smooth_descr);
    // add_smooth_function(&another_smooth, another_smooth_descr);
    add_smooth_function(&smooth_checkpoint, smooth_checkpoint_descr);
    add_smooth_function(&smooth_final, smooth_final_descr);
}
