

#*****************************************************************************
# accu.S
#-----------------------------------------------------------------------------
#
# Test accu instruction.
#

#include "riscv_test.h"
#include "riscv_test_rocc.h"
#include "test_macros.h"
#include "accumulator.h"



#define CUSTOM_X 0

  RVTEST_WITH_ROCC

start:

  RVTEST_CODE_BEGIN

  // k_DO_READ after k_DO_WRITE
  li a0, 1
  lw a1, data
  li a5, 3
  li a6, 7
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 11, 10, k_DO_WRITE)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 10,  0, 10, k_DO_READ)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 15,  0, k_DO_WRITE)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 13,  0,  0, k_DO_READ)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 13,  1, k_DO_WRITE)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 14,  0,  1, k_DO_READ)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 16,  2, k_DO_WRITE)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 18,  0,  2, k_DO_READ)
  //  ~操作一次读写后立即对Core内部寄存器进行加法操作会出错。
  //ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 15,  0, k_DO_WRITE)
  //对li进来的数据进行加法就不会出现阻塞，对Rocc写回的需要等待4cycle的时间因此会出现阻塞。
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 14,  0, k_DO_ACCUM)
  //ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X,  0, 16,  0, k_DO_ACCUM)
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 17,  0,  0, k_DO_READ)
  TEST_CASE(1, a0, 0xdead, )

  // k_DO_ACCUM should return old value
  li a0, 1
  lw a2, data + 8
  sub a2, a2, a1
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 10, 12, 10, k_DO_ACCUM)
  TEST_CASE(2, a0, 0xdead, )

  // k_DO_ACCUM should have accumulated
  li a0, 1
  lw a2, data + 8
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 10, 0, 10, k_DO_READ)
  TEST_CASE(3, a0, 0xbeef, )

  // k_DO_LOAD should return old value
  li a0, 1
  la a1, data + 16
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 10, 11, 10, k_DO_LOAD)
  TEST_CASE(4, a0, 0xbeef, )

  // k_DO_LOAD should load new value
  li a0, 1
  ROCC_INSTRUCTION_RAW_R_R_R(CUSTOM_X, 10, 0, 10, k_DO_READ)
  TEST_CASE(5, a0, 0x0bad, )

  TEST_PASSFAIL

  RVTEST_CODE_END

  .data
  RVTEST_DATA_BEGIN

  TEST_DATA
data:
  .dword 0xdead
  .dword 0xbeef
  .dword 0x0bad
  .dword 0xf00d

  RVTEST_DATA_END

