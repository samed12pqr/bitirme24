`timescale 1ns / 1ps

module uart
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic reset,
    input logic i_rx,
    input logic [D_BITS - 1:0] i_data,
    input logic i_tx_enable,
    output logic o_tx,
    output logic [D_BITS - 1:0] o_data,
    output logic o_dvalid,
    output logic o_tx_rdy
    //output logic o_tx_done
    //output logic o_drdy
    );
    
    logic tx_br_rst, rx_br_rst;
    logic b_tick;
    
    baudrate #(
        .clk_speed(clk_speed), .baudrate(baudrate)
    )TIMER(
        .i_clk(i_clk),
        .reset(reset),
        .i_tx_br_rst(tx_br_rst),
        .i_rx_br_rst(rx_br_rst),
        .o_b_tick(b_tick)
    );
    
    logic tx_fifo_empty, tx_done_tick, tx_done, full, almost_full;
    logic [D_BITS - 1: 0] tx_din;
    transmitter #(
        .clk_speed(clk_speed), .baudrate(baudrate), .D_BITS(D_BITS), .SP_BITS(SP_BITS)
    )TRANSMITTER(
        .i_clk(i_clk),
        .reset(reset),
        .i_data(tx_din),
        .i_tx_enable(~tx_fifo_empty),
        .i_b_tick(b_tick),
        .o_br_rst(tx_br_rst),
        .o_tx(o_tx),
        .o_tx_rdy(),
        .o_tx_done(tx_done)
    );

    fifo_generator_1 TX_FIFO (
        .clk(i_clk),      // input wire clk
        .srst(reset),    // input wire srst
        .din(i_data),      // input wire [7 : 0] din
        .wr_en(i_tx_enable),  // input wire wr_en
        .rd_en(tx_done),  // input wire rd_en
        .dout(tx_din),    // output wire [7 : 0] dout
        .full(full),    // output wire full
        .almost_full(almost_full),
        .empty(tx_fifo_empty)  // output wire empty
);  


    assign o_tx_rdy = ~almost_full;

    logic rx_fifo_empty, rx_done;
    logic [D_BITS - 1:0] rx_dout;
    receiver #(
        .clk_speed(clk_speed), .baudrate(baudrate), .D_BITS(D_BITS), .SP_BITS(SP_BITS)       
    )RECEIVER(
        .i_clk(i_clk),
        .reset(reset),
        .o_data(rx_dout),
        .i_b_tick(b_tick),
        .o_br_rst(rx_br_rst),
        .i_rx(i_rx),
        .o_rx_done(rx_done)
    );
    
    fifo_generator_0 RX_FIFO (
        .clk(i_clk),          // input wire clk
        .srst(reset),    // input wire srst
        .din(rx_dout),      // input wire [7 : 0] din
        .wr_en(rx_done),  // input wire wr_en
        .rd_en(~rx_fifo_empty),    // input wire rd_en
        .dout(o_data),      // output wire [7 : 0] dout
        .full(),            // output wire full
        .empty(rx_fifo_empty)    // output wire empty
    );
    
    assign o_dvalid = ~rx_fifo_empty;
    
endmodule
