`timescale 1ns / 1ps

module uipt 
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1,
                N = 400
    )(
    input logic i_clk,
    input logic reset,
    input logic [31:0] bleng,
    input logic i_rx,
    output logic o_tx
    );
    
    logic dvalid, rdy, send;
    //(*DONT_TOUCH = "true"*)
    logic [D_BITS - 1:0] rx_im_data;
    /*(*DONT_TOUCH = "true"*)*/ logic [D_BITS - 1:0] im_tx_data;
    logic o_tx_done;
    
    uart #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS)
    )UART(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(i_rx),
        .i_data(im_tx_data),
        .i_tx_enable(send),
        .o_tx(o_tx),
        .o_data(rx_im_data),
        .o_dvalid(valid),
        .o_tx_rdy(rdy),
        .o_tx_done()
    );
    
    imfilter #(
        .D_BITS(D_BITS),
        .N(N)
    )IMFILTER(
        .i_clk(i_clk),
        .reset(reset),
        .bleng(bleng),
        .i_data(rx_im_data),
        .i_valid(valid),
        .i_rdy(rdy),
        .o_data(im_tx_data),
        .o_send(send)
    );
    
endmodule
