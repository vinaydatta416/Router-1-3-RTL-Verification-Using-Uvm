interface router_dst_intf (input clock);

	logic [7:0] data_out;
	logic valid_out;
	logic read_enb;

	clocking dst_drv_cb @(posedge clock);
	
		default input #1 output #1;
		output read_enb;
		input valid_out;

	endclocking: dst_drv_cb

	clocking dst_mon_cb @(posedge clock);

		default input #1 output #1;
		input data_out;
		input read_enb;

	endclocking: dst_mon_cb

	modport DST_DRV_MP (clocking dst_drv_cb);
	modport DST_MON_MP (clocking dst_mon_cb);

endinterface: router_dst_intf
