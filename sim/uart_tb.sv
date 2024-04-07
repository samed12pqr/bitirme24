`timescale 1ns / 1ps

module uart_tb(

    );
    
    logic clk;
    logic tx_enable;
    logic [7:0] i_data, o_data;
    
    uart UART(
        .i_clk(clk),
        .i_tx_enable(tx_enable),
        .i_data(i_data),
        .o_data(o_data)
    ); 
    
    always #5 clk = ~clk;
    
    initial begin
        i_data = 8'b0101_0101;
        #20
        tx_enable = 1;
        #20
        tx_enable = 0;
        #12_000
        
        /*i_data = 8'b0011_0111;
        #20
        tx_enable = 1;
        #20
        tx_enable = 0;
        #12_000
        
        i_data = 8'b0001_0011;
        #20
        tx_enable = 1;
        #20
        tx_enable = 0;
        #12_000*/
        $stop;
    end    
    
    initial begin
        clk = 0;
        
     end 
    
endmodule
