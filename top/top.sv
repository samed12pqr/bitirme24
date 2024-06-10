`timescale 1ns / 1ps

module top
    #(parameter clk_speed = 100_000000,
        baudrate = 921600,
        D_BITS = 8,
        SP_BITS = 1,
        row_depth = 450,
        column_depth = 500)
    (
    input logic i_clk,
    input logic reset,
    input logic i_rx,
    output logic o_tx
    );

    logic [D_BITS - 1:0] dmem, tx_data, rx_data;
    logic wr_mem, rx_dvalid, tx_enable, tx_rdy, tx_done;
    logic [31:0] tot;

    convolutor #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )convolutor (
        .i_clk(i_clk),
        .reset(reset),
        .i_drdy(rx_dvalid),
        .i_data(rx_data),
        .o_dvalid(wr_mem),
        .o_data(dmem),
        .tot(tot)
    );

    mem_pix mempix(
        .i_clk(i_clk),
        .tot(tot),
        .i_drdy(tx_rdy),
        .i_dmem(dmem),
        .i_wr_mem(wr_mem),
        .o_dmem(tx_data),
        .o_tx_enable(tx_enable)
    );

    uart UART(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(i_rx),
        .i_data(tx_data),
        .i_tx_enable(tx_enable),
        .o_tx(o_tx),
        .o_data(rx_data),
        .o_dvalid(rx_dvalid),
        .o_tx_rdy(tx_rdy)
        //.o_tx_done(tx_done)
    );

endmodule
