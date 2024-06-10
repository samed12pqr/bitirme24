`timescale 1ns / 1ps


module line_buffer
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic reset,
    input logic i_drdy,
    input logic [D_BITS - 1:0] i_data,
    input logic [6:0] wr_en,
    input logic [6:0] rd_en,
    output logic o_dvalid,
    output logic [D_BITS -1:0] o_data  
    );
    
    genvar i;
    
    generate
    for (i = 0; i <  7; i = i + 1) begin
    fifo_generator_0 your_instance_name (
      .clk(i_clk),      // input wire clk
      .srst(reset),    // input wire srst
      .din(i_data),      // input wire [7 : 0] din
      .wr_en(wr_en[i]),  // input wire wr_en
      .rd_en(rd_en[i]),  // input wire rd_en
      .dout(dout),    // output wire [7 : 0] dout
      .full(full),    // output wire full
      .empty(empty)  // output wire empty
    ); end
    endgenerate
    
endmodule
