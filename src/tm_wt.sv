`timescale 1ns / 1ps

module tm_wt
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic reset,
    input logic [D_BITS - 1:0] i_data,
    input logic i_tx_enable,
    output logic o_tx,
    output logic o_tx_rdy,
    output logic o_tx_done
    );
    
    logic tx_br_rst;
    logic b_tick; 
    
    baudrate #(
        .clk_speed(clk_speed),
        .baudrate(baudrate)
    )TM_TIMER(
        .i_clk(i_clk),
        .reset(reset),
        .i_tx_br_rst(tx_br_rst),
        .i_rx_br_rst(1'b1),
        .o_b_tick(b_tick)
    );
    
    transmitter #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS)
    )TRANSMITTER(
        .i_clk(i_clk),
        .reset(reset),
        .i_data(i_data),
        .i_tx_enable(i_tx_enable),
        .i_b_tick(b_tick),
        .o_br_rst(tx_br_rst),
        .o_tx(o_tx),
        .o_tx_rdy(o_tx_rdy),
        .o_tx_done(o_tx_done)
    );
    
endmodule
