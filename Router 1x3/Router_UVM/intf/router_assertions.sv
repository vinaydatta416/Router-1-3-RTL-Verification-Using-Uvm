module router_assertions (
	input logic clock,
	input logic resetn,
	input logic pkt_valid,
	input logic [7:0] data_in,
	input logic error,
	input logic busy,
	input logic [7:0] data_out_0,
	input logic [7:0] data_out_1,
	input logic [7:0] data_out_2,
	input logic read_enb_0,
	input logic read_enb_1,
	input logic read_enb_2,
	input logic valid_out_0,
	input logic valid_out_1,
	input logic valid_out_2
);

	// Check stable data when busy asserted
	property stable_datain;
		@(posedge clock) busy |=> $stable(data_in);
	endproperty: stable_datain

	// Property to check busy goes HIGH after pkt_valid
	property valid_busy;
		@(posedge clock) $rose(pkt_valid) |=> busy;
	endproperty: valid_busy

	// Property to check if read_enb_X is asserted within 30 cycles of valid_out_X
	property check_read_0;
		@(posedge clock) $rose(valid_out_0) |-> ##[1:29] read_enb_0;
	endproperty: check_read_0

	property check_read_1;
		@(posedge clock) $rose(valid_out_1) |-> ##[1:29] read_enb_1;
	endproperty: check_read_1

	property check_read_2;
		@(posedge clock) $rose(valid_out_2) |-> ##[1:29] read_enb_2;
	endproperty: check_read_2

	// Property to check if valid_out_X third cycle after pkt_valid is asserted
	property check_valid_out;
		@(posedge clock) $rose(pkt_valid) |=> 	if($past(data_in[1:0] == 2'b00))
													(##3 valid_out_0)
												else if($past(data_in[1:0] == 2'b01))
													(##3 valid_out_1)
												else if($past(data_in[1:0] == 2'b10))
													(##3 valid_out_2);
	endproperty: check_valid_out

	// Property to check if read_enb_X is de-asserted in the next cycle after valid_out_X goes LOW
	property check_readn_0;
		@(posedge clock) $fell(valid_out_0) |=> ~read_enb_0;
	endproperty: check_readn_0

	property check_readn_1;
		@(posedge clock) $fell(valid_out_1) |=> ~read_enb_1;
	endproperty: check_readn_1

	property check_readn_2;
		@(posedge clock) $fell(valid_out_2) |=> ~read_enb_2;
	endproperty: check_readn_2

	// ------ Asserting the properties ------
	STABLE_DATA_IN	: assert property(stable_datain);
	VALID_BUSY		: assert property(valid_busy);
	CHECK_READ_0	: assert property(check_read_0);
	CHECK_READ_1	: assert property(check_read_1);
	CHECK_READ_2	: assert property(check_read_2);
	CHECK_VALID_OUT	: assert property(check_valid_out);
	CHECK_READN_0	: assert property(check_readn_0);
	CHECK_READN_1	: assert property(check_readn_1);
	CHECK_READN_2	: assert property(check_readn_2);

	// ------ Covering the properties ------
	COV_STABLE_DATA_IN	: cover property(stable_datain);
	COV_VALID_BUSY		: cover property(valid_busy);
	COV_CHECK_READ_0	: cover property(check_read_0);
	COV_CHECK_READ_1	: cover property(check_read_1);
	COV_CHECK_READ_2	: cover property(check_read_2);
	COV_CHECK_VALID_OUT	: cover property(check_valid_out);
	COV_CHECK_READN_0	: cover property(check_readn_0);
	COV_CHECK_READN_1	: cover property(check_readn_1);
	COV_CHECK_READN_2	: cover property(check_readn_2);

endmodule: router_assertions
