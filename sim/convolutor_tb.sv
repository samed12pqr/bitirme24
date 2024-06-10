`timescale 1ns / 1ps

module convolutor_tb
    #(parameter row_depth = 10,
                column_depth = 10,
                D_BITS = 8)
    (

    );
    localparam totpix = (row_depth * column_depth);
    logic clk, reset;
    logic i_drdy, o_dvalid;
    logic [D_BITS - 1:0] i_data, o_data;
    logic [D_BITS - 1:0] my_array [0:totpix - 1];
    int i;

    always #5 clk = ~clk;

    initial begin
        $readmemb("D:/Dersler/24_BYY_Dersler/Bitirme_Tezi/matlab_kod/matrix_binary.txt", my_array);
        clk = 0; reset = 0; i_drdy = 0; #25;
        for(i = 0; i < (totpix); i = i + 1) begin
            i_data = my_array[i]; i_drdy = 1; #10; i_drdy = 0; 
            #160; end
        #400;    
        $stop;
    end    

    convolutor #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )conv(
        .i_clk(clk),
        .reset(reset),
        .i_drdy(i_drdy),
        .i_data(i_data),
        .o_dvalid(o_dvalid),
        .o_data(o_data)
    );

endmodule
