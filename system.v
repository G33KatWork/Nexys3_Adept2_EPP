`timescale 1 ns / 100 ps

module system (
   input clk,
   input btns,
   output [7:0] Led,

   //EPP-Interface
   input EppAstb,   //address strobe
   input EppDstb,   //data strobe
   output EppWait,
   input EppWr,
   inout [7:0] EppDB
);

wire rst_n;
assign rst_n = ~btns;

wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;
wire [7:0] data4;

assign Led = data2;

epp epp_inst(
    .clk(clk),
    .rst_n(rst_n),
    .EppAstb(EppAstb),
    .EppDstb(EppDstb),
    .EppWait(EppWait),
    .EppWr(EppWr),
    .EppDB(EppDB),

    .reg_data1(data1),
    .reg_data2(data2),
    .reg_data3(data3),
    .reg_data4(data4)
);

endmodule
