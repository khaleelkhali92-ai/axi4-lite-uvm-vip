class axi_env extends uvm_env;
  axi_agent agt;
  axi4_lite_scoreboard sb;

  `uvm_component_utils(axi_env)

     function new(string name="axi_env",
                uvm_component parent=null);
      super.new(name,parent);
   endfunction


  function void build_phase(uvm_phase phase);
    agt = axi_agent::type_id::create("agt", this);
    sb  = axi4_lite_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agt.mon.mon_ap.connect(sb.analysis_export);
  endfunction
endclass
