`timescale 1ns / 1ps


module baudrate
    #(parameter clk_speed = 100_000000,
                baudrate = 921600)
    (
    input logic i_clk,
    input logic i_br_rst,
    output logic o_b_tick
    );
    
    localparam integer FINAL_VALUE = clk_speed / baudrate; 
    
    logic b_reg, b_next;
    logic [$clog2(FINAL_VALUE) - 1:0] c_reg, c_next;
    
    always_ff @(posedge i_clk) begin
        if(i_br_rst) begin
            b_reg <= 0;
            c_reg <= 0;
        end else begin
            c_reg <= c_next;
            b_reg <= b_next; end
    end
    
    always_comb begin
        c_next = (c_reg == FINAL_VALUE - 1) ? 0 : c_reg + 1;
        b_next = (c_reg == FINAL_VALUE - 1) ? 1 : 0;
    end
    
    assign o_b_tick = b_reg;    
    
endmodule
