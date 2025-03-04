class router_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(router_scoreboard)

	uvm_tlm_analysis_fifo#(router_src_xtn) src_fifoh;
	uvm_tlm_analysis_fifo#(router_dst_xtn) dst_fifoh[];

	router_env_config m_cfg;
	router_src_config src_cfg;
	router_dst_config dst_cfg;

	router_src_xtn src_mon_data;
	router_dst_xtn dst_mon_data;

	router_src_xtn src_cov_data;
	router_dst_xtn dst_cov_data;

	int valid_pkt_count 	= 0;
	int invalid_pkt_count	= 0;
	int src_pkt_count		= 0;
	int dst_pkt_count		= 0;

	bit [1:0] dst_addr;

	extern function new(string name="router_scoreboard", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern function void compare_xtn(router_src_xtn src_xtn, router_dst_xtn dst_xtn);
	extern function void report_phase(uvm_phase phase);

	// Covergroup information
	covergroup src_covgrp;
		
		CHANNEL: coverpoint src_cov_data.header[1:0] {
				bins DST_00 = {2'b00};
				bins DST_01 = {2'b01};
				bins DST_02 = {2'b10};
				illegal_bins DST_03 = {2'b11};
		}
		
		PAYLOAD_LEN: coverpoint src_cov_data.header[7:2] {
				bins SMALL 	= {[1:14]};
				bins MEDIUM = {[15:30]};
				bins BIG 	= {[31:63]};
				illegal_bins ILLEGAL = {[63:$]};
		}
		
		BAD_PKT: coverpoint src_cov_data.error {
				bins GOOD_PKT	= {0};
				bins BAD_PKT	= {1};
		}

	endgroup: src_covgrp

	covergroup dst_covgrp;
		
		CHANNEL: coverpoint dst_cov_data.header[1:0] {
				bins DST_00 = {2'b00};
				bins DST_01 = {2'b01};
				bins DST_02 = {2'b10};
				illegal_bins DST_03 = {2'b11};
		}
		
		PAYLOAD_LEN: coverpoint dst_cov_data.header[7:2] {
				bins SMALL 	= {[1:14]};
				bins MEDIUM = {[15:30]};
				bins BIG 	= {[31:63]};
				illegal_bins ILLEGAL = {[63:$]};
		}

	endgroup: dst_covgrp

endclass: router_scoreboard

// Constructor
function router_scoreboard::new(string name, uvm_component parent);
	super.new(name, parent);

	src_covgrp = new();
	dst_covgrp = new();
endfunction: new


// Build phase
function void router_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(router_env_config)::get(this, "", "router_env_config", m_cfg))
		`uvm_fatal(get_type_name(), "FAILED TO OBTAIN ENV CONFIG")

	src_fifoh = new("src_fifoh", this);
	dst_fifoh = new[m_cfg.no_of_dst];
	foreach (dst_fifoh[i])
		dst_fifoh[i] = new($sformatf("dst_fifoh%0d", i), this);

endfunction: build_phase


// Run phase
task router_scoreboard::run_phase(uvm_phase phase);

	forever begin
		fork 
			begin: SRC_THREAD

				src_mon_data = router_src_xtn::type_id::create("src_mon_data");
				src_cov_data = router_src_xtn::type_id::create("src_cov_data");

				src_fifoh.get(src_mon_data);
				src_pkt_count++;
				`uvm_info(get_type_name(), $sformatf("\n\nTHE SCOREBOARD SOURCE PACKET COUNT IS %0d\n\nPACKET RECEIVED AT SCOREBOARD FROM SRC IS:",src_pkt_count), UVM_LOW)
				src_mon_data.print();

				src_cov_data = src_mon_data;
				src_covgrp.sample();
			end
			begin: DST_THREAD
				dst_mon_data = router_dst_xtn::type_id::create("dst_mon_data");
				dst_cov_data = router_dst_xtn::type_id::create("dst_cov_data");

				if(!uvm_config_db#(bit[1:0])::get(this, "", "dst_addr", dst_addr))
					`uvm_fatal(get_type_name(), "FAILED TO OBTAIN DST_ADDR FROM TEST")

				dst_fifoh[dst_addr].get(dst_mon_data);
				dst_pkt_count++;
				`uvm_info(get_type_name(), $sformatf("\n\nTHE SCOREBOARD DESTINATION PACKET COUNT IS %0d\n\nPACKET RECEIVED AT SCOREBOARD FROM DST IS:",dst_pkt_count), UVM_LOW)
				dst_mon_data.print();

				dst_cov_data = dst_mon_data;
				dst_covgrp.sample();

				compare_xtn(src_mon_data, dst_mon_data);
			end
		join

	end	

endtask: run_phase


// Compare method
function void router_scoreboard::compare_xtn(router_src_xtn src_xtn, router_dst_xtn dst_xtn);

	if(src_xtn.header == dst_xtn.header) begin
		if(src_xtn.payload == dst_xtn.payload) begin
			if(src_xtn.parity == dst_xtn.parity) begin
				`uvm_info(get_type_name(), "\n\nPayload verified\n", UVM_LOW)
				valid_pkt_count++;
				return;
			end
		end
	end
	else begin
		`uvm_info(get_type_name(), "\n\nWrong payload received at destination\n", UVM_LOW)
		invalid_pkt_count++;
		return;
	end

endfunction: compare_xtn


// Report phase
function void router_scoreboard::report_phase(uvm_phase phase);
	
	super.report_phase(phase);

	`uvm_info(get_type_name(), $sformatf("\n\n---- SCOREBOARD REPORT ----\nPacket count from src 	= %0d\nPacket count from dst 	= %0d\nValid packet count 	= %0d\nInvalid packet count 	= %0d\n", src_pkt_count, dst_pkt_count, valid_pkt_count, invalid_pkt_count), UVM_LOW)

endfunction: report_phase





