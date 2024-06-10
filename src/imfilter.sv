`timescale 1ns / 1ps

module imfilter
    #(parameter D_BITS = 8, // RAM WIDTH
                N = 400) // RAM DEPTH
    (
    input logic i_clk,
    input logic reset,
    //(*DONT_TOUCH = "true"*)
    input logic [31:0] bleng, //byte length of array
    input logic [D_BITS - 1:0] i_data,
    input logic i_valid, // write en signal
    input logic i_rdy,   // read en signal
    output logic [D_BITS - 1:0] o_data,
    output logic o_send
    );
    
    localparam RAM_PERFORMANCE = "LOW_LATENCY"; // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    localparam INIT_FILE = "";

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        SAVE2MEM = 2'b01,
        SEND = 2'b10
        //STOP = 2'b10
    } state_t;
    /*(*DONT_TOUCH = "true"*)*/ //(* ram_style = "block" *)
    logic [D_BITS - 1:0] img [0:N - 1];
    logic [D_BITS - 1:0] img_data, dout;
    logic [$clog2(N) - 1:0] addra;  // write address  index
    logic [$clog2(N) - 1:0] addrb;  // read address index
    //(*DONT_TOUCH = "true"*)
    state_t state_reg;
    
    

    always_ff @(posedge i_clk) begin      
        if (i_valid) begin
            img[addra] <= i_data; end
        if(i_rdy) begin
            dout <= img[addrb]; end
    end    

    always_ff @(posedge i_clk) begin
        if(reset) begin
            state_reg <= SAVE2MEM;
            o_send <= 0;;
            addra <= 0;
            addrb <= 0;
        end else begin    
        o_send <= 0;
        case(state_reg) 
            IDLE: begin
                if(bleng) begin
                    state_reg <= SAVE2MEM;
                    addra <= 0; end
            end
            SAVE2MEM: begin
                if(i_valid) begin
                   addra <= addra + 1;        
                   if(addra == bleng - 1) begin
                       state_reg <= SEND;
                       addrb <= 0; end
                end        
            end
            SEND: begin
                if(i_rdy) begin
                    o_send <= 1;
                    addrb <= addrb + 1; 
                    if(addrb == bleng - 1) begin
                        state_reg <= IDLE; end
                end else begin
                    o_send <= 0; end
            end

            default: begin
                state_reg <= IDLE;
            end
        endcase end
    end
    
    assign o_data = (i_rdy)? dout : {D_BITS{1'bz}};

    
endmodule
