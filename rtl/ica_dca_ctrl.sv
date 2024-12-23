`include "bus.svh"

// ICA Image Control Area
// Configures during VBLANK

// DCA Dynamic Control Area
// Configures during HBLANK
// Limited to a maximum of 8 writes per line

//`define DEBUG
`define dp(statement) `ifdef DEBUG $display``statement `endif

module ica_dca_ctrl (
    input clk,
    input reset,
    output bit [21:0] address,
    output bit as,
    input [15:0] din,
    input bus_ack,

    //output burst,
    input burstdata_valid,

    input dca_read,
    input hblank,

    output [6:0] register_adr,
    output [23:0] register_data,
    output register_write,

    output reload_vsr,
    output [21:0] vsr,

    output bit irq,
    output display_parameters_s disp_params
);

    parameter bit unit_index = 0;
    localparam bit [21:0] odd_ica_start = 22'h400;
    localparam bit [21:0] even_ica_start = 22'h404;

    bit [21:0] ica_pointer;
    bit [21:0] dca_pointer;
    bit [21:0] next_line_dca_pointer;
    bit [3:0] dca_burst_cnt;
    bit [31:0] instruction;

    enum bit [3:0] {
        IDLE,
        ICA_READ0,
        ICA_READ1,
        ICA_WAIT_FOR_ACK,
        ICA_EXECUTE,
        DCA_READ0,
        DCA_READ1,
        DCA_READ2,
        DCA_READ3
    } state;

`ifdef VERILATOR
    string unit_name;
    initial begin
        $sformat(unit_name, "ICA%d", unit_index);
    end
