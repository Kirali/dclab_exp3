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

// Memory
 SRAM_ADDR,
 SRAM_DQ,
 SRAM_CE_N,
 SRAM_OE_N,
 SRAM_WE_N,
 SRAM_UB_N,
 SRAM_LB_N,

 // observation
 DAC_o,
 SCLK_o,
 SDAT_o,
 
// Control
 play_btn,
 stop_btn,
 record_btn
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
    input play_btn;
    input stop_btn;
    input record_btn;
    //input [4:0] speed_sw;
    //-------- output --------------------------------------
    // CODEC
    output AUD_XCK;
    output AUD_DACDAT;
    output I2C_SCLK;
    
    // Memory
    output [19:0] SRAM_ADDR;
    output SRAM_CE_N;
    output SRAM_OE_N;
    output SRAM_WE_N;
    output SRAM_UB_N;
    output SRAM_LB_N;
    
    // observation
    output SCLK_o;
    output SDAT_o;
    output DAC_o;
    
    // ------inout-------
    inout [15:0] SRAM_DQ;
    inout I2C_SDAT;
 
//==== reg/wire declaration ================================
    reg [1:0] state;
    reg [1:0] next_state;
    reg initial_done;
    wire next_initial_done;
    //----initialize------
    wire iI2C_SCLK;
    wire iI2C_SDAT;
    
    //----playing----------
    // CODEC
    wire pAUD_DACDAT;
    // Memory
    wire pSRAM_ADDR;
    wire pSRAM_DQ  ;
    wire pSRAM_CE;
    wire pSRAM_OE;
    wire pSRAM_WE;
    wire pSRAM_UB;
    wire pSRAM_LB;
    
    //------recording-------------
    //Memory
    wire rSRAM_ADDR;
    wire rSRAM_DQ;
    wire rSRAM_OE;
    wire rSRAM_WE;
    wire rSRAM_CE;
    wire rSRAM_LB;
    wire rSRAM_UB;
    
    wire clk_12;
//==== combinational part ==================================
    //12MHz clk
    clksrc12 clksrc12_1 (clk,clk_12);
    
    // finite state machine
    always@(*) begin
        case(state)
            INITIAL: begin
                if (initial_done == 0) 
                    next_state = INITIAL;
                else 
                    next_state = STOP;
            end
            
            PLAYING: begin
                if (stop_btn == 0) 
                    next_state = STOP;
                else 
                    next_state = PLAYING;
            end
            
            RECORDING: begin
                if (stop_btn == 0) 
                    next_state = STOP;
                else 
                    next_state = RECORDING;
            end
            
            STOP: begin
                if (play_btn == 0) 
                    next_state = PLAYING;
                else if (record_btn == 0)
                    next_state = RECORDING;
                else 
                    next_state = STOP;
            end
            default: begin
                next_state = STOP;
            end
        endcase
    end

    initialize initilaize_1 (.reset(reset), .clk(clk), .I2C_SCLK(iI2C_SCLK), .I2C_SDAT(iI2C_SDAT), .done(next_initial_done));
    playing    playing_1    (
        .reset(reset),
        .clk(clk),
        // CODEC
        .AUD_BCLK(AUD_BCLK),
        .AUD_DACDAT(pAUD_DACDAT),
        .AUD_DACLRCK(AUD_DACLRCK),
        // Memory
        .SRAM_ADDR(pSRAM_ADDR),
        .SRAM_DQ  (pSRAM_DQ  ),
        .SRAM_CE_N(pSRAM_CE),
        .SRAM_OE_N(pSRAM_OE),
        .SRAM_WE_N(pSRAM_WE),
        .SRAM_UB_N(pSRAM_UB),
        .SRAM_LB_N(pSRAM_LB),
        // Control
        .play_btn(play_btn),
        .stop_btn(stop_btn));
    recording   recording1   (
        .reset(reset),
        .clk(clk),
        
        //CODEC
        .AUD_BCLK(AUD_BCLK),
        .AUD_ADCLRCK(AUD_ADCLRCK),
        .AUD_ADCDAT(AUD_ADCDAT),
        
        //Memory
        .SRAM_ADDR(rSRAM_ADDR),
        .SRAM_DQ(rSRAM_DQ),
        .SRAM_OE(rSRAM_OE),
        .SRAM_WE(rSRAM_WE),
        .SRAM_CE(rSRAM_CE),
        .SRAM_LB(rSRAM_LB),
        .SRAM_UB(rSRAM_UB),
        
        //control
        .record_btn(record_btn),
        .stop_btn(stop_btn)
        );
    
    assign DAC_o = AUD_DACDAT;
    assign SCLK_o = I2C_SCLK;
    assign SDAT_o = I2C_SDAT;
    
    assign I2C_SCLK = (state == INITIAL)? iI2C_SCLK: 1;
    assign I2C_SDAT = (state == INITIAL)? iI2C_SDAT: 1;
    assign AUD_XCK  = clk_12;
    // assign AUD_DACDAT = (state == PLAYING)? pAUD_DACDAT : 1'bz;
    assign AUD_DACDAT = (play_btn == 0)? AUD_ADCDAT : 1'b0;
    assign SRAM_ADDR = (state == PLAYING)? pSRAM_ADDR:
                       (state == RECORDING) ? rSRAM_ADDR: 0;
    assign SRAM_DQ = (state == PLAYING)? pSRAM_DQ:
                     (state == RECORDING) ? rSRAM_DQ: 1'bz;
    assign SRAM_CE_N = (state == PLAYING)? pSRAM_CE:
                     (state == RECORDING) ? rSRAM_CE: 1'b1;
    assign SRAM_OE_N = (state == PLAYING)? pSRAM_OE:
                     (state == RECORDING) ? rSRAM_OE: 1'b1;
    assign SRAM_WE_N = (state == PLAYING)? pSRAM_WE:
                     (state == RECORDING) ? rSRAM_WE: 1'b1;
    assign SRAM_UB_N = (state == PLAYING)? pSRAM_UB:
                     (state == RECORDING) ? rSRAM_UB: 1'b1;
    assign SRAM_LB_N = (state == PLAYING)? pSRAM_LB:
                     (state == RECORDING) ? rSRAM_LB: 1'b1;
    
    
//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
            state <= INITIAL;
            initial_done <= 0;
        end
        else begin
            state <= next_state;
            initial_done <= next_initial_done;
        end
    
endmodule
