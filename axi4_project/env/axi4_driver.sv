class axi4_lite_driver extends uvm_driver #(axi4_lite_transaction);

   `uvm_component_utils(axi4_lite_driver)

   virtual axi4_lite_if vif;

   axi4_lite_transaction tr;

   function new(string name="axi4_lite_driver",
                uvm_component parent=null);
      super.new(name,parent);
   endfunction


   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if(!uvm_config_db#(virtual axi4_lite_if)::get(this,"","vif",vif))
         `uvm_fatal(get_type_name(),"Virtual Interface Not Found")
   endfunction


task run_phase(uvm_phase phase);
        initialize_signals();

        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.is_write) begin
                drive_write(tr);
            end else begin
                drive_read(tr);
            end

            seq_item_port.item_done();
        end
    endtask


   task initialize_signals();

      vif.drv_cb.awvalid <= 0;
      vif.drv_cb.wvalid  <= 0;
      vif.drv_cb.bready  <= 0;

      vif.drv_cb.arvalid <= 0;
      vif.drv_cb.rready  <= 0;

      vif.drv_cb.awaddr  <= 0;
      vif.drv_cb.araddr  <= 0;
      vif.drv_cb.wdata   <= 0;
      vif.drv_cb.wstrb   <= 0;

      wait(vif.aresetn);

   endtask


   task drive_write(axi4_lite_transaction tr);

      fork

         begin

            @(vif.drv_cb);

            vif.drv_cb.awaddr  <= tr.addr;
            vif.drv_cb.awvalid <= 1;

            do @(vif.drv_cb);
            while(!vif.drv_cb.awready);

            vif.drv_cb.awvalid <= 0;

         end

         begin

            @(vif.drv_cb);

            vif.drv_cb.wdata  <= tr.wdata;
            vif.drv_cb.wstrb  <= tr.wstrb;
            vif.drv_cb.wvalid <= 1;

            do @(vif.drv_cb);
            while(!vif.drv_cb.wready);

            vif.drv_cb.wvalid <= 0;

         end

      join


      vif.drv_cb.bready <= 1;

      do @(vif.drv_cb);
      while(!vif.drv_cb.bvalid);

      tr.bresp = vif.drv_cb.bresp;

      @(vif.drv_cb);

      vif.drv_cb.bready <= 0;

      `uvm_info(get_type_name(),
                $sformatf("WRITE Completed Addr=%h Data=%h Resp=%0d",
                tr.addr,tr.wdata,tr.bresp),
                UVM_MEDIUM)

   endtask


   task drive_read(axi4_lite_transaction tr);

      @(vif.drv_cb);

      vif.drv_cb.araddr  <= tr.addr;
      vif.drv_cb.arvalid <= 1;

      do @(vif.drv_cb);
      while(!vif.drv_cb.arready);

      vif.drv_cb.arvalid <= 0;


      vif.drv_cb.rready <= 1;

      do @(vif.drv_cb);
      while(!vif.drv_cb.rvalid);

      tr.rdata = vif.drv_cb.rdata;
      tr.rresp = vif.drv_cb.rresp;

      @(vif.drv_cb);

      vif.drv_cb.rready <= 0;

      `uvm_info(get_type_name(),
                $sformatf("READ Completed Addr=%h Data=%h Resp=%0d",
                tr.addr,tr.rdata,tr.rresp),
                UVM_MEDIUM)

   endtask

endclass