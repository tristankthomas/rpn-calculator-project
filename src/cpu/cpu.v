`default_nettype none
`include "cpu_definitions.vh"

module cpu
(
	// System
	input wire clk,
	input wire enable,
	input wire resetn,
	// Instructions
	input wire [31:0] instruction,
	output reg [7:0] instruction_pointer,
	// Inputs
	input wire [7:0] din,
	input wire [3:0] gpi,
	// Outputs
	output wire [7:0] reg_dout,
	output wire [7:0] reg_gout,
	output wire [7:0] reg_flag
);


	wire [2:0] command_group;
	wire [2:0] command;
	wire [7:0] arg1;
	wire arg1_type;
	wire [7:0] arg2;
	wire arg2_type;
	wire [7:0] result;
	wire [7:0] address;
	
	wire branch_select;
	wire [3:0] alu_op;
	wire write_enable;
	wire [7:0] flag_inputs;
	wire [7:0] a_data_out;
	
	
	assign reg_gout = 8'b1000_0000; // Turn on dval (reg_gout[7])
	
	always @(posedge clk or negedge resetn)
		if (!resetn)
			instruction_pointer <= 8'd0;
		else if (enable)		// pointer incremented when enable out is 1 (controlled by turbo)
			instruction_pointer <= (branch_select && result) ? address : instruction_pointer + 1;		// instruction pointer incremented and then next arg1 (from ROM) stored in reg_dout
	// test

			
	// register file
	assign flag_inputs = {2'd0, shift_overflow, 5'd0};
	
	register_file
	reg_ista
	(
		.clk(clk),
		.enable(1),
		.resetn(resetn),
		
		.a_addr(arg1), // the argument is a number in this case (8 bits)
		.a_data_out(a_data_out),
		
		.b_addr(arg2),
		.b_data_in(result),
		.b_wr_enable(write_enable),
		.b_data_out(),
		
		.flag_inputs(flag_inputs),
		
		.reg_gout(),
		.reg_dout(reg_dout),
		.reg_flag(reg_flag)
	);
	
	
			
	// instruction splitter
	instruction_splitter
	is
	(
		.instruction(instruction),
		.command_group(command_group),
		.command(command),
		.arg1_type(arg1_type),
		.arg1(arg1),
		.arg2_type(arg2_type),
		.arg2(arg2),
		.address(address)
	);
	

	// controller
	controller
	cont_insta
	(
		.command_group(command_group),
		.command(command),
		.write_enable(write_enable),
		.branch_select(branch_select),
		.alu_op(alu_op)
	);
	
	
	// ALU
	wire [7:0] operand_a = arg1_type ? a_data_out : arg1; // operand a is a number if the type is 0 or a register if 1
	wire shift_overflow;
	alu
	alu_insta
	(
		.operand_a(operand_a),
		.alu_op(alu_op),
		.result(result),
		.shift_overflow(shift_overflow)
	);
	
	

	
			
endmodule