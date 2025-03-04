# Makefile for Router UVM Project
RTL = ../rtl/* ../intf/*
INC = +incdir+../tb +incdir+../test +incdir+../src_agent +incdir+../dst_agent
SVTB1 = ../tb/top.sv
SVTB2 = ../test/router_pkg.sv
work = work #library name

FSDB_PATH = /home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64


# Make targets for SV compilation using VCS
sv_cmp:
	vcs -l vcs.log -timescale=1ns/1ps -assert svaext -cm line+tgl+fsm+branch+cond -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1) $(SVTB3)


# Make targets for running each testcases
run_test_top: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavetop.fsdb -cm_dir ./mem_covtop +ntb_random_seed_automatic +UVM_TESTNAME=router_base_test +DST_ADDR=01
	urg -dir mem_covtop.vdb -format both -report urgReporttop	

run_test_src_small: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavesrc_small.fsdb -cm_dir ./mem_covsrc_small +ntb_random_seed_automatic +UVM_TESTNAME=small_packet_src_test +DST_ADDR=01
	urg -dir mem_covsrc_small.vdb -format both -report urgReportsrc_small	

run_test_small: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavesmall.fsdb -cm_dir ./mem_covsmall +ntb_random_seed_automatic +UVM_TESTNAME=small_packet_test +DST_ADDR=00
	urg -dir mem_covsmall.vdb -format both -report urgReportsmall	

run_test_medium: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavemedium.fsdb -cm_dir ./mem_covmedium +ntb_random_seed_automatic +UVM_TESTNAME=medium_packet_test +DST_ADDR=00 +UVM_OBJECTION_TRACE
	urg -dir mem_covmedium.vdb -format both -report urgReportmedium	

run_test_big: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavebig.fsdb -cm_dir ./mem_covbig +ntb_random_seed_automatic +UVM_TESTNAME=big_packet_test +DST_ADDR=10
	urg -dir mem_covbig.vdb -format both -report urgReportbig	

run_test_soft_reset: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavesoft_reset.fsdb -cm_dir ./mem_covsoft_reset +ntb_random_seed_automatic +UVM_TESTNAME=soft_reset_test +DST_ADDR=01
	urg -dir mem_covsoft_reset.vdb -format both -report urgReportsoft_reset	

run_test_bad: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavebad.fsdb -cm_dir ./mem_covbad +ntb_random_seed_automatic +UVM_TESTNAME=bad_packet_test +DST_ADDR=1
	urg -dir mem_covbad.vdb -format both -report urgReportbad	

run_test_smallvseq: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavesmallvseq.fsdb -cm_dir ./mem_covsmallvseq +ntb_random_seed_automatic +UVM_TESTNAME=small_packet_vseq_test +DST_ADDR=00
	urg -dir mem_covsmallvseq.vdb -format both -report urgReportsmallvseq	

run_test_mediumvseq: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavemediumvseq.fsdb -cm_dir ./mem_covmediumvseq +ntb_random_seed_automatic +UVM_TESTNAME=medium_packet_vseq_test +DST_ADDR=00
	urg -dir mem_covmediumvseq.vdb -format both -report urgReportmediumvseq	

run_test_bigvseq: clean sv_cmp
	./simv -a vcs.log +fsdbfile+wavebigvseq.fsdb -cm_dir ./mem_covbigvseq +ntb_random_seed_automatic +UVM_TESTNAME=big_packet_vseq_test +DST_ADDR=00
	urg -dir mem_covbigvseq.vdb -format both -report urgReportbigvseq	


# Make targets to call for regress
test_small:
	./simv -a vcs.log +fsdbfile+wavesmall.fsdb -cm_dir ./mem_covsmall +ntb_random_seed=18745248 +UVM_TESTNAME=small_packet_vseq_test +DST_ADDR=00
	urg -dir mem_covsmall.vdb -format both -report urgReportsmall	

test_medium: 
	./simv -a vcs.log +fsdbfile+wavemedium.fsdb -cm_dir ./mem_covmedium +ntb_random_seed=624551742 +UVM_TESTNAME=medium_packet_vseq_test +DST_ADDR=01
	urg -dir mem_covmedium.vdb -format both -report urgReportmedium	

test_big:
	./simv -a vcs.log +fsdbfile+wavebig.fsdb -cm_dir ./mem_covbig +ntb_random_seed=2897767106 +UVM_TESTNAME=big_packet_vseq_test +DST_ADDR=10
	urg -dir mem_covbig.vdb -format both -report urgReportbig	

test_bad:
	./simv -a vcs.log +fsdbfile+wavebad.fsdb -cm_dir ./mem_covbad +ntb_random_seed=3482637390 +UVM_TESTNAME=bad_packet_test +DST_ADDR=01
	urg -dir mem_covbad.vdb -format both -report urgReportbad	

test_soft_reset: 
	./simv -a vcs.log +fsdbfile+wavesoft_reset.fsdb -cm_dir ./mem_covsoft_reset +ntb_random_seed_automatic +UVM_TESTNAME=soft_reset_test +DST_ADDR=01
	urg -dir mem_covsoft_reset.vdb -format both -report urgReportsoft_reset	

# Make target to merge the coverage reports
report:
	urg -dir mem_covsmall.vdb mem_covmedium.vdb mem_covbig.vdb mem_covbad.vdb mem_covsoft_reset.vdb -dbname merged_dir/merged_test -format both -report urgReport


# Make targets for regression test
regress: clean sv_cmp test_small test_medium test_big test_bad test_soft_reset report


# Make target to open the coverage report inside VCS GUI
cov:
	verdi -cov -covdir merged_dir.vdb


# Make targets for opening the waveform
view_wave_top: 
	verdi -ssf wavetop.fsdb

view_wave_src_small: 
	verdi -ssf wavesrc_small.fsdb

view_wave_small: 
	verdi -ssf wavesmall.fsdb

view_wave_medium: 
	verdi -ssf wavemedium.fsdb

view_wave_big: 
	verdi -ssf wavebig.fsdb

view_wave_soft_reset: 
	verdi -ssf wavesoft_reset.fsdb


# Make target to clean the compilation files
clean:
	rm -fr simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb* novas* verdi* vdCovLog
	clear


# Help prints all the available make targets
help:
	@echo "=============================================================================="
	@echo ""
	@echo "THIS IS THE MAKEFILE HELP"
	@echo ""
	@echo "run_test_top 		: Runs the base test and prints the topology"
	@echo "run_test_src_small 	: Runs the small packet test only on the source side"
	@echo "run_test_small 		: Runs the small packet test"
	@echo "run_test_medium 	: Runs the medium packet test"
	@echo "run_test_big 		: Runs the big packet test"
	@echo "run_test_smallvseq 	: Runs the small packet test on virtual sequence and virtual sequencers"
	@echo "run_test_mediumvseq 	: Runs the medium packet test on virtual sequence and virtual sequencers"
	@echo "run_test_bigvseq 	: Runs the big packet test on virtual sequence and virtual sequencers"
	@echo "regress 		: Runs the regression testing and merges the reports"
	@echo "cov 			: Show the coverage report on Verdi GUI"
	@echo "view_wave_top		: Shows the waveform of run_test_top"
	@echo "view_wave_src_small	: Shows the waveform of run_test_src_small"
	@echo "view_wave_small		: Shows the waveform of run_test_small"
	@echo "view_wave_medium	: Shows the waveform of run_test_medium"
	@echo "view_wave_big		: Shows the waveform of run_test_big"
	@echo "view_wave_soft_reset	: Shows the waveform of run_test_soft_reset"
	@echo "clean			: Clears the compilation and log files"
	@echo ""
	@echo "=============================================================================="

