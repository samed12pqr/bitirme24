`timescale 1ns / 1ps

module transmitter
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk, 
    input logic [D_BITS - 1:0] i_data,
    input logic i_tx_enable,
    input logic i_b_tick,
    output logic o_br_rst,
    output logic o_tx,
    output logic o_tx_done
    );
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START = 2'b01,
        TRANSMISSION = 2'b10,
        STOP = 2'b11
    } state_t;
    
    logic tx_reg, tx_next;
    logic [D_BITS - 1:0] data_reg, data_next;
    state_t state_reg, state_next = IDLE;
    logic [3:0] shift_reg, shift_next;
    logic [$clog2(SP_BITS) - 1:0] sb_reg, sb_next;
    
    always_ff @(posedge i_clk) begin
        state_reg <= state_next;
        data_reg <= data_next;
        tx_reg <= tx_next;
        shift_reg <= shift_next;
        sb_reg <= sb_next;
    end
            
    always_comb begin
        o_br_rst = 0;
        state_next = state_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        shift_next = shift_reg;
        sb_next = sb_reg;
        o_tx_done = 0;
        case(state_reg)
        IDLE: begin :idle;
            o_br_rst = 1;
            if(i_tx_enable) begin
                state_next = START;
                data_next = i_data;
                o_br_rst = 0; end
        end
        START: begin :start;
            tx_next = 1'b0;
            if(i_b_tick) begin
                shift_next = 0;                  
                state_next = TRANSMISSION; end
        end
        TRANSMISSION: begin :transmission;
            tx_next = data_reg[0];
            if(i_b_tick) begin
                if(shift_reg == D_BITS - 1) begin
                    state_next = STOP;
                    shift_next = 0;
                    sb_next = 0;
                end else begin
                    tx_next = data_reg[1];
                    data_next = data_reg >> 1;
                    shift_next = shift_reg + 1; end end
         end
         STOP: begin :stop;
            tx_next = 1'b1;          
            if(i_b_tick) begin
                if(sb_reg == SP_BITS - 1) begin              
                    state_next = IDLE;
                    o_tx_done = 1;
                    sb_next = 0;
                end else begin
                    sb_next = sb_reg + 1; end end
         end
         default: begin :def;
            state_next <= IDLE; end
        endcase
    end
    
    assign o_tx = tx_reg;
    
endmodule
