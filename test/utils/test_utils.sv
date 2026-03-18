//========================================================================
// test_utils
//========================================================================
// Author : Simeon Turner, Christopher Batten (Cornell)
// Date   : September 7, 2024
//
// Testing utilities library for C2S2
//

`ifndef TEST_UTILS_SV
`define TEST_UTILS_SV

//------------------------------------------------------------------------
// Colors
//------------------------------------------------------------------------

`define TEST_UTILS_RED    "\033[31m"
`define TEST_UTILS_GREEN  "\033[32m"
`define TEST_UTILS_YELLOW "\033[33m"
`define TEST_UTILS_RESET  "\033[0m"

//========================================================================
// CombinationalTestUtils
//========================================================================

module CombinationalTestUtils();

  logic clk;
  logic rst;

  // verilator lint_off BLKSEQ
  initial clk = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  // status tracking

  logic failed = 0;

  // This variable holds the +test-case command line argument indicating
  // which test cases to run.

  string vcd_filename;
  int n = 0;
  int test_suite = 0;
  initial begin

    if ( !$value$plusargs( "test-suite=%d", test_suite ) )
      test_suite = 0;

    if ( !$value$plusargs( "test-case=%d", n ) )
      n = 0;

    if ( $value$plusargs( "dump-vcd=%s", vcd_filename ) ) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

  end

  // Always call $urandom with this seed variable to ensure that random
  // test cases are both isolated and reproducible.

  // verilator lint_off UNUSEDSIGNAL
  int seed = 32'hdeadbeef;
  // verilator lint_on UNUSEDSIGNAL

  // Cycle counter with timeout check

  int cycles;

  always @( posedge clk ) begin

    if ( rst )
      cycles <= 0;
    else
      cycles <= cycles + 1;

    if ( cycles > 1000000 ) begin
      $display( "\nERROR (cycles=%0d): timeout!", cycles );
      $finish;
    end

  end

  //----------------------------------------------------------------------
  // test_bench_begin
  //----------------------------------------------------------------------

  task test_bench_begin();
    $display("");
    #1;
  endtask

  //----------------------------------------------------------------------
  // test_bench_end
  //----------------------------------------------------------------------

  task test_bench_end();
    $write("\n");
    if ( n == 0 )
      $write("\n");
    $finish;
  endtask

  //----------------------------------------------------------------------
  // test_suite_begin
  //----------------------------------------------------------------------

  task test_suite_begin( string suite_name );
    $write({"\n\n",suite_name});
  endtask

  //----------------------------------------------------------------------
  // test_suite_end
  //----------------------------------------------------------------------

  task test_suite_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_begin
  //----------------------------------------------------------------------

  task test_case_begin( string taskname );
    $write("%-40s ",taskname);
    if ( n != 0 )
      $write("\n");

    seed = 32'hdeadbeef;
    failed = 0;

    rst = 1;
    #30;
    rst = 0;
  endtask

  //----------------------------------------------------------------------
  // test_case_end
  //----------------------------------------------------------------------

  task test_case_end();
  endtask

endmodule

//========================================================================
// TestUtilsClkRst
//========================================================================

module TestUtilsClkRst
(
  output logic clk,
  output logic rst
);

  // verilator lint_off BLKSEQ
  initial clk = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  // status tracking

  logic failed = 0;

  // This variable holds the +test-case command line argument indicating
  // which test cases to run.

  string vcd_filename;
  int n = 0;
  int test_suite = 0;
  initial begin

    if ( !$value$plusargs( "test-suite=%d", test_suite ) )
      test_suite = 0;

    if ( !$value$plusargs( "test-case=%d", n ) )
      n = 0;

    if ( $value$plusargs( "dump-vcd=%s", vcd_filename ) ) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

  end

  // Always call $urandom with this seed variable to ensure that random
  // test cases are both isolated and reproducible.

  // verilator lint_off UNUSEDSIGNAL
  int seed = 32'hdeadbeef;
  // verilator lint_on UNUSEDSIGNAL

  // Cycle counter with timeout check

  int cycles;

  always @( posedge clk ) begin

    if ( rst )
      cycles <= 0;
    else
      cycles <= cycles + 1;

    if ( cycles > 1000000 ) begin
      $display( "\nERROR (cycles=%0d): timeout!", cycles );
      $finish;
    end

  end

  //----------------------------------------------------------------------
  // test_bench_begin
  //----------------------------------------------------------------------
  // We add this 1 tau delay at the beginning of the test bench to offset
  // all checks by 1 tau delay.

  task test_bench_begin();
    $display("");
    #1;
  endtask

  //----------------------------------------------------------------------
  // test_bench_end
  //----------------------------------------------------------------------

  task test_bench_end();
    $write("\n");
    if ( n == 0 )
      $write("\n");
    $finish;
  endtask

  //----------------------------------------------------------------------
  // test_suite_begin
  //----------------------------------------------------------------------

  task test_suite_begin( string suite_name );
    $write({"\n\n", suite_name});
  endtask

  //----------------------------------------------------------------------
  // test_suite_end
  //----------------------------------------------------------------------

  task test_suite_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_begin
  //----------------------------------------------------------------------

  task test_case_begin( string taskname );
    $write("\n%s ",taskname);
    if ( n != 0 )
      $write("\n");

    seed = 32'hdeadbeef;
    failed = 0;

    rst = 1;
    #30;
    rst = 0;
  endtask

  //----------------------------------------------------------------------
  // test_case_end
  //----------------------------------------------------------------------

  task test_case_end();
  endtask

