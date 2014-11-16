module initialize (
reset,
clk,
// CODEC
I2C_SCLK,
I2C_SDAT,
dat_o,

done
);

//==== parameter definition ===============================
    //state
    parameter INITIAL = 2'b00;
    parameter WAIT = 2'b01;
    parameter START = 2'b10;
    parameter STOP = 2'b11;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    //CODEC
    input reset;
    input clk;
    
    //-------- output --------------------------------------
    // CODEC
    output I2C_SCLK;
    output done;
    
    output [7:0] dat_o;
    // ------inout-------
    inout  I2C_SDAT;
 
//==== reg/wire declaration ================================
    reg  [1:0] state;
    reg  [1:0] next_state;
    reg  [1:0] tmp_state;
    reg  [1:0] next_tmp_state;
    reg [7:0] counter;
    reg [7:0] next_counter;
    wire [0:239] initialize_dat;
    reg done;
    wire next_done;
    wire clk_500;
    reg flag;
    reg state_flag;
    reg next_state_flag;
    reg next_flag;
    reg I2C_SCLK;
    wire next_I2C_SCLK;
    reg [7:0] tmp_count;
    reg [7:0] next_tmp_count;
    reg tmp_I2C_SDAT;
    reg [3:0] start_counter;
    reg [3:0] next_start_counter;
    reg start_clk;

    
    
