import uvm_pkg::*;
`include "uvm_macros.svh"
import axi_pkg::*;

class axi4_test extends uvm_test;

  axi_env env;

  `uvm_component_utils(axi4_test)

  function new(string name = "axi4_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = axi_env::type_id::create("env", this);

  endfunction


  task run_phase(uvm_phase phase);

    axi4_lite_write_seq write_seq;
    axi4_lite_read_seq read_seq;
    axi4_lite_slverr_seq slverr_seq;
    axi4_lite_read_slverr_seq rd_slverr_seq;
    axi4_lite_wstrb_seq wstrb_seq;

    phase.raise_objection(this);
    
    repeat(50) begin

    write_seq = axi4_lite_write_seq::type_id::create("write_seq");

    write_seq.start(env.agt.seqr);
    
    

    read_seq = axi4_lite_read_seq::type_id::create("read_seq");

    read_seq.start(env.agt.seqr);
      
    end


     slverr_seq = axi4_lite_slverr_seq::type_id::create("slverr_seq");

    slverr_seq.start(env.agt.seqr);
    
    rd_slverr_seq = axi4_lite_read_slverr_seq::type_id::create("rd_slverr_seq");

    rd_slverr_seq.start(env.agt.seqr);

     wstrb_seq = axi4_lite_wstrb_seq::type_id::create("wstrb_seq");

    wstrb_seq.start(env.agt.seqr);


    phase.drop_objection(this);

  endtask

endclass