endmodule

//------------------------------------------------------------------------
// TEST_UTILS_CHECK_EQ
//------------------------------------------------------------------------
// Compare two expressions which can be signals or constants. We use the
// !== operator so that Xs must also match exactly.

`define TEST_UTILS_CHECK_EQ( __dut, __ref )                             \
  if ( __ref !== __dut ) begin                                          \
    if ( t.n != 0 ) begin                                               \
      $display( "" );                                                   \
      $display( `TEST_UTILS_RED,"ERROR",`TEST_UTILS_RESET, ": Value on output port %s is incorrect on cycle %0d", \
                "__dut", t.cycles );                                    \
      $display( " - actual value   : %b", __dut );                      \
      $display( " - expected value : %b", __ref );                      \
    end                                                                 \
    else                                                                \
      $write( {`TEST_UTILS_RED,"FAILED",`TEST_UTILS_RESET} );           \
    t.failed = 1;                                                       \
  end                                                                   \
  else begin                                                            \
    if ( t.n == 0 )                                                     \
      $write( `TEST_UTILS_GREEN, ".", `TEST_UTILS_RESET );              \
  end                                                                   \
  if (1)

//------------------------------------------------------------------------
// TEST_UTILS_CHECK_EQ_HEX
//------------------------------------------------------------------------
// Compare two expressions which can be signals or constants. We use the
// !== operator so that Xs must also match exactly. Display using hex.

`define TEST_UTILS_CHECK_EQ_HEX( __dut, __ref )                         \
  if ( __ref !== __dut ) begin                                          \
    if ( t.n != 0 ) begin                                               \
      $display( "" );                                                   \
      $display( `TEST_UTILS_RED,"ERROR",`TEST_UTILS_RESET, ": Value on output port %s is incorrect on cycle %0d", \
                "__dut", t.cycles );                                    \
      $display( " - actual value   : %h", __dut );                      \
      $display( " - expected value : %h", __ref );                      \
    end                                                                 \
    else                                                                \
      $write( {`TEST_UTILS_RED,"FAILED",`TEST_UTILS_RESET} );           \
    t.failed = 1;                                                       \
  end                                                                   \
  else begin                                                            \
    if ( t.n == 0 )                                                     \
      $write( `TEST_UTILS_GREEN, ".", `TEST_UTILS_RESET );              \
  end                                                                   \
  if (1)

//------------------------------------------------------------------------
// TEST_UTILS_CHECK_EQ_STR
//------------------------------------------------------------------------
// Compare two expressions which can be signals or constants. We use the
// !== operator so that Xs must also match exactly. Display using string.

`define TEST_UTILS_CHECK_EQ_STR( __dut, __ref )                         \
  if ( __ref !== __dut ) begin                                          \
    if ( t.n != 0 ) begin                                               \
      $display( "" );                                                   \
      $display( `TEST_UTILS_RED,"ERROR",`TEST_UTILS_RESET, ": Value on output port %s is incorrect on cycle %0d", \
                "__dut", t.cycles );                                    \
      $display( " - actual value   : %-s", __dut );                     \
      $display( " - expected value : %-s", __ref );                     \
    end                                                                 \
    else                                                                \
      $write( {`TEST_UTILS_RED,"FAILED",`TEST_UTILS_RESET} );           \
    t.failed = 1;                                                       \
  end                                                                   \
  else begin                                                            \
    if ( t.n == 0 )                                                     \
      $write( `TEST_UTILS_GREEN, ".", `TEST_UTILS_RESET );              \
  end                                                                   \
  if (1)

`endif /* TEST_UTILS_SV */
