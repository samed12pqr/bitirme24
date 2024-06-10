`timescale 1ns / 1ps

module mem_pix
    #(parameter row_depth = 7,
                column_depth = 7,
                D_BITS = 8)
    (
    input logic i_clk,
    //input logic reset,
    input logic [31:0] tot,
    input logic i_drdy,
    input logic [D_BITS - 1:0] i_dmem,
    input logic i_wr_mem,
    output logic [D_BITS - 1:0] o_dmem,
    output logic o_tx_enable
    );

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        SAVE2MEM = 3'b001,
        LATENCY1 = 3'b010,
        SEND = 3'b011,
        LATENCY2 = 3'b100
    } state_t;
    
    state_t state;

    logic [D_BITS - 1:0] din, dout, fifo1_dout;
    logic [31:0] cnt;
    logic [2:0] laten;
    logic rst_mem;
    logic rd_en;
    logic empty, full;
    logic fifo1_empty, fifo2_empty, fifo1_full, fifo2_wr, fifo2_almost_full;


    always_ff @(posedge i_clk) begin
    o_tx_enable <= 0;
    rst_mem <= 0;
    case (state)
        IDLE: begin
            cnt <= 0;
            state <= SAVE2MEM;
            rst_mem <= 1;
            rd_en <= 0;
        end
        SAVE2MEM: begin
            if (i_wr_mem) begin
                //din <= i_dmem;
                cnt <= cnt + 1;
                if (cnt == tot) begin
                    state <= SEND;
                    cnt <= 0; end
            end
        end
        /*LATENCY1: begin
            rd_en <= 1'b1;
            state <= SEND; end*/  
        SEND: begin
            o_tx_enable <= 0;
            rd_en <= 0;
            if (i_drdy && ~fifo2_empty) begin
                cnt <= cnt + 1;
                rd_en <= 1;
                o_tx_enable <= 1;
                //state <= LATENCY2;
                if(cnt == tot) begin
                    state <= IDLE; end
            end
        end
        /*LATENCY2: begin
            o_tx_enable <= 1;
            state <= SEND;
            if(cnt == tot) begin
                state <= IDLE; end
        end*/
        default: begin
            state <= IDLE; 
        end
    endcase
end

    /*always_ff @(posedge i_clk) begin
        if(i_drdy) begin

    end*/    

assign o_dmem = dout;

   fifo_generator_1 MEMW1 (
  .clk(i_clk),      // input wire clk
  .srst(rst_mem),    // input wire srst
  .din(i_dmem),      // input wire [7 : 0] din
  .wr_en(i_wr_mem),  // input wire wr_en
  .rd_en(fifo2_wr),  // input wire rd_en
  .dout(fifo1_dout),    // output wire [7 : 0] dout
  .full(fifo1_full),    // output wire full
  .almost_full(),
  .empty(fifo1_empty)  // output wire empty
);

 fifo_generator_1 MEMW2 (
  .clk(i_clk),      // input wire clk
  .srst(rst_mem),    // input wire srst
  .din(fifo1_dout),      // input wire [7 : 0] din
  .wr_en(fifo2_wr),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(dout),    // output wire [7 : 0] dout
  .full(),    // output wire full
  .almost_full(fifo2_almost_full),
  .empty(fifo2_empty)  // output wire empty
);

assign fifo2_wr = ~fifo1_empty && ~fifo2_almost_full;

/*always_ff @(posedge i_clk) begin
    if(~fifo1_empty) begin
        fifo2_wr <= 1;
    end    
end   */

endmodule
