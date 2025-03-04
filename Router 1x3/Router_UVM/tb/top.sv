module top;

	import router_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	// CLOCK GENERATION
	bit clock;

	initial begin
		forever #10 clock = ~clock;
	end

	// INTERFACE INSTANTIATION
	router_src_intf src_if(clock);
	router_dst_intf dst_if0(clock);
	router_dst_intf dst_if1(clock);
	router_dst_intf dst_if2(clock);

	// DUT INSTANTIATION
	router_top DUV (
		.clock(clock),
		.resetn(src_if.resetn),
		.pkt_valid(src_if.pkt_valid),
		.data_in(src_if.data_in),
		.error(src_if.error),
		.busy(src_if.busy),
		.data_out_0(dst_if0.data_out),
		.data_out_1(dst_if1.data_out),
		.data_out_2(dst_if2.data_out),
		.read_enb_0(dst_if0.read_enb),
		.read_enb_1(dst_if1.read_enb),
		.read_enb_2(dst_if2.read_enb),
		.valid_out_0(dst_if0.valid_out),
		.valid_out_1(dst_if1.valid_out),
		.valid_out_2(dst_if2.valid_out)
	);

	// BINDING DUT WITH THE ASSERTION MODULE
	bind DUV router_assertions A1 (.*);

	initial begin

		`ifdef VCS
			$fsdbDumpvars(0, top);
		`endif
		
		// SETTING THE INTERFACE TO THE CONFIGURATION DATABASE
		uvm_config_db#(virtual router_src_intf)::set(null, "*", "vif", src_if);
		uvm_config_db#(virtual router_dst_intf)::set(null, "*", "vif0", dst_if0);
		uvm_config_db#(virtual router_dst_intf)::set(null, "*", "vif1", dst_if1);
		uvm_config_db#(virtual router_dst_intf)::set(null, "*", "vif2", dst_if2);

		// STARTING THE TEST
		run_test();
	end

//	//---- Assertions for testing -----
//
//	// Check stable data when busy asserted
//	property stable_datain;
//		@(posedge clock) DUV.busy |=> $stable(DUV.data_in);
//	endproperty: stable_datain
//
//	// Property to check busy goes HIGH after pkt_valid
//	property valid_busy;
//		@(posedge clock) $rose(DUV.pkt_valid) |=> DUV.busy;
//	endproperty: valid_busy
//
//	// Property to check if read_enb_X is asserted within 30 cycles of valid_out_X
//	property check_read_0;
//		@(posedge clock) $rose(DUV.valid_out_0) |-> ##[1:29] DUV.read_enb_0;
//	endproperty: check_read_0
//
//	property check_read_1;
//		@(posedge clock) $rose(DUV.valid_out_1) |-> ##[1:29] DUV.read_enb_1;
//	endproperty: check_read_1
//
//	property check_read_2;
//		@(posedge clock) $rose(DUV.valid_out_2) |-> ##[1:29] DUV.read_enb_2;
//	endproperty: check_read_2
//
//	// Property to check if valid_out_X third cycle after pkt_valid is asserted
//	property check_valid_out;
//		@(posedge clock) $rose(DUV.pkt_valid) |=> 	if($past(DUV.data_in[1:0] == 2'b00))
//													(##3 DUV.valid_out_0)
//												else if($past(DUV.data_in[1:0] == 2'b01))
//													(##3 DUV.valid_out_1)
//												else if($past(DUV.data_in[1:0] == 2'b10))
//													(##3 DUV.valid_out_2);
//	endproperty: check_valid_out
//
//	// Property to check if read_enb_X is de-asserted in the next cycle after valid_out_X goes LOW
//	property check_readn_0;
//		@(posedge clock) $fell(DUV.valid_out_0) |=> ~DUV.read_enb_0;
//	endproperty: check_readn_0
//
//	property check_readn_1;
//		@(posedge clock) $fell(DUV.valid_out_1) |=> ~DUV.read_enb_1;
//	endproperty: check_readn_1
//
//	property check_readn_2;
//		@(posedge clock) $fell(DUV.valid_out_2) |=> ~DUV.read_enb_2;
//	endproperty: check_readn_2
//
//	// ------ Asserting the properties ------
//	STABLE_DATA_IN	: assert property(stable_datain);
//	VALID_BUSY		: assert property(valid_busy);
//	CHECK_READ_0	: assert property(check_read_0);
//	CHECK_READ_1	: assert property(check_read_1);
//	CHECK_READ_2	: assert property(check_read_2);
//	CHECK_VALID_OUT	: assert property(check_valid_out);
//	CHECK_READN_0	: assert property(check_readn_0);
//	CHECK_READN_1	: assert property(check_readn_1);
//	CHECK_READN_2	: assert property(check_readn_2);

endmodule: top
