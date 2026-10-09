class axi_agent extends uvm_component;
  axi4_lite_driver drv;
  axi4_lite_monitor mon;
  axi4_lite_sequencer seqr;

  `uvm_component_utils(axi_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    drv  = axi4_lite_driver::type_id::create("drv", this);
    mon  = axi4_lite_monitor::type_id::create("mon", this);
    seqr = axi4_lite_sequencer::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