//==== combinational part ==================================

    clksrc clksrc1 (clk, clk_500);
    assign next_I2C_SCLK = (state == INITIAL || state == WAIT)? ~clk_500 : start_clk;
    assign dat_o = initialize_dat[0:7];
    assign I2C_SDAT = tmp_I2C_SDAT;
    
        // finite state machine
    always@(*) begin
        case(state)

            START: begin
                if (start_counter < 4'd7) begin
                    start_clk = 1;
                    tmp_I2C_SDAT = 1'b1;
                    next_tmp_state = START;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter + 1;
                end
                else if (start_counter < 10) begin
                    start_clk = 1;
                    tmp_I2C_SDAT = 1'b0;
                    next_tmp_state = START;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter + 1;

                end
                else begin
                    start_clk = 0;
                    tmp_I2C_SDAT = 1'b0;
                    next_tmp_state = INITIAL;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter;
                end
            end
            
            STOP: begin
                start_clk = 1;
                if (start_counter < 4'd7) begin
                    tmp_I2C_SDAT = 1'b0;
                    next_tmp_state = STOP;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter + 1;
                end
                else if (start_counter < 10) begin
                    tmp_I2C_SDAT = 1'b1;
                    next_tmp_state = STOP;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter + 1;

                end
                else begin
                    tmp_I2C_SDAT = 1'b1;
                    if (counter >= 8'd240) 
                        next_tmp_state = STOP;
                    else
                        next_tmp_state = START;
                    next_state = tmp_state;
                    next_state_flag = 0;
                    next_start_counter = start_counter;
                end
            end
            
            INITIAL: begin
                start_clk = 1;
                tmp_I2C_SDAT = initialize_dat[counter];
                next_start_counter = 0;
                    if (done == 1) begin
                        next_tmp_state = STOP;
                        next_state = tmp_state;
                        next_state_flag = 0;
                    end
                    else if (I2C_SCLK == 0 && state_flag == 0) begin  // flag == 00 -> 01
                        if (counter%8 == 7 && counter != 8'b11111111)
                            next_tmp_state = WAIT;
                        else
                            next_tmp_state = INITIAL;
                        next_state = tmp_state;
                        next_state_flag = 1;
                    end
                    else if (I2C_SCLK == 0 && state_flag == 1) begin // flag == 10
                        if (counter%8 == 7 && counter != 8'b11111111)
                            next_tmp_state = WAIT;
                        else
                            next_tmp_state = tmp_state;
                        next_state = state;
                        next_state_flag = 1;
                    end
                    else begin // I2C_SCLK == 0
                        if (counter%8 == 7 && counter != 8'b11111111)
                            next_tmp_state = WAIT;
                        else
                            next_tmp_state = tmp_state;
                        next_state = state;
                        next_state_flag = 0;
                    end
                
            end          
            
            WAIT: begin
                start_clk = 1;
                tmp_I2C_SDAT = 1'bz;
                next_start_counter = 0;
                    if (I2C_SCLK == 0 && state_flag == 0) begin // flag == 00 -> 01
                        if (counter % 24 == 0)
                            next_tmp_state = STOP;
                        else if (I2C_SDAT == 0)
                            next_tmp_state = INITIAL;
                        else
                            next_tmp_state = tmp_state;
                        next_state = tmp_state;
                        next_state_flag = 1;
                    end
                    else if (I2C_SCLK == 0 && state_flag == 1) begin // flag == 1
                        if (counter % 24 == 0)
                            next_tmp_state = STOP;
                        else if (I2C_SDAT == 0)
                            next_tmp_state = INITIAL;
                        else
                            next_tmp_state = tmp_state;
                        next_state = state;
                        next_state_flag = 1;
                    end
                    else begin // I2C_SCLK == 0
                        if (counter % 24 == 0)
                            next_tmp_state = STOP;
                        else if (I2C_SDAT == 0)
                            next_tmp_state = INITIAL;
                        else
                            next_tmp_state = tmp_state;
                        next_state = state;
                        next_state_flag = 0;
                    end
            end
                    
            
        endcase
    end
    
    // assign I2C_SDAT = (state == INITIAL)? initialize_dat[counter] : 1'bz;
    // always@(*) begin
        // if (state == INITIAL)
            // tmp_I2C_SDAT = initialize_dat[counter];
        // else if (state == WAIT)
            // tmp_I2C_SDAT = 1'bz;
        // else if (state == START) begin
        
        // end
        // else begin // STOP
        
        // end
            
    // end

    always@(*) begin
        if(state == INITIAL) begin
            if(I2C_SCLK == 0 && flag == 0) begin
                next_tmp_count = counter + 8'd1;
                next_counter = tmp_count;
                next_flag = 1;
            end
            else if (I2C_SCLK == 0 && flag == 1) begin
                next_tmp_count = counter + 8'd1;
                next_counter = counter;
                next_flag = 1;
            end
            else begin // I2C_SCLK == 0
                next_tmp_count = counter + 8'd1;
                next_counter = counter;
                next_flag = 0;
            end
        end
        else begin
            if(I2C_SCLK == 0 && flag == 0) begin
                next_tmp_count = counter;
                next_counter = tmp_count;
                next_flag = 1;
            end
            else if (I2C_SCLK == 0 && flag == 1) begin
                next_tmp_count = counter;
                next_counter = counter;
                next_flag = 1;
            end
            else begin // I2C_SCLK == 0
                next_tmp_count = counter;
                next_counter = counter;
                next_flag = 0;
            end
        end
    end
    //next_counter = (state == INITIAL && )? counter+1'b1 : counter;
    
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
    
    assign next_done = (counter == 8'd241)? 1 : 0;
//==== sequential part =====================================  
    always@(posedge clk or negedge reset)
        if (reset == 0) begin
            state <= START;
            tmp_state <= START;
            counter <= 8'b0;
            tmp_count <= 8'b0;
            done <= 0;
            flag <= 0;
            state_flag = 0;
            I2C_SCLK <= 1;
            start_counter <= 4'b0;
        end
        else begin
            state <= next_state;
            tmp_state <= next_tmp_state;
            done <= next_done;
            counter <= next_counter;
            tmp_count <= next_tmp_count;
            flag <= next_flag;
            state_flag = next_state_flag;
            I2C_SCLK <= next_I2C_SCLK;
            start_counter <= next_start_counter;
        end
    
endmodule