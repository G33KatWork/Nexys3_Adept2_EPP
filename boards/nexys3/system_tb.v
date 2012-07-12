//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module system_tb;

//----------------------------------------------------------------------------
// Parameter (may differ for physical synthesis)
//----------------------------------------------------------------------------
parameter tck              = 10;       // clock period in ns
parameter clk_freq = 1000000000 / tck; // Frequenzy in HZ
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
reg        clk;
reg        reset;
wire [7:0] led;

reg EppAstb;
reg EppDstb;
wire EppWait;
reg EppWr;
wire [7:0] EppDB;

reg [7:0] epp_data_out;
wire [7:0] epp_data_in;

assign EppDB = EppWr == 0 ? epp_data_out : 8'hzz;
assign epp_data_in = EppDB;

//------------------------------------------------------------------
// Decive Under Test
//------------------------------------------------------------------
system #(
) dut  (
	.clk(          clk    ),
	.btns(         reset  ),
	.Led(          led    ),
	.EppAstb(      EppAstb),
	.EppDstb(      EppDstb),
	.EppWait(      EppWait),
	.EppWr(        EppWr  ),
	.EppDB(        EppDB  )
);

/* Clocking device */
initial         clk <= 0;
always #(tck/2) clk <= ~clk;

/* Initial values for EPP interface */
initial begin
	EppAstb <= 1;
	EppDstb <= 1;
	EppWr <= 1;
	epp_data_out <= 8'h00;
end

/* Simulation setup */
initial begin
	$dumpfile("system_tb.vcd");
	$dumpvars(-1, dut);

	// reset
	#0  reset <= 1;
	#10 reset <= 0;

	//write address register 1
	#20 epp_data_out <= 8'h01;
	#21 EppWr <= 0;
	#22 EppDstb <= 1;
	#23 EppAstb <= 0;
	#24 EppAstb <= 1;

	//write data 0xAA
	#30 epp_data_out <= 8'hAA;
	#31 EppDstb <= 0;
	#32 EppDstb <= 1;
	#33 EppWr <= 1;

	//read it back
	#40 EppDstb <= 0;
	#41 EppDstb <= 1;
	$display("Read value is %x", epp_data_in);

	#(tck*50) $finish;
end

endmodule
