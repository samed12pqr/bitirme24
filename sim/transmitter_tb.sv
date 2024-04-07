`timescale 1ns / 1ps

module transmitter_tb(

    );
    
    logic br_rst, b_tick;
    logic i_clk, i_tx_enable;
    logic [7:0] i_data;
    logic o_tx;
    
    baudrate TM_TIMER(
        .i_clk(i_clk),
        .i_br_rst(br_rst),
        .o_b_tick(b_tick)
    );
    
    transmitter TM(
        .i_clk(i_clk),
        .i_data(i_data),
        .i_b_tick(b_tick),
        .i_tx_enable(i_tx_enable),
        .o_br_rst(br_rst),
        .o_tx(o_tx)
    );
    
    always #5 i_clk = ~i_clk;
    
    initial begin
        i_data = 8'b0101_0101;
        #20
        i_tx_enable = 1;
        #20
        i_tx_enable = 0;
        #12_000
        $stop;
    end    
    
    initial begin
        i_clk = 0;
        
     end   
    
endmodule
