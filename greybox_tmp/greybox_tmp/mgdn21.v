//altsyncram ADDRESS_ACLR_B="NONE" CBX_SINGLE_OUTPUT_FILE="ON" CLOCK_ENABLE_INPUT_A="BCLOCK_ECLOCK_ENABLE_OUTPUT_A=CLOCK_ENABLE_INPUT_B=BYPASS" CLOCK_ENABLE_OUTPUT_B="BYPASS" READ_DURING_WRITE_MODE_MIXED_PORTS="DONT_CARE" WIDTH_A=16 WIDTH_B=16 WIDTH_BYTEENA_A=1 WIDTH_BYTEENA_B=1 WIDTH_ECCSTATUS=3 WIDTHAD_A=13 WIDTHAD_B=13 address_a address_b clock0 data_a q_a q_b wren_a
//VERSION_BEGIN 18.1 cbx_mgl 2018:09:12:13:10:36:SJ cbx_stratixii 2018:09:12:13:04:24:SJ cbx_util_mgl 2018:09:12:13:04:24:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2018  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details.



//synthesis_resources = altsyncram 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgdn21
	( 
	address_a,
	address_b,
	clock0,
	data_a,
	q_a,
	q_b,
	wren_a) /* synthesis synthesis_clearbox=1 */;
	input   [12:0]  address_a;
	input   [12:0]  address_b;
	input   clock0;
	input   [15:0]  data_a;
	output   [15:0]  q_a;
	output   [15:0]  q_b;
	input   wren_a;

	wire  [15:0]   wire_mgl_prim1_q_a;
	wire  [15:0]   wire_mgl_prim1_q_b;

	altsyncram   mgl_prim1
	( 
	.address_a(address_a),
	.address_b(address_b),
	.clock0(clock0),
	.data_a(data_a),
	.q_a(wire_mgl_prim1_q_a),
	.q_b(wire_mgl_prim1_q_b),
	.wren_a(wren_a));
	defparam
		mgl_prim1.address_aclr_b = "NONE",
		mgl_prim1.clock_enable_input_a = "BCLOCK_ECLOCK_ENABLE_OUTPUT_A=CLOCK_ENABLE_INPUT_B=BYPASS",
		mgl_prim1.clock_enable_output_b = "BYPASS",
		mgl_prim1.read_during_write_mode_mixed_ports = "DONT_CARE",
		mgl_prim1.width_a = 16,
		mgl_prim1.width_b = 16,
		mgl_prim1.width_byteena_a = 1,
		mgl_prim1.width_byteena_b = 1,
		mgl_prim1.width_eccstatus = 3,
		mgl_prim1.widthad_a = 13,
		mgl_prim1.widthad_b = 13;
	assign
		q_a = wire_mgl_prim1_q_a,
		q_b = wire_mgl_prim1_q_b;
endmodule //mgdn21
//VALID FILE
