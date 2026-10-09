// Code your design here
// ============================================================================
// AXI4-Lite Slave Memory Module
// ============================================================================
// Description: Simple AXI4-Lite compliant memory slave with 4KB capacity
// Features:
//   - 4KB memory (1024 x 32-bit words)
//   - Single outstanding transaction
//   - Word-aligned access support
//   - Byte strobe support (WSTRB)
//   - 1-cycle read latency
//   - Protocol compliant responses
// ============================================================================

module axi4_lite_slave #(
    parameter ADDR_WIDTH = 12,  // 4KB address space
    parameter DATA_WIDTH = 32
) (
    // Global signals
    input  logic                      aclk,
    input  logic                      aresetn,
    
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]     awaddr,
    input  logic                      awvalid,
    output logic                      awready,
    
    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]     wdata,
    input  logic [(DATA_WIDTH/8)-1:0] wstrb,
    input  logic                      wvalid,
    output logic                      wready,
    
    // Write Response Channel
    output logic [1:0]                bresp,
    output logic                      bvalid,
    input  logic                      bready,
    
    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]     araddr,
    input  logic                      arvalid,
    output logic                      arready,
    
    // Read Data Channel
    output logic [DATA_WIDTH-1:0]     rdata,
    output logic [1:0]                rresp,
    output logic                      rvalid,
    input  logic                      rready
);

    // ========================================================================
    // Local Parameters
    // ========================================================================
    localparam MEM_DEPTH = 1024;  // 4KB / 4 bytes = 1024 words
    
    // AXI4 Response codes
    localparam [1:0] RESP_OKAY   = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;
    
    // ========================================================================
    // Internal Signals
    // ========================================================================
    logic [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];
    
    // Write channel state
    logic [ADDR_WIDTH-1:0] wr_addr_reg;
    logic                  wr_addr_valid;
    logic [DATA_WIDTH-1:0] wr_data_reg;
    logic [3:0]            wr_strb_reg;
    logic                  wr_data_valid;
    
    // Read channel state
    logic [ADDR_WIDTH-1:0] rd_addr_reg;
    logic                  rd_addr_valid;
    
    // Address decode
    logic [9:0]            wr_word_addr;
    logic [9:0]            rd_word_addr;
    logic                  wr_addr_error;
    logic                  rd_addr_error;
    
    // ========================================================================
    // Address Decoding & Error Checking
    // ========================================================================
    assign wr_word_addr  = wr_addr_reg[11:2];  // Word address (divide by 4)
    assign rd_word_addr  = rd_addr_reg[11:2];
    
    // Check for alignment errors and out-of-range
    assign wr_addr_error = (wr_addr_reg[1:0] != 2'b00) || 
                          (wr_word_addr >= MEM_DEPTH);
    
    assign rd_addr_error = (rd_addr_reg[1:0] != 2'b00) || 
                          (rd_word_addr >= MEM_DEPTH);
    
    // ========================================================================
    // Write Address Channel
    // ========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wr_addr_reg   <= '0;
            wr_addr_valid <= 1'b0;
            awready       <= 1'b0;
        end else begin
            awready <= 1'b0;  // Default
            
            // Capture write address when both valid and ready
            if (awvalid && !wr_addr_valid) begin
                wr_addr_reg   <= awaddr;
                wr_addr_valid <= 1'b1;
                awready       <= 1'b1;
            end
            
            // Clear when write completes
            if (wr_addr_valid && wr_data_valid) begin
                wr_addr_valid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Write Data Channel
    // ========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wr_data_reg   <= '0;
            wr_strb_reg   <= '0;
            wr_data_valid <= 1'b0;
            wready        <= 1'b0;
        end else begin
            wready <= 1'b0;  // Default
            
            // Capture write data when both valid and ready
            if (wvalid && !wr_data_valid) begin
                wr_data_reg   <= wdata;
                wr_strb_reg   <= wstrb;
                wr_data_valid <= 1'b1;
                wready        <= 1'b1;
            end
            
            // Clear when write completes
            if (wr_addr_valid && wr_data_valid) begin
                wr_data_valid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Memory Write Operation
    // ========================================================================
    always_ff @(posedge aclk) begin
        // Perform write when both address and data are valid
        if (wr_addr_valid && wr_data_valid && !wr_addr_error) begin
            // Byte-wise write using WSTRB
            if (wr_strb_reg[0]) memory[wr_word_addr][7:0]   <= wr_data_reg[7:0];
            if (wr_strb_reg[1]) memory[wr_word_addr][15:8]  <= wr_data_reg[15:8];
            if (wr_strb_reg[2]) memory[wr_word_addr][23:16] <= wr_data_reg[23:16];
            if (wr_strb_reg[3]) memory[wr_word_addr][31:24] <= wr_data_reg[31:24];
        end
    end
    
    // ========================================================================
    // Write Response Channel
    // ========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            bresp  <= RESP_OKAY;
            bvalid <= 1'b0;
        end else begin
            // Generate response when write completes
            if (wr_addr_valid && wr_data_valid && !bvalid) begin
                bresp  <= wr_addr_error ? RESP_SLVERR : RESP_OKAY;
                bvalid <= 1'b1;
            end
            
            // Clear response when master accepts it
            if (bvalid && bready) begin
                bvalid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Read Address Channel
    // ========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rd_addr_reg   <= '0;
            rd_addr_valid <= 1'b0;
            arready       <= 1'b0;
        end else begin
            arready <= 1'b0;  // Default
            
            // Capture read address when both valid and ready
            if (arvalid && !rd_addr_valid) begin
                rd_addr_reg   <= araddr;
                rd_addr_valid <= 1'b1;
                arready       <= 1'b1;
            end
            
            // Clear when read completes
            if (rd_addr_valid && rvalid && rready) begin
                rd_addr_valid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Read Data Channel
    // ========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rdata  <= '0;
            rresp  <= RESP_OKAY;
            rvalid <= 1'b0;
        end else begin
            // Generate read response when address is valid
            if (rd_addr_valid && !rvalid) begin
                if (rd_addr_error) begin
                    rdata  <= '0;
                    rresp  <= RESP_SLVERR;
                end else begin
                    rdata  <= memory[rd_word_addr];
                    rresp  <= RESP_OKAY;
                end
                rvalid <= 1'b1;
            end
            
            // Clear response when master accepts it
            if (rvalid && rready) begin
                rvalid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Assertions for Design Verification (Optional - can be disabled in synth)
    // ========================================================================
    `ifdef SIMULATION
    
    // Check for protocol violations
    property p_awvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> awvalid;
    endproperty
    assert property (p_awvalid_stable) 
        else $error("AWVALID deasserted before AWREADY");
    
    property p_wvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> wvalid;
    endproperty
    assert property (p_wvalid_stable) 
        else $error("WVALID deasserted before WREADY");
    
    property p_arvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> arvalid;
    endproperty
    assert property (p_arvalid_stable) 
        else $error("ARVALID deasserted before ARREADY");
    
    property p_bvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        bvalid && !bready |=> bvalid;
    endproperty
    assert property (p_bvalid_stable) 
        else $error("BVALID deasserted before BREADY");
    
    property p_rvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> rvalid;
    endproperty
    assert property (p_rvalid_stable) 
        else $error("RVALID deasserted before RREADY");
    
    `endif
    
endmodule

// ============================================================================
// AXI4-Lite Package with Type Definitions
// ============================================================================

package axi4_lite_pkg;
    
    // Transaction types
    typedef enum logic {
        AXI_READ  = 1'b0,
        AXI_WRITE = 1'b1
    } trans_type_e;
    
    // Response types
    typedef enum logic [1:0] {
        RESP_OKAY   = 2'b00,
        RESP_EXOKAY = 2'b01,  // Not used in AXI4-Lite
        RESP_SLVERR = 2'b10,
        RESP_DECERR = 2'b11
    } resp_type_e;
    
    // Address and data widths
    parameter int ADDR_WIDTH = 12;
    parameter int DATA_WIDTH = 32;
    parameter int STRB_WIDTH = DATA_WIDTH / 8;
    
endpackage : axi4_lite_pkg