module initialize (
reset,
clk,
// CODEC
I2C_SCLK,
I2C_SDAT,

done
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
    output I2C_SCLK;
    output done;
    // ------inout-------
    inout  I2C_SDAT;
 
//==== reg/wire declaration ================================
    reg  state;
    reg  next_state;
    reg [7:0] counter;
    wire [7:0] next_counter;
    wire [0:239] initialize_dat;
    reg done;
    wire next_done;
    
    //reg ack;
    //reg next_ack;
    
//==== combinational part ==================================

        // finite state machine
    always@(*) begin
        case(state)
            INITIAL: begin
                if (counter%8 == 7 && counter != 8'b11111111) begin
                    next_state = WAIT;
                    //next_ack = 1'b1;
                end
                else begin
                    next_state = INITIAL;
                    //next_ack = 1'b1;
                end
            end
            
            WAIT: begin
                if (I2C_SDAT == 0) begin
                    next_state = INITIAL;
                    //next_ack = 1'b1;
                end
                else begin
                    next_state = WAIT;
//next_ack = I2C_SDAT;
                end
            end
        endcase
    end
    
    assign I2C_SDAT = (state == INITIAL)? initialize_dat[counter] : 1'bz;
    
    assign next_counter = (state == INITIAL)? counter+1'b1 : counter;
    
    assign initialize_dat[0  :23 ] = 24'b001101000000000010010111;
    assign initialize_dat[24 :47 ] = 24'b001101000000001010010111;
    assign initialize_dat[48 :71 ] = 24'b001101000000010001111001;
    assign initialize_dat[72 :95 ] = 24'b001101000000011001111001;
    assign initialize_dat[96 :119] = 24'b001101000000100000010101;
    assign initialize_dat[120:143] = 24'b001101000000101000000000;
    assign initialize_dat[144:167] = 24'b001101000000110000000000;
    assign initialize_dat[168:191] = 24'b001101000000111001000010;
    assign initialize_dat[192:215] = 24'b001101000001000000011001;
    assign initialize_dat[216:239] = 24'b001101000001001000000001;
    
    assign next_done = (counter == 8'd239)? 1 : 0;
//==== sequential part =====================================  
    always@(posedge clk or negedge reset)
        if (reset == 0) begin
            state <= INITIAL;
            counter <= 8'b11111111;
            done <= 0;
            //ack <= 0;
        end
        else begin
            state <= next_state;
            done <= next_done;
            counter <= next_counter;
            //ack <= next_ack;
        end
    
endmodule