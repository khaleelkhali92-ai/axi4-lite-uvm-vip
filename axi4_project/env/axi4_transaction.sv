class axi4_lite_transaction extends uvm_sequence_item;
  
    rand bit is_write;
  
    rand bit [11:0] addr;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;

    bit [31:0] rdata;
    bit [1:0]  bresp;
    bit [1:0]  rresp;

    constraint c_addr {
        addr inside {[12'h000:12'hFFF]};
    }

    
    constraint c_align {
        addr[1:0]==2'b00;
    }

 
    constraint c_wstrb {
      if(is_write==1'b1)
            wstrb!=4'b0000;
    }

    function new(string name="axi4_lite_transaction");
        super.new(name);
    endfunction


    `uvm_object_utils_begin(axi4_lite_transaction)

  `uvm_field_int(is_write,UVM_ALL_ON)
        `uvm_field_int(addr,UVM_ALL_ON)
        `uvm_field_int(wdata,UVM_ALL_ON)
        `uvm_field_int(wstrb,UVM_ALL_ON)
        `uvm_field_int(rdata,UVM_ALL_ON)
        `uvm_field_int(bresp,UVM_ALL_ON)
        `uvm_field_int(rresp,UVM_ALL_ON)

    `uvm_object_utils_end

endclass