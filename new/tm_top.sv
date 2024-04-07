`timescale 1ns / 1ps

module tm_top
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic i_tx_enable,
    input logic [D_BITS - 1:0] i_data,
    output logic o_tx,
    output logic o_tx_done
    );
    
    logic br_rst, b_tick;
    
    
    baudrate TM_TIMER(
        .i_clk(i_clk),
        .i_br_rst(br_rst),
        .o_b_tick(b_tick)
    );
    
    transmitter TRANSMITTER(
        .i_clk(i_clk),
        .i_data(i_data),
        .i_tx_enable(i_tx_enable),
        .i_b_tick(b_tick),
        .o_br_rst(br_rst),
        .o_tx(o_tx),
        .o_tx_done(o_tx_done)
    );
    
endmodule
