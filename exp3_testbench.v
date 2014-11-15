`timescale 1ns/1ps
`define CYCLE	20 // ns
`define END_CYCLE 30000

module testbench;
//===============================================
//============= Signal Declaration ==============
	// signal in top module
	reg		rest;
	reg		clk;

	// Codec
	wire	I2C_SCLK;
	reg		I2C_SDAT;
	wire	AUD_XCK;
	wire	AUD_BCLK;
	wire	AUD_DACDAT;
	wire	AUD_DACLRCK;
	wire	AUD_ADCDAT;
	wire	AUD_ADCLRCK;

	// indices
	integer i;
//============= Module Connection ===============
	exp3 top(
		.reset(reset),
		.clk(clk),
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT),
		.AUD_XCK(AUD_XCK)
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_ADCLRCK(AUD_ADCLRCK)
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

	initial begin
        #0; // t = 0
        clk     = 1'b1;
        reset   = 1'b0; 

        #(`CYCLE) reset = 1'b1; // t = 1
        #(`CYCLE) reset = 1'b0; // t = 2

		#(0.001);
		i = 1;
		while(i <= END_CYCLE) begin
			#(`CYCLE);
			if(i % 9 == 0)
				I2C_SDAT = 1'b0;
		end
	end

endmodule
