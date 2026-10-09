`include "/home/dvft1207/axi4_project/rtl/design.sv"
`include "/home/dvft1207/axi4_project/env/axi4_interface.sv"
`include "/home/dvft1207/axi4_project/test/axi4_pkg.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

import axi_pkg::*;

module top;


   parameter ADDR_WIDTH = 12;
   parameter DATA_WIDTH = 32;


   logic aclk;
   logic aresetn;

   initial begin
      aclk = 0;
      forever #5 aclk = ~aclk;
   end

   initial begin
      aresetn = 0;
      #20;
      aresetn = 1;
   end


   axi4_lite_if #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) vif (
      .aclk(aclk),
      .aresetn(aresetn)
   );


   axi4_lite_slave #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) dut (

      .aclk(aclk),
      .aresetn(aresetn),

      // Write Address Channel
      .awaddr(vif.awaddr),
      .awvalid(vif.awvalid),
      .awready(vif.awready),

      // Write Data Channel
      .wdata(vif.wdata),
      .wstrb(vif.wstrb),
      .wvalid(vif.wvalid),
      .wready(vif.wready),

      // Write Response Channel
      .bresp(vif.bresp),
      .bvalid(vif.bvalid),
      .bready(vif.bready),

      // Read Address Channel
      .araddr(vif.araddr),
      .arvalid(vif.arvalid),
      .arready(vif.arready),

      // Read Data Channel
      .rdata(vif.rdata),
      .rresp(vif.rresp),
      .rvalid(vif.rvalid),
      .rready(vif.rready)

   );


   initial begin

      uvm_config_db#(virtual axi4_lite_if)::set(
         null,
         "*",
         "vif",
         vif
      );

      run_test("axi4_test");

   end

endmodule
