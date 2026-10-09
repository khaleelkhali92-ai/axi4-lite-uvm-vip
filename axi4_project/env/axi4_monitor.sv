class axi4_lite_monitor extends uvm_monitor;

   `uvm_component_utils(axi4_lite_monitor)

   virtual axi4_lite_if vif;

   uvm_analysis_port #(axi4_lite_transaction) mon_ap;

   // Pending transactions
   axi4_lite_transaction wr_tr;
   axi4_lite_transaction rd_tr;

   function new(string name="axi4_lite_monitor",
                uvm_component parent=null);
      super.new(name,parent);
      mon_ap = new("mon_ap",this);
   endfunction

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      if(!uvm_config_db #(virtual axi4_lite_if)::get(this,"","vif",vif))
         `uvm_fatal(get_type_name(),"Virtual Interface Not Found")

   endfunction

   task run_phase(uvm_phase phase);

      forever begin

         @(posedge vif.aclk);

         if(vif.awvalid && vif.awready) begin

            wr_tr = axi4_lite_transaction::type_id::create("wr_tr");

            wr_tr.is_write   = 1;
            wr_tr.addr       = vif.awaddr;

         end

            if(vif.wvalid && vif.wready) begin

            if(wr_tr == null)
               `uvm_fatal("MONITOR",
                          "WDATA received before AWADDR")

            wr_tr.wdata = vif.wdata;
            wr_tr.wstrb = vif.wstrb;

         end

         if(vif.bvalid && vif.bready) begin

            if(wr_tr == null)
               `uvm_fatal("MONITOR",
                          "BRESP received without WRITE transaction")

            wr_tr.bresp = vif.bresp;

           mon_ap.write(wr_tr);

         `uvm_info(get_type_name(),
                   $sformatf("WRITE\n%s",
                             wr_tr.sprint()),
                   UVM_MEDIUM)

            wr_tr = null;

         end

         if(vif.arvalid && vif.arready) begin

            rd_tr = axi4_lite_transaction::type_id::create("rd_tr");

            rd_tr.is_write   = 0;
            rd_tr.addr       = vif.araddr;

         end


         if(vif.rvalid && vif.rready) begin

            if(rd_tr == null)
               `uvm_fatal("MONITOR",
                          "RDATA received without READ transaction")

            rd_tr.rdata = vif.rdata;
            rd_tr.rresp = vif.rresp;

            mon_ap.write(rd_tr);

            `uvm_info(get_type_name(),
                      $sformatf("READ\n%s",
                      rd_tr.sprint()),
                      UVM_MEDIUM)

            rd_tr = null;

         end

      end

   endtask

endclass