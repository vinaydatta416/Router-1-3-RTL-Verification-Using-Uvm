class router_src_driver extends uvm_driver #(router_src_xtn);

	`uvm_component_utils(router_src_driver)

	virtual router_src_intf.SRC_DRV_MP vif;

	router_src_config m_cfg;

	extern function new(string name="router_src_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(router_src_xtn xtn);
	//extern function void report_phase(uvm_phase phase);

endclass: router_src_driver

function router_src_driver::new(string name="router_src_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void router_src_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(router_src_config)::get(this,"","router_src_config", m_cfg))
		`uvm_fatal(get_type_name(), "UNABLE TO GET THE CONFIG")
endfunction: build_phase

function void router_src_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task router_src_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);

	// Reseting the DUT
	@(vif.src_drv_cb);
	vif.src_drv_cb.resetn <= 1'b0;
	@(vif.src_drv_cb);
	vif.src_drv_cb.resetn <= 1'b1;

	// Getting the xtn through the DUT
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end

endtask: run_phase

task router_src_driver::send_to_dut(router_src_xtn xtn);
	
	// Sending the header
	@(vif.src_drv_cb);
	while(vif.src_drv_cb.busy) 	// If the busy is HIGH no data should be sent so adding a cb
		@(vif.src_drv_cb);	// wait() statement can be used but while is recommended with Verdi
	vif.src_drv_cb.pkt_valid 	<= 1'b1;
	vif.src_drv_cb.data_in		<= xtn.header;

	// Sending the payload
	@(vif.src_drv_cb);
	foreach(xtn.payload[i]) begin
		while(vif.src_drv_cb.busy) 	// If the busy is HIGH no data should be sent so adding a cb
			@(vif.src_drv_cb);	// wait() statement can be used but while is recommended with Verdi
		vif.src_drv_cb.data_in <= xtn.payload[i];
		@(vif.src_drv_cb);
	end

	// Sending the parity byte
	while(vif.src_drv_cb.busy) 	// If the busy is HIGH no data should be sent so adding a cb
		@(vif.src_drv_cb);	// wait() statement can be used but while is recommended with Verdi
	vif.src_drv_cb.pkt_valid 	<= 1'b0;
	vif.src_drv_cb.data_in		<= xtn.parity;

	repeat(2) @(vif.src_drv_cb);

	// Printing the sent packet
	m_cfg.drv_data_count++;
	`uvm_info(get_type_name(), $sformatf("\n\nTHE SOURCE DRIVER PACKET COUNT IS: %0d\nTHE PACKET SENT FROM THE DRIVER IS", m_cfg.drv_data_count), UVM_LOW)
	xtn.print();

endtask: send_to_dut


// Driver report phase
//function void router_src_driver::report_phase(uvm_phase phase);
//	super.report_phase(phase);
//
//	// Displaying the transaction count
//	`uvm_info("REPORT", $sformatf("\n\nTHE SOURCE DRIVER PACKET COUNT IS %0d\n", m_cfg.drv_data_count), UVM_LOW)
//
//endfunction: report_phase
