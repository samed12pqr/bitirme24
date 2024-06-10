`timescale 1ns / 1ps

module uipt_tb 
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1,
                N = 400,
                b_len = 5
    )(
    );
    
    logic i_clk, reset;
    logic i_tx_enable;
    int i, j;
    
    always #5 i_clk = ~i_clk;
    
    initial begin
        #50; bleng = b_len; //#50; bleng = 0;
        for (i = 0; i <= bleng - 1; i = i + 1) begin
            i_data = $urandom_range(0, 255);
            #20;
            send = 1;
            #10;
            send = 0;
            #12_000; end           
        #(12_000 * bleng );
        $stop;
    end
    
    initial begin
        reset = 1'b0;
        i_clk = 1'b0;
        //#200;
        //bleng = b_len;
    end   
   
    logic [31:0] bleng;
    logic io_tx1_rx1, io_tx2_rx2;
    uipt #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS),
        .N(N)
    )UIPT(
        .i_clk(i_clk),
        .reset(reset),
        .bleng(bleng),
        .i_rx(io_tx1_rx1),
        .o_tx(io_tx2_rx2)
    );    
    logic send;
    logic [D_BITS - 1:0] i_data;
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
        .i_tx_enable(send),
        .o_tx(io_tx1_rx1),
        .o_data(),
        .o_dvalid(),
        .o_tx_rdy(),
        .o_tx_done()
    );
    logic [D_BITS - 1:0] o_data;
    logic o_dvalid;
    uart #(
        .clk_speed(clk_speed),
        .baudrate(baudrate),
        .D_BITS(D_BITS),
        .SP_BITS(SP_BITS)
    )UART_RX(
        .i_clk(i_clk),
        .reset(reset),
        .i_rx(io_tx2_rx2),
        .i_data(),
        .i_tx_enable(),
        .o_tx(),
        .o_data(o_data),
        .o_dvalid(o_dvalid),
        .o_tx_rdy(),
        .o_tx_done()
    );
    
endmodule    
