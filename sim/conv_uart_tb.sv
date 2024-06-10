`timescale 1ns / 1ps

module conv_uart_tb
    #(parameter row_depth = 9,
                column_depth = 9,
                D_BITS = 8)
    (

    );
    localparam totpix = (row_depth * column_depth);
    localparam last = (row_depth - 6) * (column_depth - 6);
    logic clk;
    logic reset;
    logic [D_BITS - 1:0] i_data, dmem, tx_data, o_data;
    logic i_drdy;
    logic wr_mem, rx_dvalid, tx_enable, tx_rdy, o_valid;
    logic tot;
    int i;
    logic [D_BITS - 1:0] my_array [0:totpix - 1];

    always #5 clk = ~clk;

    initial begin
        $readmemb("D:/Dersler/24_BYY_Dersler/Bitirme_Tezi/matlab_kod/matrix_binary.txt", my_array);
        clk = 0; reset = 0; i_drdy = 0; #25;
        for(i = 0; i < (totpix); i = i + 1) begin
            i_data = my_array[i]; i_drdy = 1; #10; i_drdy = 0;
            #12_000; end
        #(12_000*last);    
        $stop;
    end    

    conv_uart #(
        .row_depth(row_depth),
        .column_depth(column_depth),
        .D_BITS(D_BITS)
    )conv_uart (
        .i_clk(clk),
        .reset(reset),
        .i_data(i_data),
        .i_drdy(i_drdy),
        .o_data(o_data),
        .o_dvalid(o_dvalid)
    );


endmodule
