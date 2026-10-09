class axi4_lite_base_seq extends uvm_sequence #(axi4_lite_transaction);

    `uvm_object_utils(axi4_lite_base_seq)

    function new(string name="axi4_lite_base_seq");
        super.new(name);
    endfunction

endclass


class axi4_lite_write_seq extends axi4_lite_base_seq;

    `uvm_object_utils(axi4_lite_write_seq)

    function new(string name="axi4_lite_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        axi4_lite_transaction tx;

        tx = axi4_lite_transaction::type_id::create("tx");

        start_item(tx);

        assert(tx.randomize() with
        {
            is_write == 1;

            addr[1:0] == 2'b00;

            wstrb inside
            {
                4'b0001,
                4'b0010,
                4'b0100,
                4'b1000,
                4'b0011,
                4'b1100,
                4'b1111
            };
        });

        finish_item(tx);

        `uvm_info(get_type_name(),
                  $sformatf("Generated WRITE Transaction\n%s",
                  tx.convert2string()),
                  UVM_MEDIUM)

    endtask

endclass



class axi4_lite_read_seq extends axi4_lite_base_seq;

    `uvm_object_utils(axi4_lite_read_seq)

    function new(string name="axi4_lite_read_seq");
        super.new(name);
    endfunction

    virtual task body();

        axi4_lite_transaction tx;

        tx = axi4_lite_transaction::type_id::create("tx");

        start_item(tx);

        assert(tx.randomize() with
        {
            is_write == 0;

            addr[1:0] == 2'b00;
        });

        finish_item(tx);

        `uvm_info(get_type_name(),
                  $sformatf("Generated READ Transaction\n%s",
                  tx.convert2string()),
                  UVM_MEDIUM)

    endtask

endclass



class axi4_lite_slverr_seq extends axi4_lite_base_seq;

   `uvm_object_utils(axi4_lite_slverr_seq)

   function new(string name = "axi4_lite_slverr_seq");
      super.new(name);
   endfunction

   task body();

      req = axi4_lite_transaction::type_id::create("req");

      start_item(req);

      req.is_write=1;

      // Invalid address to generate SLVERR
      req.addr  = 12'h001;

      req.wdata = 32'hDEADBEEF;

      req.wstrb = 4'hF;

      finish_item(req);

      `uvm_info(get_type_name(),
                 $sformatf("Generated SLVERR Transaction\n%s",
                           req.sprint()), 
                 UVM_MEDIUM)

   endtask

endclass
      
      
class axi4_lite_read_slverr_seq extends axi4_lite_base_seq;
    `uvm_object_utils(axi4_lite_read_slverr_seq)

    function new(string name = "axi4_lite_read_slverr_seq");
       super.new(name);
    endfunction

    task body();
       req = axi4_lite_transaction::type_id::create("req");
       start_item(req);

       req.is_write = 0;      
       req.addr     = 12'h003;

       finish_item(req);

       `uvm_info(get_type_name(), $sformatf("Generated READ SLVERR\n%s", req.sprint()), UVM_MEDIUM)
    endtask
endclass


class axi4_lite_wstrb_seq extends axi4_lite_base_seq;

   `uvm_object_utils(axi4_lite_wstrb_seq)

   function new(string name = "axi4_lite_wstrb_seq");
      super.new(name);
   endfunction

   task body();

      // BYTE0
      send_wstrb_transaction(12'h100, 32'hAABBCCDD, 4'b0001);

      // BYTE1
      send_wstrb_transaction(12'h104, 32'h11223344, 4'b0010);

      // BYTE2
      send_wstrb_transaction(12'h108, 32'h55667788, 4'b0100);

      // BYTE3
      send_wstrb_transaction(12'h10C, 32'h99AABBCC, 4'b1000);

      // LOW 2 bytes
      send_wstrb_transaction(12'h110, 32'hDEADBEEF, 4'b0011);

      // HIGH 2 bytes
      send_wstrb_transaction(12'h114, 32'hCAFEBABE, 4'b1100);

      // ALL bytes
      send_wstrb_transaction(12'h118, 32'h12345678, 4'b1111);

   endtask


   task send_wstrb_transaction(
      bit [11:0] addr,
      bit [31:0] data,
      bit [3:0]  strb
   );

      req = axi4_lite_transaction::type_id::create("req");

      start_item(req);

      req.is_write   =1;
      req.addr       = addr;
      req.wdata      = data;
      req.wstrb      = strb;

      finish_item(req);

      `uvm_info(get_type_name(),
                $sformatf("WSTRB TEST: ADDR=%03h DATA=%08h WSTRB=%04b",
                          addr, data, strb),
                UVM_MEDIUM)

   endtask

endclass