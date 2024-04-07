`timescale 1ns / 1ps


module receiver
    #(parameter clk_speed = 100_000000,
                baudrate = 921600,
                D_BITS = 8,
                SP_BITS = 1)
    (
    input logic i_clk,
    input logic i_rx,
    input logic i_b_tick,
    output logic [D_BITS - 1:0] o_data,
    output logic o_br_rst,
    output logic o_rx_done
    );
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START = 2'b01,
        RECEIVING = 2'b10,
        STOP = 2'b11
    } state_t;
    
    localparam DIV2_VALUE = (clk_speed / baudrate) >> 1;
    //localparam REMAINDER = (clk_speed / baudrate) - ((clk_speed / (baudrate << 4)) << 4);
    //localparam IDLE = 0, RECEIVING = 1, STOP = 2;
    
    logic [D_BITS - 1:0] data_reg, data_next;
    state_t state_reg, state_next = IDLE;
    logic [3:0] shift_reg, shift_next;
    logic [$clog2(DIV2_VALUE) - 1:0] c_reg, c_next;
    logic [$clog2(SP_BITS) - 1:0] sb_reg, sb_next;
    
    always_ff @(posedge i_clk) begin
        state_reg <= state_next;
        data_reg <= data_next;
        shift_reg <= shift_next;
        c_reg <= c_next;
        sb_reg <= sb_next;
    end
    
    always_comb begin
        o_br_rst = 0;
        state_next = state_reg;
        data_next = data_reg;
        shift_next = shift_reg;
        c_next = c_reg;
        sb_next = sb_reg;
        o_rx_done = 0;
        case(state_reg)
        IDLE: begin :idle;
            o_br_rst = 1;
            if(~i_rx) begin
                c_next = 0;
                state_next = START;

 end
        end
        START: begin :start;
            o_br_rst = 1;
            if(c_reg == DIV2_VALUE - 1) begin
                c_next = 0;
                shift_next = 0;
                o_br_rst = 0;
                data_next = 0;                  
                state_next = RECEIVING;
            end else begin
                c_next = c_reg + 1; end
        end
        RECEIVING: begin :receiving;
            if(i_b_tick) begin
                data_next = {i_rx, data_reg[D_BITS - 1:1]}; // right shift
                if(shift_reg == D_BITS - 1) begin
                    state_next = STOP;
                    shift_next = 0;
                    sb_next = 0;
                end else begin
                    shift_next = shift_reg + 1; end end
         end
         STOP: begin :stop;
        
            if(i_b_tick) begin
                if(sb_reg == SP_BITS - 1) begin              
                    state_next = IDLE;
                    o_rx_done = 1;
                    sb_next = 0;
                end else begin
                    sb_next = sb_reg + 1; end end
         end
         default: begin :def;
            state_next <= IDLE; end
        endcase
    end
    
    assign o_data = data_reg;
    
endmodule
