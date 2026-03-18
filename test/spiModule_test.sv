`default_nettype none
`timescale 1ns / 1ps


module spiModule_test ();

  logic clk;
  logic rst;
  logic sclk;
  initial sclk = 1'b0;
  TestUtilsClkRst t(
    .clk(clk),
    .rst(rst)
  ); // clk in util is 10 units
  always #50 sclk = ~sclk; // safe assumption to assume that clk will have 10x freq of sclk

  // Wire up the inputs and outputs:

  logic cs;
  logic mosi;
  logic [7:0] data_out;
  logic val;
  logic rdy;

  spiModule dut (
      .clk(clk),
      .rst(rst),
      .cs(cs),
      .mosi(mosi),
      .miso(/*unused*/),
      .sclk(sclk),
      .data_out(data_out),
      .val(val),
      .rdy(rdy)
  );

  task automatic init_signals();
    begin
      cs   = 1'b1;
      mosi = 1'b0;
      rdy  = 1'b1;
    end
  endtask

  task automatic drive_byte(input logic [7:0] value);
    begin
      // SPI mode 0 samples on rising SCLK, so bit 7 must already be
      // present on MOSI before the first rising edge.
      mosi = value[7];
      @(posedge sclk);

      for (int i = 6; i >= 0; i--) begin
        @(negedge sclk);
        mosi = value[i];
        @(posedge sclk);
      end

    end

  endtask

  task automatic send_frame_byte(input logic [7:0] value);
    begin
      // Start the frame while SCLK is low and preload bit 7 before the
      // next rising edge so the DUT can sample it in SPI mode 0.
      @(negedge sclk);
      mosi = value[7];
      cs = 0;
      repeat (3) @(posedge clk);
      @(posedge sclk);

      for (int i = 6; i >= 0; i--) begin
        @(negedge sclk);
        mosi = value[i];
        @(posedge sclk);
      end

      @(negedge sclk);
      cs = 1;
      mosi = 1'b0;
    end
  endtask

  task automatic test1();
  begin
    t.test_case_begin("reset_idle");
    init_signals();

    // wait for reset to complete
    repeat (4) @(posedge clk);

    `TEST_UTILS_CHECK_EQ(val, 1'b0);
    `TEST_UTILS_CHECK_EQ_HEX(data_out, 8'h00);

    t.test_case_end();
  end
  endtask

  task automatic test2();
  begin
    t.test_case_begin("single_byte_mode0");
    init_signals();
    rdy = 1'b0; 

    send_frame_byte(8'b10101010);

    wait (val == 1'b1);
    `TEST_UTILS_CHECK_EQ(val, 1'b1);
    `TEST_UTILS_CHECK_EQ_HEX(data_out, 8'b10101010);


    rdy = 1'b1;
    wait (val == 1'b0);
    `TEST_UTILS_CHECK_EQ(val, 1'b0);

    t.test_case_end();
  end
  endtask

  task automatic test3();
  begin
    t.test_case_begin("cs_gates_shifting");
    init_signals();
    rdy = 1'b0;

    drive_byte(8'h3C);
    repeat (20) @(posedge clk);

    `TEST_UTILS_CHECK_EQ(val, 1'b0);

    t.test_case_end();
  end
  endtask

  task automatic test4();
  begin
    t.test_case_begin("two_separate_bytes");
    init_signals();
    rdy = 1'b0;

    send_frame_byte(8'h12);
    wait (val == 1'b1);
    `TEST_UTILS_CHECK_EQ(val, 1'b1);
    `TEST_UTILS_CHECK_EQ_HEX(data_out, 8'h12);
    rdy = 1'b1;
    wait (val == 1'b0);
    rdy = 1'b0;

    send_frame_byte(8'h34);
    wait (val == 1'b1);
    `TEST_UTILS_CHECK_EQ(val, 1'b1);
    `TEST_UTILS_CHECK_EQ_HEX(data_out, 8'h34);
    rdy = 1'b1;
    wait (val == 1'b0);

    t.test_case_end();
  end
  endtask

initial begin
    t.test_bench_begin();
    t.test_suite_begin("spiModule_test");

    if (t.n == 0 || t.n == 1) test1();
    if (t.n == 0 || t.n == 2) test2();
    if (t.n == 0 || t.n == 3) test3();
    if (t.n == 0 || t.n == 4) test4();


    t.test_suite_end();
    t.test_bench_end();
end



endmodule
