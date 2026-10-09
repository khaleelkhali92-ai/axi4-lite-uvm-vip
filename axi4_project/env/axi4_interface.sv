interface axi4_lite_if #(parameter ADDR_WIDTH = 12,
                         parameter DATA_WIDTH = 32)
(
    input logic aclk,
    input logic aresetn
);

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;

    logic [DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;

    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;

    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic       rvalid;
    logic       rready;

    clocking drv_cb @(posedge aclk);

        default input #1 output #1;

        output awaddr;
        output awvalid;
        input  awready;

        output wdata;
        output wstrb;
        output wvalid;
        input  wready;

        input  bresp;
        input  bvalid;
        output bready;

        output araddr;
        output arvalid;
        input  arready;

        input  rdata;
        input  rresp;
        input  rvalid;
        output rready;

    endclocking

    clocking mon_cb @(posedge aclk);

        default input #1;

        input awaddr;
        input awvalid;
        input awready;

        input wdata;
        input wstrb;
        input wvalid;
        input wready;

        input bresp;
        input bvalid;
        input bready;

        input araddr;
        input arvalid;
        input arready;

        input rdata;
        input rresp;
        input rvalid;
        input rready;

    endclocking

    modport DRIVER  (clocking drv_cb, input aclk, input aresetn);

    modport MONITOR (clocking mon_cb, input aclk, input aresetn);

endinterface
