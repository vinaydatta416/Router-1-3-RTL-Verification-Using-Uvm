// Base test
class router_base_test extends uvm_test;

	`uvm_component_utils(router_base_test)

	router_env_config env_cfg;
	router_src_config src_cfg;
	router_dst_config dst_cfg[];

	router_env envh;

	bit has_src_agent 	= 1;
	bit has_dst_agent 	= 1;
	bit has_scoreboard 	= 1;
	int no_of_dst		= 3;

	// Property to choose the destination
	bit [1:0] dst_addr;  // Valid destination are 0,1 and 2

	extern function new(string name, uvm_component parent);
	extern function void config_router();
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);

endclass: router_base_test

// CLASS CONSTRUCTOR
function router_base_test::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new


// FUNCTION TO CONFIGURE THE AGENT CONFIGS
function void router_base_test::config_router();

	// SOURCE AGENT CONFIGURATION SETTING
	if(has_src_agent == 1) begin
		src_cfg = router_src_config::type_id::create("src_cfg");
		
		if(!uvm_config_db#(virtual router_src_intf)::get(this, "", "vif", src_cfg.vif))
			`uvm_fatal(get_type_name(), "UNABLE TO OBTAIN VIRTUAL INTERFACE FOR SOURCE");
		
		src_cfg.is_active = UVM_ACTIVE;
		env_cfg.src_cfg = this.src_cfg;
	end

	// DESTINATION AGENT CONFIGURATION SETTING
	if(has_dst_agent == 1) begin
		
		dst_cfg = new[no_of_dst];
		env_cfg.dst_cfg = new[no_of_dst];

		foreach (dst_cfg[i]) begin
			dst_cfg[i] = router_dst_config::type_id::create($sformatf("dst_cfg%0d", i));
			
			if(!uvm_config_db#(virtual router_dst_intf)::get(this, "", $sformatf("vif%0d", i), dst_cfg[i].vif))
				`uvm_fatal(get_type_name(), "UNABLE TO OBTAIN VIRTUAL INTERFACE FOR DESTINATION");

			dst_cfg[i].is_active = UVM_ACTIVE;
			env_cfg.dst_cfg[i] = dst_cfg[i];
		end
	end

	env_cfg.has_src_agent 	= this.has_src_agent;
	env_cfg.has_dst_agent 	= this.has_dst_agent;
	env_cfg.has_scoreboard 	= this.has_scoreboard;
	env_cfg.no_of_dst 		= this.no_of_dst;	
	env_cfg.dst_addr		= this.dst_addr;

endfunction: config_router

// BUILD PHASE
function void router_base_test::build_phase(uvm_phase phase);
	
	super.build_phase(phase);

	// Setting the destination address variable to database	
	if($value$plusargs("DST_ADDR=%0b", this.dst_addr)) begin
		`uvm_info(get_type_name(), "DST_ADDR Received from Makefile", UVM_LOW)
		uvm_config_db#(bit[1:0])::set(this, "*", "dst_addr", this.dst_addr);
	end
	else
		`uvm_fatal(get_type_name(), "Set DST_ADDR properly in the makefile")

	// ENVIRONMNET CONFIGURATION SETTING
	env_cfg = router_env_config::type_id::create("env_cfg");

	config_router();

	uvm_config_db#(router_env_config)::set(this, "*", "router_env_config", env_cfg);

	// BUILDING THE ENVIRONMNET
	envh = router_env::type_id::create("envh", this);

endfunction: build_phase

// PRINTING THE TOPOLOGY
function void router_base_test::end_of_elaboration_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("\n\nThe router TB topology is shown below"), UVM_LOW)
	uvm_top.print_topology();
endfunction: end_of_elaboration_phase

// ------- Testcases ---------

//-----------------------------------------------------------
// Packet tests by starting normal sequence on sequencer
//-----------------------------------------------------------

// Small packet source side test
class small_packet_src_test extends router_base_test;

	`uvm_component_utils(small_packet_src_test)
	
	function new(string name="small_packet_src_test", uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	small_packet_src_seq 	small_src_seq;

	task run_phase(uvm_phase phase);

		phase.raise_objection(this);

		small_src_seq = small_packet_src_seq::type_id::create("small_src_seq");
		small_src_seq.start(envh.src_agnt_toph.agnth.seqrh);
		#100;

		phase.drop_objection(this);

	endtask: run_phase

endclass: small_packet_src_test

// Soft reset test
class soft_reset_test extends router_base_test;

	`uvm_component_utils(soft_reset_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	small_packet_src_seq 	small_seqs;
	with_delay_dst_seq		with_delay_seqs;

	task run_phase(uvm_phase phase);

		small_seqs 		= small_packet_src_seq::type_id::create("small_seqs");
		with_delay_seqs	= with_delay_dst_seq::type_id::create("with_delay_seqs");

		phase.raise_objection(this);
		fork
			small_seqs.start(envh.src_agnt_toph.agnth.seqrh);
			with_delay_seqs.start(envh.dst_agnt_toph.agnth[dst_addr].seqrh);
		join
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: soft_reset_test

// Bad packet test
class bad_packet_test extends router_base_test;

	`uvm_component_utils(bad_packet_test)
	
	function new(string name="bad_packet_test", uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	bad_packet_src_seq 	bad_seqs;
	no_delay_dst_seq	no_delay_seqs;

	task run_phase(uvm_phase phase);

		bad_seqs 		= bad_packet_src_seq::type_id::create("bad_seqs");
		no_delay_seqs	= no_delay_dst_seq::type_id::create("no_delay_seqs");

		phase.raise_objection(this);
		fork
			bad_seqs.start(envh.src_agnt_toph.agnth.seqrh);
			no_delay_seqs.start(envh.dst_agnt_toph.agnth[dst_addr].seqrh);
		join
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: bad_packet_test

// Small packet test with source and destination implemented
class small_packet_test extends router_base_test;

	`uvm_component_utils(small_packet_test)
	
	function new(string name="small_packet_test", uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	small_packet_src_seq 	small_seqs;
	no_delay_dst_seq		no_delay_seqs;

	task run_phase(uvm_phase phase);

		small_seqs 		= small_packet_src_seq::type_id::create("small_seqs");
		no_delay_seqs	= no_delay_dst_seq::type_id::create("no_delay_seqs");

		phase.raise_objection(this);
		fork
			small_seqs.start(envh.src_agnt_toph.agnth.seqrh);
			no_delay_seqs.start(envh.dst_agnt_toph.agnth[dst_addr].seqrh);
		join
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: small_packet_test

// Medium packet test
class medium_packet_test extends router_base_test;

	`uvm_component_utils(medium_packet_test)
	
	function new(string name="medium_packet_test", uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	medium_packet_src_seq 	medium_seqs;
	no_delay_dst_seq	no_delay_seqs;

	task run_phase(uvm_phase phase);

		medium_seqs 		= medium_packet_src_seq::type_id::create("medium_seqs");
		no_delay_seqs	= no_delay_dst_seq::type_id::create("no_delay_seqs");

		phase.raise_objection(this);
		fork
			medium_seqs.start(envh.src_agnt_toph.agnth.seqrh);
			no_delay_seqs.start(envh.dst_agnt_toph.agnth[dst_addr].seqrh);
		join
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: medium_packet_test

// Big packet test
class big_packet_test extends router_base_test;

	`uvm_component_utils(big_packet_test)
	
	function new(string name="big_packet_test", uvm_component parent);
		super.new(name, parent);	
	endfunction: new	

	big_packet_src_seq 	big_seqs;
	no_delay_dst_seq	no_delay_seqs;

	task run_phase(uvm_phase phase);

		big_seqs 		= big_packet_src_seq::type_id::create("big_seqs");
		no_delay_seqs	= no_delay_dst_seq::type_id::create("no_delay_seqs");

		phase.raise_objection(this);
		fork
			big_seqs.start(envh.src_agnt_toph.agnth.seqrh);
			no_delay_seqs.start(envh.dst_agnt_toph.agnth[dst_addr].seqrh);
		join
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: big_packet_test

//-----------------------------------------------------------
// Packet tests by starting virtual sequence on sequencer
//-----------------------------------------------------------

// Small packet test using virtual sequencer
class small_packet_vseq_test extends router_base_test;
	
	`uvm_component_utils(small_packet_vseq_test)

	function new(string name="small_packet_vseq_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	small_packet_vseq small_vseq;

	task run_phase(uvm_phase phase);
			
		small_vseq = small_packet_vseq::type_id::create("small_vseq");

		phase.raise_objection(this);
		small_vseq.start(envh.v_seqrh);
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: small_packet_vseq_test

// Medium packet test using virtual sequencer
class medium_packet_vseq_test extends router_base_test;
	
	`uvm_component_utils(medium_packet_vseq_test)

	function new(string name="medium_packet_vseq_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	medium_packet_vseq medium_vseq;

	task run_phase(uvm_phase phase);
			
		medium_vseq = medium_packet_vseq::type_id::create("medium_vseq");

		phase.raise_objection(this);
		medium_vseq.start(envh.v_seqrh);
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: medium_packet_vseq_test

// Big packet test using virtual sequencer
class big_packet_vseq_test extends router_base_test;
	
	`uvm_component_utils(big_packet_vseq_test)

	function new(string name="big_packet_vseq_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	big_packet_vseq big_vseq;

	task run_phase(uvm_phase phase);
			
		big_vseq = big_packet_vseq::type_id::create("big_vseq");

		phase.raise_objection(this);
		big_vseq.start(envh.v_seqrh);
		#100;
		phase.drop_objection(this);

	endtask: run_phase

endclass: big_packet_vseq_test








