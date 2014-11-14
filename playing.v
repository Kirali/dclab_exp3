module playing (
reset,
clk,

// CODEC
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

// Control
play_btn,
stop_btn,
record_btn,
speed_sw

);

//==== parameter definition ===============================
    //state
    parameter INITIAL = 1'b0;
    parameter WAIT = 1'b1;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    //CODEC
    input reset;
    input clk;
    
    //-------- output --------------------------------------
    // CODEC

    // ------inout-------

 
//==== reg/wire declaration ================================
    reg  state;
    reg  next_state;

    
//==== combinational part ==================================

        // finite state machine
    always@(*) begin
        case(state)

        endcase
    end
    

//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
    
        end
        else begin

        end
    
endmodule