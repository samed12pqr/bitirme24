`timescale 1ns / 1ps

module rx_top
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic i_rx,
    output logic [D_BITS - 1:0] o_data,
    output logic o_rx_done
    );
    
    logic br_rst, b_tick;
    
    
    baudrate TM_TIMER(
        .i_clk(i_clk),
        .i_br_rst(br_rst),
        .o_b_tick(b_tick)
    );
    
    receiver RECEIVER(
        .i_clk(i_clk),
        .o_data(o_data),
        .i_b_tick(b_tick),
        .o_br_rst(br_rst),
        .i_rx(i_rx),
        .o_rx_done(o_rx_done)
    );

endmodule
