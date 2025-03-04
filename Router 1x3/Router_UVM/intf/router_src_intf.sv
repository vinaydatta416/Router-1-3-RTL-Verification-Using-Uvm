interface router_src_intf (input clock);

	logic resetn;
	logic pkt_valid;
	logic [7:0] data_in;
	logic busy;
	logic error;

	clocking src_drv_cb @ (posedge clock);

		default input #1 output #1;	
		output resetn;
		output pkt_valid;
		output data_in;
		input error;
		input busy;

	endclocking: src_drv_cb

	clocking src_mon_cb @ (posedge clock);

		default input #1 output #1;	
		input resetn;
		input pkt_valid;
		input data_in;
		input error;
		input busy;

	endclocking: src_mon_cb

	modport SRC_DRV_MP (clocking src_drv_cb);
	modport SRC_MON_MP (clocking src_mon_cb);

endinterface: router_src_intf
