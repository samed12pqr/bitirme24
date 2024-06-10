`timescale 1ns / 1ps

module uart_tb
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (

    );
    
    logic i_clk, reset, send, o_tx, valid, rdy;
    logic [D_BITS - 1:0] im_tx_data, rx_im_data;
    logic [D_BITS - 1:0] i_data, o_data;
    logic  io_tx_rx, i_tx_enable, o_tx_done;
    int i;
    
    always #5 i_clk = ~i_clk;
    
    initial begin
        reset = 1'b0;
        i_clk = 1'b0;
        for (i = 0; i <= 4; i = i + 1) begin
            i_data = $urandom_range(0, 255);
            #5;
            i_tx_enable = 1;
            #10;
            i_tx_enable = 0;
            #10; 
            #12_000; end
        for(i = 0; i <= 0; i = i + 1) begin
            #12_000; end        
        $stop;
    end
    
    uart #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS)
    )UART_TX(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(),
        .i_data(i_data),
        .i_tx_enable(i_tx_enable),
        .o_tx(o_tx),
        .o_data(),
        .o_dvalid(),
        .o_tx_rdy(rdy),
        .o_tx_done(o_tx_done)
    );
    
    uart #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS)
    )UART_RX(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(o_tx),
        .i_data(),
        .i_tx_enable(),
        .o_tx(),
        .o_data(o_data),
        .o_dvalid(valid),
        .o_tx_rdy(),
        .o_tx_done()
    );
    
endmodule
