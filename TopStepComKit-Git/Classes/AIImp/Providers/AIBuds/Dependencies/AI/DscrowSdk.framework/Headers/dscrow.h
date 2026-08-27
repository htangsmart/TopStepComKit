#ifndef DSCROW_H
#define DSCROW_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ================================================================== */
/*  Compile-time constant                                              */
/* ================================================================== */


/* ================================================================== */
/*  Opaque state handle                                                */
/* ================================================================== */
typedef struct DscrowState DscrowState;


/* ================================================================== */
/*  Initialisation — placement (no heap required)                      */
/* ================================================================== */

/*
 * dscrow_init
 *   Initialise the library state inside a caller-provided memory buffer.
 *
 *   buffer      : pointer to a buffer >= DSCROW_STATE_SIZE bytes.
 *   buffer_size : byte count of the buffer (allows runtime validation).
 *
 *   Returns buffer cast to DscrowState * on success, NULL on failure
 *   (buffer is NULL or buffer_size < DSCROW_STATE_SIZE).
 */
DscrowState *dscrow_init(void *buffer, size_t buffer_size);

/*
 * dscrow_reset
 *   Re-initialise all caches and hidden states to zero.
 *   Call between audio streams to restart from silence.
 */
void dscrow_reset(DscrowState *state);


/* ================================================================== */
/*  Error codes                                                        */
/* ================================================================== */
#define DSCROW_OK              0
#define DSCROW_ERR_TIME_LIMIT  (-1)


/* ================================================================== */
/*  Streaming inference                                                */
/* ================================================================== */

/*
 * dscrow_process_samples
 *   Process 256 PCM samples, produce 256 denoised PCM samples.
 *   Latency = 256 samples = 16 ms at 16 kHz.
 *
 *   state   : pointer returned from dscrow_init().
 *   pcm_in  : short[256]  normalised PCM  input [-32768, 32767].
 *   pcm_out : short[256]  normalised PCM output [-32768, 32767].
 *
 *   Returns DSCROW_OK (0) on success.
 *   Returns DSCROW_ERR_TIME_LIMIT (-1) when trial time limit is reached
 *   (pcm_out is filled with silence in this case).
 */
int dscrow_process_samples(DscrowState     *state,
                           const short     *pcm_in,
                           short           *pcm_out);


/* ================================================================== */
/*  Helpers — heap convenience                                         */
/* ================================================================== */

/*
 * dscrow_get_state_size
 *   Runtime equivalent of DSCROW_STATE_SIZE.  Returns sizeof(DscrowState).
 *   Useful when the caller prefers dynamic sizing over the compile-time
 *   constant (e.g. when the library is loaded dynamically).
 */
size_t dscrow_get_state_size(void);

/*
 * dscrow_create
 *   Heap-convenience wrapper: allocates a DscrowState internally and
 *   returns it initialised.  Only available when malloc/free are linked.
 *   Returns NULL on allocation failure.
 */
DscrowState *dscrow_create(void);

/*
 * dscrow_destroy
 *   Free a DscrowState previously obtained from dscrow_create().
 *   Calling on a placement-constructed state is undefined behaviour.
 */
void dscrow_destroy(DscrowState *state);


#ifdef __cplusplus
}
#endif

#endif /* DSCROW_H */
