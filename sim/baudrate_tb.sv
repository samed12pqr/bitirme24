`timescale 1ns / 1ps

module baudrate_tb(

    );
    
    logic i_clk, br_rst, b_tick;
    
    baudrate TIMER (
        .i_clk(i_clk),
        .i_br_rst(br_rst),
        .o_b_tick(b_tick)
    );
    
    initial begin
        #2300 $stop; end
        
    always #5 i_clk <= ~i_clk;
    
    initial begin
        i_clk <= 0;
        br_rst <= 1;
        //s_tick <= 0;
        #22 br_rst <= 0; end
endmodule
