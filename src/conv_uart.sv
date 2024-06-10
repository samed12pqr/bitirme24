`timescale 1ns / 1ps

module conv_uart
    #(parameter row_depth = 7,
                column_depth = 7,
                D_BITS = 8)
    (
    input logic i_clk,
    input logic reset,
    input logic [D_BITS - 1:0] i_data,
    input logic i_drdy,
    output logic [D_BITS - 1:0] o_data,
    output logic o_dvalid
    );

    logic [D_BITS - 1:0] dmem, tx_data2, dconv;
    logic wr_mem, rx1_dvalid, rx2_dvalid, tx_enable2, tx_rdy1, tx_rdy2, tx_done1, tx_done2, tx1_rx1, tx2_rx2;
    logic [31:0] tot;

    convolutor #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )convolutor (
        .i_clk(i_clk),
        .reset(reset),
        .i_drdy(rx1_dvalid),
        .i_data(dconv),
        .o_dvalid(wr_mem),
        .o_data(dmem),
        .tot(tot)
    );

    mem_pix mempix(
        .i_clk(i_clk),
        .tot(tot),
        .i_drdy(tx_rdy2),
        .i_dmem(dmem),
        .i_wr_mem(wr_mem),
        .o_dmem(tx_data2),
        .o_tx_enable(tx_enable2)
    );

    uart TX1(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(),
        .i_data(i_data),
        .i_tx_enable(i_drdy),
        .o_tx(tx1_rx1),
        .o_data(),
        .o_dvalid(),
        .o_tx_rdy(tx_rdy1)
        //.o_tx_done(tx_done1)
    );
    
    uart RX1(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(tx1_rx1),
        .i_data(),
        .i_tx_enable(),
        .o_tx(),
        .o_data(dconv),
        .o_dvalid(rx1_dvalid),
        .o_tx_rdy()
        //.o_tx_done()
    );

    uart TX2(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(),
        .i_data(tx_data2),
        .i_tx_enable(tx_enable2),
        .o_tx(o_tx2),
        .o_data(),
        .o_dvalid(),
        .o_tx_rdy(tx_rdy2)
        //.o_tx_done(o_tx_done2)
    );
    
    uart RX2(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(o_tx2),
        .i_data(),
        .i_tx_enable(),
        .o_tx(),
        .o_data(o_data),
        .o_dvalid(o_dvalid),
        .o_tx_rdy()
        //.o_tx_done()
    );

endmodule

