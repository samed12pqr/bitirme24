`timescale 1ns / 1ps

module imfilter
    #(parameter D_BITS = 8,
                N = 3)
    (
    input logic i_clk,
    input logic [D_BITS - 1:0] i_data,
    input logic i_rx_done,
    input logic i_tx_done,
    output logic [D_BITS - 1:0] o_data,
    output logic o_tx_enable
    );
    
    typedef enum logic [1:0] {
        SAVE2MEM = 2'b00,
        SEND = 2'b01,
        STOP = 2'b10
    } state_t;
    
    logic [D_BITS - 1:0] I [N - 1:0];
    logic [D_BITS - 1:0] Is [N - 1:0];
    int i = 0;
    state_t state_reg = SAVE2MEM;
    
    always_ff @(posedge i_clk) begin
        o_tx_enable <= 0;
        case(state_reg) 
            SAVE2MEM: begin
                if(i_rx_done) begin
                   I[i] <= i_data;
                   i <= i + 1;        
                   if(i == N - 1) begin
                       i <= 1;
                       o_data <= I[0] >> 1;
                       o_tx_enable <= 1;
                       state_reg <= SEND; end end           
            end
            SEND: begin
                if(i_tx_done) begin
                    o_data <= I[i] >> 1;
                    o_tx_enable <= 1;
                    i <= i + 1; end
                    if(i == N ) begin
                        state_reg <= STOP;
                        i <= 0; end
            end
            STOP: begin
                i <= 1;
            end
            default: begin
                state_reg <= SAVE2MEM;
            end
        endcase
    end
    
endmodule
