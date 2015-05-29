//                              -*- Mode: Verilog -*-
// Filename        : timer.v
// Description     : Picoblaze Timer Module
// Author          : Philip Tracton
// Created On      : Thu May 28 22:54:35 2015
// Last Modified By: Philip Tracton
// Last Modified On: Thu May 28 22:54:35 2015
// Update Count    : 0
// Status          : Unknown, Use with caution!

module timer (/*AUTOARG*/
   // Outputs
   timer_interrupt,
   // Inputs
   clk, timer_count, timer_enable, timer_one_shot
   ) ;
   input clk;
   input [31:0] timer_count;
   input        timer_enable;
   input        timer_one_shot; 
   input        timer_interrupt_clear;   
   output       timer_interrupt;

   //
   // Registers
   //
   reg [31:0]   count = 32'h0000_0000;
   reg          timer_interrupt = 1'b0;
   
   always @(posedge clk)
     if (timer_enable  && !(count >= timer_count)) begin
        count <= count + 1;        
     end else begin
        count <= 32'h0000_0000;        
     end
       
   //
   // Interrupt
   //
   always @(posedge clk)
     if (timer_enable  & !timer_interrupt_clear) begin
        interrupt <= (count >= timer_count);        
     end else begin
        interrupt <= 1'b0;        
     end
   
endmodule // timer
