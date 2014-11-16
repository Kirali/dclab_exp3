module playing (
reset,
clk,

// CODEC
AUD_BCLK,
AUD_DACDAT,
AUD_DACLRCK,

// Memory
SRAM_ADDR,
SRAM_DQ  ,
SRAM_CE_N,
SRAM_OE_N,
SRAM_WE_N,
SRAM_UB_N,
SRAM_LB_N,

// Control
play_btn,
stop_btn

);

//==== parameter definition ===============================
    //state
    parameter PLAYING = 2'b00;
    parameter STOP = 2'b01;
    //parameter PAUSE = 2'b10;
    //parameter SPEEDUP = 2'b11;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    input reset;
    input clk;
    input AUD_BCLK;
    input AUD_DACLRCK;
    input play_btn;
    input stop_btn;
    
    //-------- output --------------------------------------
    output AUD_DACDAT; //
    output [19:0] SRAM_ADDR;
    output SRAM_CE_N; //
    output SRAM_OE_N; //
    output SRAM_WE_N; // 
    output SRAM_UB_N; //
    output SRAM_LB_N; //
    
    // ------inout-------
    inout [15:0] SRAM_DQ;
    
//==== reg/wire declaration ================================
    reg  state;
    reg  next_state;
    reg  AUD_DACDAT;
    reg  next_AUD_DACDAT;
    reg  flag;
    reg  next_flag;
    reg  [4:0] Lcounter;
    reg  [4:0] Rcounter;
    reg  [4:0] next_Lcounter;
    reg  [4:0] next_Rcounter;
    reg  [15:0] dat;
    reg  [15:0] next_dat;
    reg  [19:0] addr;
    reg  [19:0] next_addr;
    reg  [19:0] SRAM_ADDR;
    
//==== combinational part ==================================
    // finite state machine
    always@(*) begin
        case(state)
            PLAYING:begin
                if(stop_btn == 0)
                next_state = STOP;
                else next_state = state;
            end
            STOP:begin
                if(play_btn == 0)
                next_state = PLAYING;
                else next_state = state;
            end
            default:begin
                next_state = state;
            end
        endcase
    end
    
    // CODEC in/out put
    always@(*) begin
        if (state == PLAYING)begin
            if(AUD_DACLRCK == 0)begin
                next_Rcounter = 5'b0;
                if(AUD_BCLK == 0 && flag == 0)begin
                    if (Lcounter == 5'd0 || Lcounter == 5'd17) 
                        next_AUD_DACDAT = 1'bz;
                    else  next_AUD_DACDAT = dat[Lcounter-1];
                    next_Lcounter = Lcounter + 5'd1;
                    next_flag = 1;
                end
                else if (AUD_BCLK == 0 && flag == 1)begin
                    next_AUD_DACDAT = AUD_DACDAT;
                    next_Lcounter = Lcounter;
                    next_flag = 1;
                end
                else begin//BCLK==1
                    next_AUD_DACDAT = AUD_DACDAT;
                    next_Lcounter = Lcounter;
                    next_flag = 0;
                end
            end
            else begin //AUD_DACLRCK == 1
                next_Lcounter = 5'b0;
                if(AUD_BCLK == 0 && flag == 0)begin
                    if (Rcounter == 5'd0 || Rcounter == 5'd17) 
                        next_AUD_DACDAT = 1'bz;
                    else  next_AUD_DACDAT = dat[Rcounter-1];
                    next_Rcounter = Rcounter + 5'd1;
                    next_flag = 1;
                end
                else if (AUD_BCLK == 0 && flag == 1)begin
                    next_AUD_DACDAT = AUD_DACDAT;
                    next_Rcounter = Rcounter;
                    next_flag = 1;
                end
                else begin//BCLK==1
                    next_AUD_DACDAT = AUD_DACDAT;
                    next_Rcounter = Rcounter;
                    next_flag = 0;
                end
            end
        end
        else if (state == STOP) begin
            next_Lcounter = 5'b0;
            next_Rcounter = 5'b0;
            next_AUD_DACDAT = 1'bz;
            next_flag = 0;
        end
        else begin
            next_Lcounter = 5'b0;
            next_Rcounter = 5'b0;
            next_AUD_DACDAT = 1'bz;
            next_flag = 0;
        end
            
    end
    
    // ------SRAM-----------------
    //control
    assign SRAM_CE_N = (state == PLAYING)? 0 : 1;
    assign SRAM_OE_N = (state == PLAYING)? 0 : 1;
    assign SRAM_WE_N = (state == PLAYING)? 1 : 1;
    assign SRAM_UB_N = (state == PLAYING)? 0 : 1;
    assign SRAM_LB_N = (state == PLAYING)? 0 : 1;
    
    //addr & dat
    assign SRAM_DQ = 1'bz;
    always@(*) begin
        if (state == PLAYING)begin
            SRAM_ADDR = addr;
            if(Lcounter == 5'd16 || Rcounter == 5'd16)
                next_addr = addr+1;
            else next_addr = addr;
            if(Lcounter == 5'd17 || Rcounter == 5'd17)
                next_dat = SRAM_DQ;
            else next_dat = dat;
        end
        else begin
            SRAM_ADDR = 20'b0;
            next_dat = 16'b0;
            next_addr = 20'b0;
        end
            
    end
    
//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
            state = STOP;
            AUD_DACDAT = 1'bz;
            flag       = 0;
            Lcounter   = 5'b0;
            Rcounter   = 5'b0;
            dat        = 16'b0;
            addr       = 20'b0;
        end
        else begin
            state = next_state;
            AUD_DACDAT = next_AUD_DACDAT ;
            flag       = next_flag       ;
            Lcounter   = next_Lcounter   ;
            Rcounter   = next_Rcounter   ;
            dat        = next_dat        ;
            addr       = next_addr       ;
        end
    
endmodule