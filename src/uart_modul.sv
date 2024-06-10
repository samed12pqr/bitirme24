`timescale 1ns / 1ps


module uart_modul
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)(
    input logic i_clk,
    input logic reset,
    input logic i_rx,
    input logic [D_BITS - 1:0] tx_data,
    input logic i_tx_enable,
    output logic o_tx,
    output logic [D_BITS - 1:0] rx_data,
    output logic rx_dvalid,
    output logic o_tx_rdy
    );

    uart #(
        .clk_speed(clk_speed), .baudrate(baudrate), .D_BITS(D_BITS), .SP_BITS(SP_BITS)       
    )UART(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(i_rx),
        .i_data(tx_data),
        .i_tx_enable(i_tx_enable),
        .o_tx(o_tx),
        .o_data(rx_data),
        .o_dvalid(rx_dvalid),
        .o_tx_rdy(o_tx_rdy)
        //.o_tx_done(tx_done)
    );

endmodule
