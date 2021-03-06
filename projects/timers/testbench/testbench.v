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
   wire [3:0]           ANODE;                  // From dut of display_top.v
   wire [7:0]           CATHODE;                // From dut of display_top.v
   wire                 TX;                     // From dut of display_top.v
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

   timers_top dut(/*AUTOINST*/
                   // Outputs
                   .ANODE               (ANODE[3:0]),
                   .CATHODE             (CATHODE[7:0]),
                   // Inputs
                   .CLK_IN              (CLK_IN),
                   .RESET_IN            (RESET_IN));   
   
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
      
      repeat(100) @(posedge CLK_IN);      
      `TEST_PASSED = 1;
            
   end
endmodule // Basic
