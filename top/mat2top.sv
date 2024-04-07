`timescale 1ns / 1ps

module mat2top(
    input logic i_clk,
    input logic i_rx,
    output logic o_tx
    );
    
    logic tx_br_rst, rx_br_rst;
    logic tx_b_tick, rx_b_tick;
    logic tx_enable;
    logic rx_done, tx_done;
    logic [7:0] rx_im_data, im_tx_data;
    
    tm_top TM(
        .i_clk(i_clk),
        .i_data(im_tx_data),
        .i_tx_enable(tx_enable),
        .o_tx(o_tx),
        .o_tx_done(tx_done)
    );
    
    imfilter IMFILTER(
        .i_clk(i_clk),
        .i_data(rx_im_data),
        .i_rx_done(rx_done),
        .i_tx_done(tx_done),
        .o_data(im_tx_data),
        .o_tx_enable(tx_enable)
    );
    
    rx_top RX(
        .i_clk(i_clk),
        .i_rx(i_rx),
        .o_data(rx_im_data),
        .o_rx_done(rx_done)
    );
    
endmodule
