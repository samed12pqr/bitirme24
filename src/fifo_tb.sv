`timescale 1ns / 1ps


module fifo_tb(

    );
    
    logic clk, rst, wr_en, rd_en, empty, full;
    logic [7:0] din, dout, data;
    int i;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 0; /*wr_en = 0; rd_en = 0; din = 0; rst = 0;*/ #15;
        rst = 0;
        #10;
        din = 25;
        wr_en = 1; #10; wr_en = 0;
        #60;
        din = 40;
        wr_en = 1; #10; wr_en = 0;
        //#10;
        rd_en = 1; #10; rd_en = 0;
        #40;
        rd_en = 1; #10; rd_en = 0;
        #20;
        din = 50; wr_en = 1; #10; wr_en = 0;
        #40;
        for(i=0; i <1000 ; i = i + 1) begin
        data = $urandom_range(0, 255);  end
        #50;   
        $stop;
    end
    
    assign data = dout;
    
    fifo_generator_0 fifo (
      .clk(clk),      // input wire clk
      .srst(rst),    // input wire srst
      .din(din),      // input wire [7 : 0] din
      .wr_en(wr_en),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout),    // output wire [7 : 0] dout
      .full(full),    // output wire full
      .empty(empty)  // output wire empty
);
    
endmodule
