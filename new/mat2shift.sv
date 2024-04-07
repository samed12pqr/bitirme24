`timescale 1ns / 1ps

module mat2shift
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic i_tx_enable,
    input logic [D_BITS - 1:0] i_data,
    output logic [D_BITS - 1:0] o_data,
    output logic o_rx_done
    );
    
    logic tx_br_rst1, rx_br_rst1, tx_br_rst2, rx_br_rst2;
    logic tx_b_tick1, rx_b_tick1, tx_b_tick2, rx_b_tick2;
    logic tx_enable2;
    logic io_tx_rx1, io_tx_rx2;
    logic [D_BITS - 1:0] rx_im_data, im_tx_data;
    logic rx_done1;  
    logic tx_done2;
    
    tm_top TM1(
        .i_clk(i_clk),
        .i_data(i_data),
        .i_tx_enable(i_tx_enable),
        .o_tx(io_tx_rx1),
        .o_tx_done()
    );
    
    rx_top RX1(
        .i_clk(i_clk),
        .i_rx(io_tx_rx1),
        .o_data(rx_im_data),
        .o_rx_done(rx_done1)
    );
    
    imfilter IMFILTER(
        .i_clk(i_clk),
        .i_data(rx_im_data),
        .i_rx_done(rx_done1),
        .i_tx_done(tx_done2),
        .o_data(im_tx_data),
        .o_tx_enable(tx_enable2)
    );
    tm_top TM2(
        .i_clk(i_clk),
        .i_data(im_tx_data),
        .i_tx_enable(tx_enable2),
        .o_tx(io_tx_rx2),
        .o_tx_done(tx_done2)
    );
    
    rx_top RX2(
        .i_clk(i_clk),
        .i_rx(io_tx_rx2),
        .o_data(o_data),
        .o_rx_done(o_rx_done)
    );
    
endmodule