`endif

    assign register_adr = instruction[30:24];
    assign register_data = instruction[23:0];
    assign register_write = execute_instruction && instruction[31];

    assign vsr = instruction[21:0];
    assign reload_vsr = (execute_instruction && instruction[31:28] == 5) || (execute_instruction && ica_ended && instruction[31:28] == 4);

    always_ff @(posedge clk) begin
        if (register_write)
            `dp(("%s Write %x %x %b", unit_name, {1'b1, register_adr
                }, register_data, register_data));
    end

    bit ica_ended;
    bit dca_active;

    bit execute_instruction;
    // A high level indicates a DCA access was not aligned on a 64 bit boundary
    // We need to ignore the second instruction of the first and last burst to
    // fix this. Also we need one additional burst
    bit dca_misaligned;


    always_ff @(posedge clk) begin
        irq <= 0;
        disp_params.strobe <= 0;
        execute_instruction <= 0;

        if (reset) begin
            ica_pointer <= odd_ica_start;
            as <= 0;
            state <= IDLE;
            ica_ended <= 0;
            dca_burst_cnt <= 0;
            dca_active <= 0;
            dca_misaligned <= 0;

            disp_params.cm <= 0;
            disp_params.mf1 <= 0;
            disp_params.mf2 <= 0;
            disp_params.ft1 <= 0;
            disp_params.ft2 <= 0;
            instruction <= 0;
        end else begin

            case (state)
                IDLE: begin
                    if (!ica_ended && !hblank) begin
                        state <= ICA_READ0;
                        address <= ica_pointer;
                        // Read one instruction of 4 byte
                        ica_pointer <= ica_pointer + 4;
                        `dp(("ICA%d Start reading at %x", unit_index, ica_pointer));
                        // check for alignment on 32 bit boundary
                        assert (ica_pointer[1:0] == 0);
                        as <= 1;
                    end else if (dca_read) begin
                        dca_active <= 1;
                        // ICA has ended. Wait for hblanks to
                        state <= DCA_READ0;
                        as <= 1;
                        address <= dca_pointer;
                        // check at least for alignment on 32 bit boundary
                        assert (dca_pointer[1:0] == 0);

                        if (dca_pointer[2]) begin
                            // This is bad. The access is not on a 64 bit boundary
                            // Only use the first 2 words on the first and last burst
                            // Also we need one more additional burst
                            dca_pointer <= dca_pointer + 4;
                            dca_burst_cnt <= 8;
                            dca_misaligned <= 1;
                        end else begin
                            // We need to read 16 instructions from DCA
                            // Always read in bursts of 4. This causes 2 instructions
                            // per burst.
                            // We need 8 bursts to complete the line
                            dca_pointer <= dca_pointer + 8;
                            dca_burst_cnt <= 7;
                            dca_misaligned <= 0;
                        end
                        $sformat(unit_name, "DCA%d", unit_index);
                        `dp(("DCA%d Start reading at %x", unit_index, dca_pointer));
                        next_line_dca_pointer <= dca_pointer + 8 * 8;
                    end
                end
                ICA_READ0: begin
                    if (burstdata_valid) begin
                        instruction[31:16] <= din;
                        state <= ICA_READ1;
                    end
                end
                ICA_READ1: begin
                    if (burstdata_valid) begin
                        instruction[15:0] <= din;
                        state <= ICA_WAIT_FOR_ACK;
                        execute_instruction <= 1;
                    end
                end
                ICA_WAIT_FOR_ACK: begin
                    if (bus_ack) begin
                        as <= 0;
                        state <= ICA_EXECUTE;
                    end
                end
                ICA_EXECUTE: begin
                    state <= IDLE;
                end
                DCA_READ0: begin
                    if (burstdata_valid) begin
                        instruction[31:16] <= din;
                        state <= DCA_READ1;
                    end
                end
                DCA_READ1: begin
                    if (burstdata_valid) begin
                        instruction[15:0] <= din;
                        state <= DCA_READ2;
                        execute_instruction <= dca_active;
                    end
                end
                DCA_READ2: begin
                    if (burstdata_valid) begin
                        instruction[31:16] <= din;
                        state <= DCA_READ3;
                    end
                end
                DCA_READ3: begin
                    if (burstdata_valid) begin
                        instruction[15:0] <= din;
                        if (dca_misaligned) begin
                            // With DCA not aligned on 64 bit boundary, we must throw away the second word of the first and
                            // the last burst
                            execute_instruction <= dca_active && dca_burst_cnt != 8 && dca_burst_cnt != 0;
                        end else begin
                            execute_instruction <= dca_active;
                        end

                        if (dca_burst_cnt == 8)
                            assert (dca_misaligned);  // check for the simulation
                    end

                    if (bus_ack) begin
                        if (dca_burst_cnt == 0 || !dca_active) begin
                            state <= IDLE;

                            dca_pointer <= next_line_dca_pointer;
                            dca_active <= 0;
                            as <= 0;
                        end else begin
                            state <= DCA_READ0;
                            as <= 1;
                            address <= dca_pointer;
                            // `dp(("DCA%d Continue reading at %x", unit_index, dca_pointer);

                            dca_pointer   <= dca_pointer + 8;
                            dca_burst_cnt <= dca_burst_cnt - 1;
                        end
                    end
                end


                default: begin
                end

            endcase



            if (execute_instruction) begin
                // `dp(("%s instruction %x", unit_name, instruction);

                case (instruction[31:28])
                    0: begin
                        // stop until next field
                        ica_ended <= 1;
                        `dp(("%s STOP", unit_name));

                        dca_active <= 0;
                    end
                    1: begin
                        // no operation
                        // `dp(("%s NOP", unit_name);
                    end
                    2: begin
                        // reload dcp
                        if (ica_ended) begin
                            `dp(("%s NOP (Reload DCP)", unit_name));
                        end else begin
                            dca_pointer <= instruction[21:0];
                            `dp(("%s Reload DCP %x", unit_name, instruction[21:0]));
                        end
                    end
                    3: begin
                        // reload dcp and stop
                        dca_pointer <= instruction[21:0];
                        next_line_dca_pointer <= instruction[21:0];
                        dca_active <= 0;
                        ica_ended <= 1;
                        `dp(("%s Reload DCP and STOP %x", unit_name, instruction[21:0]));
                    end
                    4: begin
                        // reload ica pointer
                        ica_pointer <= instruction[21:0];

                        if (ica_ended) `dp(("%s Reload VSR %x", unit_name, instruction[21:0]));
                        else `dp(("%s Reload ICA %x", unit_name, instruction[21:0]));
                    end
                    5: begin
                        // reload vsr pointer and stop
                        `dp(("%s Reload VSR and STOP %x", unit_name, instruction[21:0]));
                        ica_ended  <= 1;
                        dca_active <= 0;

                    end
                    6: begin
                        // interrupt
                        `dp(("%s INTERRUPT", unit_name));
                        irq <= 1;
                    end
                    7: begin
                        // reload display parameters
                        //assert(instruction[27]);
                        //assert(!instruction[5]);

                        if (instruction[27]) begin
                            disp_params.cm <= instruction[4];
                            disp_params.mf1 <= instruction[3];
                            disp_params.mf2 <= instruction[2];
                            disp_params.ft1 <= instruction[1];
                            disp_params.ft2 <= instruction[0];
                            disp_params.strobe <= 1;

                            `dp(("%s RELOAD DISPLAY PARAMETERS %b", unit_name, instruction[4:0]));
                        end

                    end
                    default: begin
                        // no command but probably a register write
                    end
                endcase
            end

        end
    end

endmodule
