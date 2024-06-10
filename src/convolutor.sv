`timescale 1ns / 1ps

(* use_dsp = "yes" *)
module convolutor
    #(parameter row_depth = 7,
                column_depth = 7,
                D_BITS = 8)
    (
    input logic i_clk,
    input logic reset,
    input logic i_drdy,
    input logic [D_BITS - 1:0] i_data,
    output logic o_dvalid,
    output logic [D_BITS -1:0] o_data,
    output logic [31:0] tot
    );

    localparam totpix = (row_depth - 6) * (column_depth - 6) - 1;

    typedef enum logic [3:0] {
        IDLE = 4'b0000,
        SAVE2MEM = 4'b0001,
        SHIFT_LB = 4'b0010,
        LATENCY = 4'b0011,
        SHIFT_MAT = 4'b0100,
        CONVOLUTION = 4'b0101,
        ADDTREE = 4'b1010,
        WRITE2MEM = 4'b1011
    } state_t;
    
    state_t state_reg;
    logic [6:0] wr_en;
    logic rd_en;
    logic [1:0] laten;
    logic [$clog2(row_depth):0] row;
    logic [$clog2(column_depth):0] col, col_cntr;
    logic [2:0] shift_cntr, conv_cntr;
    logic [3:0] cnt_addtr;
    logic [$clog2(column_depth * row_depth):0] pxl_cntr;
    logic [D_BITS - 1:0] din_lb [0:6];
    logic [D_BITS - 1:0] dout_lb [0:6];
    logic en_conv, en_comp;
    logic signed [8 :0] shift_reg [0:48]; 
    logic signed [22 :0] dout;
    logic signed [7:0] DoG [0:48]; 
    logic signed [16:0] temp1 [0:48]; 
    logic rst_lb;
    int i, j, k, l, m;

    always_ff @(posedge i_clk) begin
        if(reset) begin
            state_reg <= SAVE2MEM;
            o_dvalid <= 1'b0;
            row <= 0;
            col <= 0;
            en_comp <= 1'b0; wr_en <= 1'b0; rd_en <= 1'b0; col_cntr <= 0;
        end else begin    
        en_comp <= 1'b0;
        wr_en <= 0;
        rd_en <= 1'b0;
        o_dvalid <= 1'b0;
        rst_lb <= 0;
        case(state_reg) 
            IDLE: begin
                tot <= totpix;
                rst_lb <= 1;
                row <= 0;
                col <= 0; col_cntr <= 0; conv_cntr <= 0;
                pxl_cntr <= 0;
                shift_cntr <= 0;
                state_reg <= SAVE2MEM;
            end
            SAVE2MEM: begin
                if(i_drdy) begin
                    din_lb[row] <= i_data;
                    wr_en[row] <= 1'b1;
                    col <= col + 1;
                    if(col == column_depth - 1) begin
                        col <= 0; 
                        row <= row + 1; end
                    if(row == 6) begin
                        row <= 6;
                        laten <= 0;
                        state_reg <= SHIFT_LB; end    
                end        
            end  
            SHIFT_LB: begin
                for(i = 0; i < 6; i = i + 1) begin
                    din_lb[i] <= shift_reg[i + 1]; end
                if(shift_cntr == 7) begin
                    wr_en <= 7'b0111_111; end
                state_reg <= LATENCY;
            end
            LATENCY: begin
                laten <= laten + 1;
                if(laten == 2) begin
                    laten <= 0;
                    rd_en <= 1'b1;
                    state_reg <= SHIFT_MAT; end
            end
            SHIFT_MAT: begin
                for(j = 0; j < 42; j = j + 1) begin
                    shift_reg[j] <= shift_reg[j+7]; end
                for(k = 0; k < 7; k = k + 1) begin
                    shift_reg[42 + k] <= dout_lb[k]; end 
                if(conv_cntr == 6) begin                 
                    state_reg <= CONVOLUTION; 
                end else begin
                    state_reg <= SAVE2MEM;
                    conv_cntr <= conv_cntr + 1; end
                if(shift_cntr == 7) begin
                    if(col_cntr == column_depth - 6) begin
                        col_cntr <= 0;
                        conv_cntr <= 1;
                        state_reg <= SAVE2MEM; end
                end else begin
                    shift_cntr <= shift_cntr + 1; end;
            end //(* use_dsp = "yes" *)
            CONVOLUTION: begin
                for(l = 0; l < 49; l = l + 1) begin
                    temp1[l] <= shift_reg[l] * DoG[l]; end
                cnt_addtr <= 0;    
                state_reg <= ADDTREE;
            end    
            ADDTREE: begin
                cnt_addtr <= cnt_addtr + 1;
                if(cnt_addtr == 6) begin
                    en_comp <= 1'b1;
                    state_reg <= WRITE2MEM; end
            end    
            WRITE2MEM: begin
                    pxl_cntr <= pxl_cntr + 1;
                    o_data <= dout;
                    o_dvalid <= 1'b1;
                    col_cntr <= col_cntr + 1;
                    if(pxl_cntr == totpix) begin
                        state_reg <= IDLE;
                        pxl_cntr <= 0;
                    end else begin
                        state_reg <= SAVE2MEM; end
                //end
            end   
            default: begin
                state_reg <= IDLE;
            end
        endcase end
    end
    logic signed [20:0] sum; logic signed [20:0] sum2; logic signed [25:0] sum_out;
    //(* use_dsp = "yes" *)
    always_comb begin
        dout = o_data;
        if(en_comp) begin
            dout = sum_out >>> 7; //1024'e böl 8 kat kazanc ver.
            dout = dout + shift_reg[24];
            if(dout > 255) begin
                dout = 255;
            end else if(dout < 0) begin
                dout = 0; end  
        end                           
    end
    
    logic signed [25:0] sum_stage_0 [0:24];   // 1. Aşama için toplamlar (25 toplam)
    logic signed [25:0] sum_stage_1 [0:12];   // 2. Aşama için toplamlar (13 toplam)
    logic signed [25:0] sum_stage_2 [0:6];    // 3. Aşama için toplamlar (7 toplam)
    logic signed [25:0] sum_stage_3 [0:3];    // 4. Aşama için toplamlar (4 toplam)
    logic signed [25:0] sum_stage_4 [0:1];    // 5. Aşama için toplamlar (2 toplam)
    logic signed [25:0] sum_stage_5;          // 6. Aşama için toplam (1 toplam

    // 1. Aşama: 49 eleman -> 25 toplam
    genvar o;
    generate
        for (o = 0; o < 24; o = o + 1) begin : STAGE_0
            always_ff @(posedge i_clk or posedge reset) begin
                if (reset)
                    sum_stage_0[o] <= 0;
                else
                    sum_stage_0[o] <= temp1[2*o] + temp1[2*o+1];
            end
        end
        always_ff @(posedge i_clk or posedge reset) begin
            if (reset)
                sum_stage_0[24] <= 0;
            else
                sum_stage_0[24] <= temp1[48];
        end
    endgenerate

    // 2. Aşama: 25 eleman -> 13 toplam
    generate
        for (o = 0; o < 12; o = o + 1) begin : STAGE_1
            always_ff @(posedge i_clk or posedge reset) begin
                if (reset)
                    sum_stage_1[o] <= 0;
                else
                    sum_stage_1[o] <= sum_stage_0[2*o] + sum_stage_0[2*o+1];
            end
        end
        always_ff @(posedge i_clk or posedge reset) begin
            if (reset)
                sum_stage_1[12] <= 0;
            else
                sum_stage_1[12] <= sum_stage_0[24];
        end
    endgenerate

    // 3. Aşama: 13 eleman -> 7 toplam
    generate
        for (o = 0; o < 6; o = o + 1) begin : STAGE_2
            always_ff @(posedge i_clk or posedge reset) begin
                if (reset)
                    sum_stage_2[o] <= 0;
                else
                    sum_stage_2[o] <= sum_stage_1[2*o] + sum_stage_1[2*o+1];
            end
        end
        always_ff @(posedge i_clk or posedge reset) begin
            if (reset)
                sum_stage_2[6] <= 0;
            else
                sum_stage_2[6] <= sum_stage_1[12];
        end
    endgenerate

    // 4. Aşama: 7 eleman -> 4 toplam
    generate
        for (o = 0; o < 3; o = o + 1) begin : STAGE_3
            always_ff @(posedge i_clk or posedge reset) begin
                if (reset)
                    sum_stage_3[o] <= 0;
                else
                    sum_stage_3[o] <= sum_stage_2[2*o] + sum_stage_2[2*o+1];
            end
        end
        always_ff @(posedge i_clk or posedge reset) begin
            if (reset)
                sum_stage_3[3] <= 0;
            else
                sum_stage_3[3] <= sum_stage_2[6];
        end
    endgenerate

    // 5. Aşama: 4 eleman -> 2 toplam
    generate
        for (o = 0; o < 2; o = o + 1) begin : STAGE_4
            always_ff @(posedge i_clk or posedge reset) begin
                if (reset)
                    sum_stage_4[o] <= 0;
                else
                    sum_stage_4[o] <= sum_stage_3[2*o] + sum_stage_3[2*o+1];
            end
        end
    endgenerate

    // 6. Aşama: 2 eleman -> 1 toplam
    always_ff @(posedge i_clk or posedge reset) begin
        if (reset)
            sum_stage_5 <= 0;
        else
            sum_stage_5 <= sum_stage_4[0] + sum_stage_4[1];
    end

    // Toplam sonucun çıkışı
    always_ff @(posedge i_clk or posedge reset) begin
        if (reset)
            sum_out <= 0;
        else
            sum_out <= sum_stage_5;
    end
    
    genvar g;
    
    generate
    for (g = 0; g <  7; g = g + 1) begin
    begin: LINE_BUFFER
    fifo_generator_0 LB(
      .clk(i_clk),      // input wire clk
      .srst(rst_lb),    // input wire srst
      .din(din_lb[g]),      // input wire [7 : 0] din
      .wr_en(wr_en[g]),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout_lb[g]),    // output wire [7 : 0] dout
      .full(),    // output wire full
      .empty()  // output wire empty
    ); end end
    endgenerate


    initial begin
        DoG[0] = -3; DoG[1] = -6; DoG[2] = -9; DoG[3] = -10; DoG[4] = -9; DoG[5] = -6; DoG[6] = -3;
        DoG[7] = -6; DoG[8] = -11; DoG[9] = -9; DoG[10] = -5; DoG[11] = -9; DoG[12] = -11; DoG[13] = -6;
        DoG[14] = -9; DoG[15] = -9; DoG[16] = 17; DoG[17] = 41; DoG[18] = 17; DoG[19] = -9; DoG[20] = -9;
        DoG[21] = -10; DoG[22] = -5; DoG[23] = 41; DoG[24] = 79; DoG[25] = 41; DoG[26] = -5; DoG[27] = -10;
        DoG[28] = -9; DoG[29] = -9; DoG[30] = 17; DoG[31] = 41; DoG[32] = 17; DoG[33] = -9; DoG[34] = -9;
        DoG[35] = -6; DoG[36] = -11; DoG[37] = -9; DoG[38] = -5; DoG[39] = -9; DoG[40] = -11; DoG[41] = -6;
        DoG[42] = -3; DoG[43] = -6; DoG[44] = -9; DoG[45] = -10; DoG[46] = -9; DoG[47] = -6; DoG[48] = -3;
    end    
    
endmodule
