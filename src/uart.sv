`timescale 1ns / 1ps

module uart
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
    
    logic tx_br_rst, rx_br_rst;
    logic tx_b_tick, rx_b_tick;
    logic tx_done;
    logic tx_enable;
    logic io_tx_rx;
    
    baudrate TM_TIMER(
        .i_clk(i_clk),
        .i_br_rst(tx_br_rst),
        .o_b_tick(tx_b_tick)
    );
    
    baudrate RX_TIMER(
        .i_clk(i_clk),
        .i_br_rst(rx_br_rst),
        .o_b_tick(rx_b_tick)
    );
    
    transmitter TRANSMITTER(
        .i_clk(i_clk),
        .i_data(i_data),
        .i_tx_enable(i_tx_enable),
        .i_b_tick(tx_b_tick),
        .o_br_rst(tx_br_rst),
        .o_tx(io_tx_rx),
        .o_tx_done(tx_done)
    );
    
    receiver RECEIVER(
        .i_clk(i_clk),
        .i_rx(io_tx_rx),
        .i_b_tick(rx_b_tick),
        .o_data(o_data),
        .o_br_rst(rx_br_rst),
        .o_rx_done(o_rx_done)
    );
    
endmodule
