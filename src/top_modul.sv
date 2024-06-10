`timescale 1ns / 1ps

module top_modul
    #(parameter clk_speed = 100_000000,
        baudrate = 921600,
        D_BITS = 8,
        SP_BITS = 1,
        row_depth = 450,
        column_depth = 500)(
    input logic i_clk,
    input logic reset,
    input logic i_rx,
    output logic o_tx
    );

    logic [D_BITS - 1:0] dmem, tx_data, rx_data;
    logic wr_mem, rx_dvalid, tx_enable, tx_rdy, tx_done;
    logic [31:0] tot;

    filtre_modul #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )FILTRE(
        .i_clk(i_clk),
        .reset(reset),
        .i_drdy(rx_dvalid),
        .i_tx_rdy(tx_rdy),
        .i_data(rx_data),
        .o_data(tx_data),
        .o_dvalid(tx_enable)
    );

    uart_modul #(
        .clk_speed(clk_speed), .baudrate(baudrate), .D_BITS(D_BITS), .SP_BITS(SP_BITS)       
    )UART(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(i_rx),
        .tx_data(tx_data),
        .i_tx_enable(tx_enable),
        .o_tx(o_tx),
        .rx_data(rx_data),
        .rx_dvalid(rx_dvalid),
        .o_tx_rdy(tx_rdy)
        //.o_tx_done(tx_done)
    );

endmodule
