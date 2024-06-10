`timescale 1ns / 1ps

module test_tb(

    );
    
    localparam k_size = 500;

    logic clk;
    logic [7:0] Id [k_size - 1:0];
    logic [31:0] sum; logic signed [31:0]test1; logic [7:0] test2;
    int i,j;
    
    initial begin
        clk = 0;
        test1=255; #10;
        test2=test1;
        #10; $stop;
    end   
    /*initial begin
        clk = 0; sum = 0; sgn_test = -4;
        for (j = 0; j < k_size; j = j + 1) begin
            Id[j] = $urandom_range(0, 10); end
        #10;
        for (i=0; i < k_size; i = i + 1) begin
            sum = sum + Id[i]; end
        #50; $stop;
    end*/
    logic [4:0] sgn_test;
    always #5 clk = ~clk;
endmodule
