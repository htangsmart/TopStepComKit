// -----------------------------------------------------------------------------
// Copyright (c) 2023 Think Silicon S.A., an Applied Materials Company
// Think Silicon S.A., an Applied Materials Company Confidential Proprietary
// -----------------------------------------------------------------------------
//     All Rights reserved - Unpublished -rights reserved under
//         the Copyright laws of the European Union
//
//  This file includes the Confidential information of Think Silicon S.A., an
//  Applied Materials Company. The receiver of this Confidential Information
//  shall not disclose it to any third party and shall protect its confidentiality
//  by using the same degree of care, but not less than a reasonable degree of
//  care, as the receiver uses to protect receiver's own Confidential Information.
//  The entire notice must be reproduced on all authorised copies and copies may
//  only be made to the extent permitted by a licensing agreement from Think Silicon S.A.,
//  an Applied Materials Company
//
//  The software is provided 'as is', without warranty of any kind, express or
//  implied, including but not limited to the warranties of merchantability,
//  fitness for a particular purpose and noninfringement. In no event shall
//  Think Silicon S.A. be liable for any claim, damages or other liability, whether
//  in an action of contract, tort or otherwise, arising from, out of or in
//  connection with the software or the use or other dealings in the software.
//
//
//                    Think Silicon S.A., an Applied Materials Company
//                    http://www.think-silicon.com
//                    Patras Science Park
//                    Rion Achaias 26504
//                    Greece
// -----------------------------------------------------------------------------

#ifndef TSCCOMPRESSORLIB_H
#define TSCCOMPRESSORLIB_H

#include <cstdint>

#ifndef CUSTOM_FORMAT
#include "format.h"
#else
#include "../common/format.h"
#endif

#define IGNORE_TRANSPARENT_PIXELS 1 /**< Compression will ignore transparent pixels. Applicable to TSC6AHQ. First bit of the "flags" argument used in "CompressBlock" and "CompressImage" */

class TscCompressor
{

public:
    /** \brief Compress an RGBA block (4x4 or 2x2) to a compressed TSC formated block
     *  \param rgba_block pointer to the RGBA block (input block)
     *  \param tsc_block pointer to the TSC compressed block (output block). Must be allocated before calling this function.
     *  \param format TSC format (compression format)
     *  \param flags Bitfields for controlling the compression algorithm (see the defines at the top of this file)
     */
    static void CompressBlock( uint8_t const* rgba_block, uint8_t* tsc_block, Format format, uint32_t flags = 0U);

    /** \brief Compress an RGBA image (buffer) to a compressed TSC formated image (buffer).
     *  \param src_rgba pointer to the RGBA buffer (source buffer with image data)
     *  \param dst_tsc pointer to the TSC compressed buffer (destination buffer with compressed data). Must be allocated before calling this function.
     *  \param width source image width
     *  \param height source image height
     *  \param format TSC format (compression format)
     *  \param flags Bitfields for controlling the compression algorithm (see the defines at the top of this file)
     */
//    static void CompressImage( uint8_t const* src_rgba, uint8_t* dst_tsc, int width, int height, Format format, uint32_t flags = 0U);
    static void CompressImage( uint8_t const* src_rgba, uint8_t* dst_tsc, int width, int height, Format format);

    /** \brief Calculates the memory size (in bytes), needed for a TSC compressed buffer. Use this function
     *         to calculate the correct buffer/array size before allocationg them.
     *  \param width source image width
     *  \param height source image height
     *  \param format TSC format (compression format)
     */
    static int  GetTscSize(int width, int height, Format format);
};

#endif // TSCCOMPRESSORLIB_H
