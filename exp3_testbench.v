`timescale 1ns/1ps
`define I2C_CYCLE   2000 //ns
`define CYCLE	20 // ns
`define END_CYCLE 300

module testbench;
//===============================================
//============= Signal Declaration ==============
	// signal in top module
	reg		reset;
	reg		clk;

	// Codec
	wire	I2C_SCLK;
	wire	I2C_SDAT;
	wire	AUD_XCK;
	wire	AUD_BCLK;
	wire	AUD_DACDAT;
	wire	AUD_DACLRCK;
	wire	AUD_ADCDAT;
	wire	AUD_ADCLRCK;
    wire    I2C_SCLK_o;
    wire    I2C_SDAT_o;
    wire    [7:0] dat_o;

	// indices
	integer i;
//============= Module Connection ===============
	exp3 top(
		.reset(reset),
		.clk(clk),
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT),
		.AUD_XCK(AUD_XCK),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_ADCLRCK(AUD_ADCLRCK),
        .SCLK_o(SCLK_o),
        .SDAT_o(SDAT_o),
        .dat_o(dat_o)
	);

//============= Create Wave File ================
	// uncomment this part if we want the waveform file
	/*
    initial begin
        $fsdbDumpfile("exp3.fsdb");
        $fsdbDumpvars;
    end
	*/

//============= Start Simulation =============== 
    always begin 
        #(`CYCLE/2) clk = ~clk; 
    end

    assign I2C_SDAT = (i % 9 == 0)? 0 : 1'bz;
    
	initial begin
        #0; // t = 0
        clk     = 1'b1;
        reset   = 1'b1; 

        #(`I2C_CYCLE) reset = 1'b0;
        #(`I2C_CYCLE) reset = 1'b1;

		#(0.001);
		i = 1;
		while(i <= `END_CYCLE) begin
			#(`I2C_CYCLE);
            i = i + 1;
		end
        
        $display("-------------------------DONE------------------------\n");
        $finish;
	end

endmodule
