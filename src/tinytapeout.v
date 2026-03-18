/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier:
 */


 /*
  * Project description:
  * 
  * -
*/
`include "helpers/hvsync_generator.v"
`include "helpers/pengine.v"
`include "helpers/decoder.v"
`include "helpers/vga_display.v"

`default_nettype none
module tinytapeout (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // VGA-facing signals.
  wire       hsync;
  wire       vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire       video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD mapping.
  assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uio_out = 0;
  assign uio_oe  = 8'b00000000;


  assign R = 2'b00;
  assign G = 2'b00;
  assign B = 2'b00;

  wire cs   = uio_in[0];
  wire mosi = uio_in[1];
  wire sclk = uio_in[3];
  wire rst  = ~rst_n; // High reset

  wire       spi2m_val;
  wire       spi2m_rdy = 1'b1;
  wire [15:0] spi2m_data;

  spiModule spi (
    .clk     (clk),
    .rst     (rst),
    .cs      (cs),
    .mosi    (mosi),
    .miso    (/*unused*/),
    .sclk    (sclk),
    .data_out(spi2m_data),
    .val     (spi2m_val),
    .rdy     (spi2m_rdy)
  );

  hvsync_generator hvsync_gen (
    .clk       (clk),
    .reset     (rst),
    .hsync     (hsync),
    .vsync     (vsync),
    .display_on(video_active),
    .hpos      (pix_x),
    .vpos      (pix_y)
  );

  decoder send_message( 
    .rst(rst),
    .clk(clk),
    .in(spi2m_data),
    .val(spi2m_val),
    .rdy(spi2m_rdy),
    .x_out(x_out),
    .y_out(y_out),
    .cmd_valid(cmd_valid),
    .cmd_type(cmd_type),
    .cmd_data(cmd_data)
  );

  pengine physics_module(
    .rst(rst),
    .clk(clk),
    .cmd_valid(cmd_valid),
    .cmd_type(cmd_type),
    .cmd_data(cmd_data),
    .x_ball(x_ball),
    .y_ball(y_ball)
  );

  vga_display ball_renderer(
    .display_on(display_on),
    .x_ball(x_ball),
    .y_ball(y_ball),
    .hpos(hpos),
    .vpos(vpos),
    .R(R),
    .G(G),
    .B(B)
  );


  wire _unused = &{ena, ui_in, video_active, pix_x, pix_y, spi2m_val, spi2m_data};

endmodule
