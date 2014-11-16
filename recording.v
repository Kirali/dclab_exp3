module recording (
reset,
clk,

//CODEC
AUD_BCLK,
AUD_ADCLRCK,
AUD_ADCDAT,

//Memory
SRAM_ADDR,
SRAM_DQ,
SRAM_OE,
SRAM_WE,
SRAM_CE,
SRAM_LB,
SRAM_UB,

//control
record_btn,
stop_btn
);

// ================= parameter definition ===================
    parameter RECORD = 1'b0;
    parameter STOP = 1'b1;
    
// ================= in/out declaration =====================
    // ---------------- input ----------------------------------
    input reset;
    input clk;
    
    // input AUD_XCK;
    input AUD_BCLK;
    input AUD_ADCLRCK;
    input AUD_ADCDAT;
    
    input record_btn;
    input stop_btn;
    
    // ---------------- output --------------------------------- 
    output [19:0] SRAM_ADDR;
    output [15:0] SRAM_DQ; // inout
    output SRAM_OE;
    output SRAM_WE;
    output SRAM_CE;
    output SRAM_LB;
    output SRAM_UB;

// ================= reg/wire declaration ===================
    reg  state;
    reg  next_state;
    reg  [19:0] addr;
    reg  [19:0] next_addr;
    reg  [4:0] clk_Lcounter;
    reg  [4:0] next_clk_Lcounter;
    reg  [4:0] clk_Rcounter;
    reg  [4:0] next_clk_Rcounter;
    reg  flag;
    reg  next_flag;
    reg  [15:0] dat;
    reg  [15:0] next_dat;
    reg  [3:0] DQ_bit;
    reg  [3:0] next_DQ_bit;

    
    integer i;
// ================= combinational part =====================
// finite state machine
always@(*) begin
    case (state)
        RECORD: begin
            if (stop_btn == 0) begin
                next_state = STOP;
            end
            else begin
                next_state = RECORD;
            end
        end
        
        STOP: begin
            if (record_btn == 0) begin
                next_state = RECORD;
            end
            else begin
                next_state = STOP;
            end
        end
    endcase
end

assign SRAM_CE = (state == RECORD)? 1'b0 : 1'b1;
assign SRAM_OE = (state == RECORD)? 1'b1 : 1'b1;
assign SRAM_WE = (state == RECORD)? 1'b0 : 1'b1;
assign SRAM_LB = (state == RECORD)? 1'b0 : 1'b1;
assign SRAM_UB = (state == RECORD)? 1'b0 : 1'b1;

assign SRAM_ADDR = addr;
assign SRAM_DQ = dat;

// record
always@(*) begin
    if (state == RECORD) begin
        if (AUD_BCLK == 0 && flag == 0) begin // a new clk
            // left channel
            if (AUD_ADCLRCK == 0) begin // left channel
                next_clk_Rcounter = 5'd0; // reset clk_Rcounter
                if (clk_Lcounter == 0) begin // waiting
                    next_clk_Lcounter = clk_Lcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr;
                    next_DQ_bit = 4'd15;
                    next_dat = dat;
                end
                else if (clk_Lcounter >= 1 || clk_Lcounter <= 16) begin // start ADCDAT
                    next_clk_Lcounter = clk_Lcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr + 1;
                    next_DQ_bit = (DQ_bit == 0)? DQ_bit - 4'd1 : DQ_bit;
                    
                    // assign dat
                    for ( i=0; i<16; i=i+1) begin
                        if (i == DQ_bit)
                            next_dat[i] = AUD_ADCDAT;
                        else
                            next_dat[i] = dat[i];
                    end
                end
                else begin // finish
                    next_clk_Lcounter = clk_Lcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr;
                    next_DQ_bit = DQ_bit;
                    next_dat = dat;
                end
            end
            // right channel
            else begin // right channel
                next_clk_Lcounter = 5'd0; // reset clk_Lcounter
                if (clk_Rcounter == 0) begin // waiting
                    next_clk_Rcounter = clk_Rcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr;
                    next_DQ_bit = 4'd15;
                    next_dat = dat;
                end
                else if (clk_Rcounter >= 1 || clk_Rcounter <= 16) begin // start ADCDAT
                    next_clk_Rcounter = clk_Rcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr + 1;
                    next_DQ_bit = (DQ_bit == 0)? DQ_bit - 4'd1 : DQ_bit;
                    
                    // assign dat
                    for ( i=0; i<16; i=i+1) begin
                        if (i == DQ_bit)
                            next_dat[i] = AUD_ADCDAT;
                        else
                            next_dat[i] = dat[i];
                    end
                end
                else begin // finish
                    next_clk_Rcounter = clk_Rcounter + 1;
                    next_flag = 1'b1;
                    next_addr = addr;
                    next_DQ_bit = DQ_bit;
                    next_dat = dat;
                end
            end
         end
         else if (AUD_BCLK == 0 && flag == 1) begin // same clk
            next_clk_Lcounter = clk_Lcounter;
            next_clk_Rcounter = clk_Rcounter;
            next_flag = 1'b1;
            next_addr = addr;
            next_DQ_bit = DQ_bit;
            next_dat = dat;
         end
         else begin // AUD_BCLK == 1
            next_clk_Lcounter = clk_Lcounter;
            next_clk_Rcounter = clk_Rcounter;
            next_flag = 1'b0;
            next_addr = addr;
            next_DQ_bit = DQ_bit;
            next_dat = dat;
         end
    end
    else begin// state == STOP
        next_clk_Lcounter = 5'b0;
        next_clk_Rcounter = 5'b0;
        next_flag = 1'b0;
        next_addr = 20'b0;
        next_DQ_bit = 4'd15;
        next_dat = 16'b0;
    end
end



// ================= sequentail part ========================
always@( posedge clk or posedge reset ) begin

    // reset
    if ( reset == 1 ) begin
        state <= STOP;
        addr <= 20'b0;
        clk_Lcounter <= 5'b0;
        clk_Rcounter <= 5'b0;
        DQ_bit <= 4'd15;
        flag = 1'b0;
        dat <= 16'b0;
    end
    // run
    else begin
        state <= next_state;
        addr <= next_addr;
        clk_Lcounter <= next_clk_Lcounter;
        clk_Rcounter <= next_clk_Rcounter;
        DQ_bit <= next_DQ_bit;
        flag <= next_flag;
        dat <= next_dat;
    end

end

endmodule
