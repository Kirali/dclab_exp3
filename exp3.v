module exp3 (
reset,
clk,

// CODEC
I2C_SCLK,
I2C_SDAT,
AUD_XCK,
AUD_BCLK,
AUD_DACDAT,
AUD_DACLRCK,
AUD_ADCDAT,
AUD_ADCLRCK,

// observation
I2C_SCLK_o,
I2C_SDAT_o,
dat_o
// Memory
// SRAM_ADDR,
// SRAM_DQ,
// SRAM_CE_N,
// SRAM_OE_N,
// SRAM_WE_N,
// SRAM_UB_N,
// SRAM_LB_N,

// Control
// play_btn,
// stop_btn,
// record_btn,
// speed_sw
);

//==== parameter definition ===============================
    //state
    parameter INITIAL = 2'b00;
    parameter PLAYING = 2'b01;
    parameter RECORDING = 2'b10;
    parameter STOP = 2'b11;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    input reset;
    input clk;
    
    //CODEC
    input AUD_BCLK;
    input AUD_DACLRCK;
    input AUD_ADCDAT;
    input AUD_ADCLRCK;
    
    // control
    // input play_btn;
    // input stop_btn;
    // input record_btn;
    // input [4:0] speed_sw;
    //-------- output --------------------------------------
    // CODEC
    output AUD_XCK;
    output AUD_DACDAT;
    output I2C_SCLK;
    
    // Memory
    // output [19:0] SRAM_ADDR;
    // output SRAM_CE_N;
    // output SRAM_OE_N;
    // output SRAM_WE_N;
    // output SRAM_UB_N;
    // output SRAM_LB_N;
    
    // observation
    output I2C_SCLK_o;
    output I2C_SDAT_o;
    output [7:0] dat_o;
    
    // ------inout-------
    // inout [15:0] SRAM_DQ;
    inout I2C_SDAT;
    // output I2C_SDAT;
 
//==== reg/wire declaration ================================
    reg [1:0] state;
    reg [1:0] next_state;
    wire initial_done;
    reg next_initial_done;
    wire clk_12;
    
    
//==== combinational part ==================================
    // observation
    assign I2C_SCLK_o = I2C_SCLK;
    assign I2C_SDAT_o = I2C_SDAT;
    
    clksrc12 clksrc12_1 (clk, clk_12);
    
    // finite state machine
    always@(*) begin
        case(state)
            INITIAL: begin
                if (initial_done == 0) 
                    next_state = INITIAL;
                else 
                    next_state = STOP;
            end
            
            // PLAYING: begin
                // if (stop_btn == 0) 
                    // next_state = STOP;
                // else 
                    // next_state = PLAYING;
            // end
            
            // RECORDING: begin
                // if (stop_btn == 0) 
                    // next_state = STOP;
                // else 
                    // next_state = RECORDING;
            // end
            
            // STOP: begin
                // if (play_btn == 0) 
                    // next_state = PLAYING;
                // else if (record_btn == 0)
                    // next_state = RECORDING;
                // else 
                    // next_state = STOP;
            // end
            default: begin
                next_state = STOP;
            end
        endcase
    end

    initialize initilaize_1 (.reset(reset), .clk(clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT), .done(initial_done), .dat_o(dat_o));
    assign AUD_DACDAT = AUD_ADCDAT;
    assign AUD_XCK = clk_12;
    
//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
            state <= INITIAL;
        end
        else begin
            state <= next_state;
        end
    
endmodule
