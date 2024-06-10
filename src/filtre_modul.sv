`timescale 1ns / 1ps

module filtre_modul
    #(parameter row_depth = 450,
                column_depth = 500,
                D_BITS = 8)(
    input logic i_clk,
    input logic reset,
    input logic i_drdy,
    input logic i_tx_rdy,
    input logic [D_BITS - 1:0] i_data,
    output logic [D_BITS - 1:0] o_data,
    output logic o_dvalid
    );

    logic wr_mem;
    logic [D_BITS - 1:0] dmem;
    logic [31:0] tot;

    convolutor #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )convolutor (
        .i_clk(i_clk),
        .reset(reset),
        .i_drdy(i_drdy),
        .i_data(i_data),
        .o_dvalid(wr_mem),
        .o_data(dmem),
        .tot(tot)
    );

    mem_pix mempix(
        .i_clk(i_clk),
        .tot(tot),
        .i_drdy(i_tx_rdy),
        .i_dmem(dmem),
        .i_wr_mem(wr_mem),
        .o_dmem(o_data),
        .o_tx_enable(o_dvalid)
    );

endmodule
