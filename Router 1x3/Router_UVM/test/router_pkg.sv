package router_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	// Transaction class
	`include "router_dst_xtn.sv"
	`include "router_src_xtn.sv"

	// Config files
	`include "router_src_config.sv"
	`include "router_dst_config.sv"
	`include "router_env_config.sv"

	// Source agent components
	`include "router_src_driver.sv"
	`include "router_src_monitor.sv"
	`include "router_src_sequencer.sv"
	`include "router_src_agent.sv"
	`include "router_src_agent_top.sv"
	`include "router_src_sequence.sv"

	// Destination agent components
	`include "router_dst_driver.sv"
	`include "router_dst_monitor.sv"
	`include "router_dst_sequencer.sv"
	`include "router_dst_agent.sv"
	`include "router_dst_agent_top.sv"
	`include "router_dst_sequence.sv"

	// Virtual seqs and seqr
	`include "router_virtual_sequencer.sv"
	`include "router_virtual_sequence.sv"

	// Scoreboard
	`include "router_scoreboard.sv"

	// Env and Test
	`include "router_env.sv"
	`include "router_test_lib.sv"

endpackage: router_pkg
