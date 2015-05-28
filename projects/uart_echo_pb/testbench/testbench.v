//                              -*- Mode: Verilog -*-
// Filename        : testbench.v
// Description     : Basic Picoblaze TB
// Author          : Philip Tracton
// Created On      : Thu May 21 22:35:48 2015
// Last Modified By: Philip Tracton
// Last Modified On: Thu May 21 22:35:48 2015
// Update Count    : 0
// Status          : Unknown, Use with caution!

`timescale 1ns/1ns
`include "includes.v"

module testbench (/*AUTOARG*/) ;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 TX;                     // From dut of uart_echo_pb.v
   // End of automatics
   /*AUTOREG*/
   
   //
   // Free Running 100 MHz clock
   //
   reg                  CLK_IN = 0;
   initial begin
      forever begin
         #5 CLK_IN <= ~CLK_IN;         
      end
   end

   //
   // Reset
   //
   reg RESET_IN = 0;
   initial begin
      #100 RESET_IN <= 1;
      #1000 RESET_IN <= 0;      
   end

   reg [31:0]           read_word;
   
   uart_echo_pb dut(/*AUTOINST*/
                    // Outputs
                    .TX                 (TX),
                    // Inputs
                    .CLK_IN             (CLK_IN),
                    .RESET_IN           (RESET_IN),
                    .RX                 (RX));
   
   /****************************************************************************
    UART 0 

    The WB UART16550 from opencores is used here to simulate a UART on the other end
    of the cable.  It will allow us to send/receive characters to the NGMCU firmware
    ***************************************************************************/

   wire [31:0]          uart0_adr;
   wire [31:0]          uart0_dat_o;
   wire [31:0]          uart0_dat_i;
   wire [3:0]           uart0_sel;
   wire                 uart0_cyc;
   wire                 uart0_stb;
   wire                 uart0_we;
   wire                 uart0_ack;
   wire                 uart0_int;

   assign      uart0_dat_o[31:8] = 'b0;

   uart_top uart0(
                  .wb_clk_i(CLK_IN),
                  .wb_rst_i(RESET_IN),

                  .wb_adr_i(uart0_adr[4:0]),
                  .wb_dat_o(uart0_dat_o),
                  .wb_dat_i(uart0_dat_i),
                  .wb_sel_i(uart0_sel),
                  .wb_cyc_i(uart0_cyc),
                  .wb_stb_i(uart0_stb),
                  .wb_we_i(uart0_we),
                  .wb_ack_o(uart0_ack),
                  .int_o(uart0_int),
                  .stx_pad_o(RX),
                  .srx_pad_i(TX),

                  .rts_pad_o(),
                  .cts_pad_i(1'b0),
                  .dtr_pad_o(),
                  .dsr_pad_i(1'b0),
                  .ri_pad_i(1'b0),
                  .dcd_pad_i(1'b0),

                  .baud_o()
                  );


   wb_mast uart_master0(
                        .clk (CLK_IN),
                        .rst (RESET_IN),
                        .adr (uart0_adr),
                        .din (uart0_dat_o),
                        .dout(uart0_dat_i),
                        .cyc (uart0_cyc),
                        .stb (uart0_stb),
                        .sel (uart0_sel),
                        .we  (uart0_we ),
                        .ack (uart0_ack),
                        .err (1'b0),
                        .rty (1'b0)
                        );

   uart_tasks uart_tasks();
   test_tools test_tools();
   
   
   //
   // Test Case
   //
   initial begin
      @(posedge RESET_IN);
      $display("RESET: Asserted @ %d", $time);
      @(negedge RESET_IN);
      $display("RESET: De-Asserted @ %d", $time);

      repeat(100) @(posedge CLK_IN);
      `UART_CONFIG;
      `UART_WRITE_CHAR(8'h31);
      `UART_READ_CHAR(8'h31);
      
      
      repeat(100) @(posedge CLK_IN);      
      $finish;
      
   end
endmodule // Basic
