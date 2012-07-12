`timescale 1 ns / 100 ps

module epp (
   //system signals
   input clk,
   input rst_n,

   //usb epp signals
   input EppAstb,   //address strobe
   input EppDstb,   //data strobe
   output EppWait,
   input EppWr,
   inout [7:0] EppDB,

   output reg [7:0] reg_data1,
   output reg [7:0] reg_data2,
   output reg [7:0] reg_data3,
   output reg [7:0] reg_data4
);

//statemachine states
        //Name                State    DWR    AWR    Dir    Wait
parameter s_ready           = {4'd0,   1'b0,  1'b0,  1'b0,  1'b0};
parameter s_addressWriteA   = {4'd1,   1'b0,  1'b1,  1'b0,  1'b0};
parameter s_addressWriteB   = {4'd2,   1'b0,  1'b0,  1'b0,  1'b1};
parameter s_addressReadA    = {4'd3,   1'b0,  1'b0,  1'b1,  1'b0};
parameter s_addressReadB    = {4'd4,   1'b0,  1'b0,  1'b1,  1'b1};
parameter s_dataWriteA      = {4'd5,   1'b1,  1'b0,  1'b0,  1'b0};
parameter s_dataWriteB      = {4'd6,   1'b0,  1'b0,  1'b0,  1'b1};
parameter s_dataReadA       = {4'd7,   1'b0,  1'b0,  1'b1,  1'b0};
parameter s_dataReadB       = {4'd8,   1'b0,  1'b0,  1'b1,  1'b1};

reg [7:0] cur_state;
reg [7:0] next_state;

//internal control registers
wire ctlEppWait;
wire ctlEppDir;
wire ctlEppAwr;
wire ctlEppDwr;

//get internal control signals from statemachine states
assign ctlEppWait = cur_state[0];
assign ctlEppDir  = cur_state[1];
assign ctlEppAwr  = cur_state[2];
assign ctlEppDwr  = cur_state[3];

//connect wait control line to output
assign EppWait = ctlEppWait;

//Tri-State logic for EppDB
reg [7:0] epp_out;
assign EppDB = (EppWr == 1 && ctlEppDir == 1) ? epp_out : 8'bz;

//registers
reg [1:0] reg_addr;

//multiplex registers to data out register
always @(reg_addr or reg_data1 or reg_data2 or reg_data3 or reg_data4) begin
    case(reg_addr)
        2'b00: epp_out <= reg_data1;
        2'b01: epp_out <= reg_data2;
        2'b10: epp_out <= reg_data3;
        2'b11: epp_out <= reg_data4;
        //default: epp_out <= 8'h00;
    endcase
end

//fill address register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        reg_addr <= 2'b00;
    end else begin
        if(ctlEppAwr == 1)
            reg_addr <= EppDB[1:0];
    end
end

//fill data registers
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        reg_data1 <= 8'd0;
        reg_data2 <= 8'd0;
        reg_data3 <= 8'd0;
        reg_data4 <= 8'd0;
    end else begin
        if(ctlEppDwr == 1 && reg_addr == 0)
            reg_data1 <= EppDB;
        else if(ctlEppDwr == 1 && reg_addr == 1)
            reg_data2 <= EppDB;
        else if(ctlEppDwr == 1 && reg_addr == 2)
            reg_data3 <= EppDB;
        else if(ctlEppDwr == 1 && reg_addr == 3)
            reg_data4 <= EppDB;
    end
end

//statemachine logic
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cur_state <= s_ready;
        next_state <= s_ready;
    end else begin
        case(cur_state)
            //Idle state - begin of transactions
            s_ready:
                if(EppAstb == 0)
                    //address operation
                    if(EppWr == 0)
                        next_state <= s_addressWriteA;
                    else
                        next_state <= s_addressReadA;
                else if(EppDstb == 0)
                    //data operation
                    if(EppWr == 0)
                        next_state <= s_dataWriteA;
                    else
                        next_state <= s_dataReadA;
                else
                    next_state <= s_ready;

            //Write address
            s_addressWriteA:
                next_state <= s_addressWriteB;

            s_addressWriteB:
                if(EppAstb == 0)
                    next_state <= s_addressWriteB;
                else
                    next_state <= s_ready;

            //Read address
            s_addressReadA:
                next_state <= s_addressReadB;

            s_addressReadB:
                if(EppAstb == 0)
                    next_state <= s_addressReadB;
                else
                    next_state <= s_ready;

            //Write data
            s_dataWriteA:
                next_state <= s_dataWriteB;

            s_dataWriteB:
                if(EppDstb == 0)
                    next_state <= s_dataWriteB;
                else
                    next_state <= s_ready;

            //Read data
            s_dataReadA:
                next_state <= s_dataReadB;

            s_dataReadB:
                if(EppDstb == 0)
                    next_state <= s_dataReadB;
                else
                    next_state <= s_ready;

            default:
                next_state <= s_ready;
        endcase

        //advance to next state
        cur_state <= next_state;
    end
end

endmodule
