// SPDX-FileCopyrightText: 2025 Open Circuit Design, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
//
// Caravel harness chip original copyright 2020 Efabless Corporation

module caravel_padframe (
`ifdef USE_POWER_PINS
	// Power buses
        inout  vddio_pad,               // Common padframe/ESD supply
        inout  vddio_pad2,
        inout  vssio_pad,               // Common padframe/ESD ground
        inout  vssio_pad2,
        inout  vccd_pad,                // Common 1.8V supply
        inout  vssd_pad,                // Common digital ground
        inout  vdda_pad,                // Management analog 3.3V supply
        inout  vssa_pad,                // Management analog ground
        inout  vdda1_pad,               // User area 1 3.3V supply
        inout  vdda1_pad2,
        inout  vdda2_pad,               // User area 2 3.3V supply
        inout  vssa1_pad,               // User area 1 analog ground
        inout  vssa1_pad2,
        inout  vssa2_pad,               // User area 2 analog ground
        inout  vccd1_pad,               // User area 1 1.8V supply
        inout  vccd2_pad,               // User area 2 1.8V supply
        inout  vssd1_pad,               // User area 1 digital ground
        inout  vssd2_pad,               // User area 2 digital ground

        // Core Side
        inout  vddio,           // Common padframe/ESD supply
        inout  vssio,           // Common padframe/ESD ground
        inout  vccd,            // Common 1.8V supply
        inout  vssd,            // Common digital ground
        inout  vdda,            // Management analog 3.3V supply
        inout  vssa,            // Management analog ground
        inout  vdda1,           // User area 1 3.3V supply
        inout  vdda2,           // User area 2 3.3V supply
        inout  vssa1,           // User area 1 analog ground
        inout  vssa2,           // User area 2 analog ground
        inout  vccd1,           // User area 1 1.8V supply
        inout  vccd2,           // User area 2 1.8V supply
        inout  vssd1,           // User area 1 digital ground
        inout  vssd2,           // User area 2 digital ground
`endif

	inout  gpio,
	input  clock,
	input  resetb,
	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,

	// Chip Core Interface
	output resetb_core,
	output clock_core,
	output gpio_in_core,
	input  gpio_out_core,
	input  gpio_outen_core,
	input  gpio_inen_core,
	input  gpio_pu_select,
	input  gpio_pd_select,
	input  gpio_schmitt_select,
	input  gpio_slew_select,
	input  [1:0] gpio_drive_select_core,
	input  flash_csb_core,
	input  flash_clk_core,
	input  flash_csb_oe_core,
	input  flash_clk_oe_core,
	input  flash_io0_oe_core,
	input  flash_io1_oe_core,
	input  flash_io0_ie_core,
	input  flash_io1_ie_core,
	input  flash_io0_do_core,
	input  flash_io1_do_core,
	output flash_io0_di_core,
	output flash_io1_di_core,

	// Constant value inputs for fixed GPIO configuration
	input [5:0] const_zero,
	input [1:0] const_one,

	// User project IOs
	inout [`PROJECT_IO_PADS-1:0] project_io,
	input [`PROJECT_IO_PADS-1:0] project_io_out,
	input [`PROJECT_IO_PADS-1:0] project_io_outen,
	input [`PROJECT_IO_PADS-1:0] project_io_inen,
	input [`PROJECT_IO_PADS-1:0] project_io_schmitt_select,
	input [`PROJECT_IO_PADS-1:0] project_io_slew_select,
	input [`PROJECT_IO_PADS-1:0] project_io_pu_select,
	input [`PROJECT_IO_PADS-1:0] project_io_pd_select,
	input [`PROJECT_IO_PADS*2-1:0] project_io_drive_sel,
	output [`PROJECT_IO_PADS-1:0] project_io_in
);

	// Instantiate power and ground pads for management domain
	// 12 pads:  vddio, vssio, vdda, vssa, vccd, vssd correspond
	// to names used with sky130, with multiple voltages for each
	// domain.  The instance names reflect where these pads
	// match the position of corresponding pads on the sky130
	// caravel.
	//
	// Note that the ground domains in the gf180mcu_ocd_io cell
	// library are only virtually separated by "isosub" marker
	// layers.

    	gf180mcu_ocd_io__dvdd mgmt_vddio_pad_0 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	// lies in user area---Does not belong to management domain
	// like it does on the Sky130 version.
    	gf180mcu_ocd_io__dvdd mgmt_vddio_pad_1 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvdd mgmt_vdda_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__vdd mgmt_vccd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvss mgmt_vssio_pad_0 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvss mgmt_vssio_pad_1 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvss mgmt_vssa_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__vss mgmt_vssd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	// Instantiate power and ground pads for user 1 domain
	// 8 pads:  vdda, vssa, vccd, vssd;  One each HV and LV clamp.

    	gf180mcu_ocd_io__dvdd user1_vdda_pad_0 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	gf180mcu_ocd_io__dvdd user1_vdda_pad_1 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__vdd user1_vccd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvss user1_vssa_pad_0 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);


    	gf180mcu_ocd_io__dvss user1_vssa_pad_1 (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__vss user1_vssd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	// Instantiate power and ground pads for user 2 domain
	// 8 pads:  vdda, vssa, vccd, vssd;  One each HV and LV clamp.

    	gf180mcu_ocd_io__dvdd user2_vdda_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__vdd user2_vccd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

    	gf180mcu_ocd_io__dvss user2_vssa_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
    	);

    	gf180mcu_ocd_io__vss user2_vssd_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	// Management clock input pad
	gf180mcu_ocd_io__in_c mgmt_clock_input_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PU(const_zero[4]),
		.PD(const_zero[4]),
		.PAD(clock),
		.Y(clock_core)
	);

	// Management GPIO pad
	gf180mcu_ocd_io__bi_t mgmt_gpio_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PAD(gpio),
		.CS(gpio_schmitt_select),
		.SL(gpio_slew_select),
		.IE(gpio_inen_core),
		.OE(gpio_outen_core),
		.PU(gpio_pu_select),
		.PD(gpio_pd_select),
		.PDRV0(gpio_drive_select_core[0]),
		.PDRV1(gpio_drive_select_core[1]),
		.A(gpio_out_core),
		.Y(gpio_in_core)
	);

	// Management Flash SPI pads
	gf180mcu_ocd_io__bi_t flash_io0_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PAD(flash_io0),
		.CS(const_zero[1]),
		.SL(const_zero[1]),
		.IE(flash_io0_ie_core),
		.OE(flash_io0_oe_core),
		.PU(const_zero[1]),
		.PD(const_zero[1]),
		.PDRV0(const_zero[1]),
		.PDRV1(const_zero[1]),
		.A(flash_io0_do_core),
		.Y(flash_io0_di_core)
	);
	
	gf180mcu_ocd_io__bi_t flash_io1_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PAD(flash_io1),
		.CS(const_zero[0]),
		.SL(const_zero[0]),
		.IE(flash_io1_ie_core),
		.OE(flash_io1_oe_core),
		.PU(const_zero[0]),
		.PD(const_zero[0]),
		.PDRV0(const_zero[0]),
		.PDRV1(const_zero[0]),
		.A(flash_io1_do_core),
		.Y(flash_io1_di_core)
	);

	gf180mcu_ocd_io__bi_t flash_csb_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PAD(flash_csb),
		.CS(const_zero[3]),
		.SL(const_zero[3]),
		.IE(const_zero[3]),
		.OE(flash_csb_oe_core),
		.PU(const_one[1]),
		.PD(const_zero[3]),
		.PDRV0(const_zero[3]),
		.PDRV1(const_zero[3]),
		.A(flash_csb_core),
		.Y()
	);

	gf180mcu_ocd_io__bi_t flash_clk_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PAD(flash_clk),
		.CS(const_zero[2]),
		.SL(const_zero[2]),
		.IE(const_zero[2]),
		.OE(flash_clk_oe_core),
		.PU(const_zero[2]),
		.PD(const_zero[2]),
		.PDRV0(const_zero[2]),
		.PDRV1(const_zero[2]),
		.A(flash_clk_core),
		.Y()
	);

	// NOTE:  Resetb is active low and is configured as a pull-up

	gf180mcu_ocd_io__in_s resetb_pad (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
		.PU(const_one[0]),
		.PD(const_zero[5]),
		.PAD(resetb),
		.Y(resetb_core)
	);

	// Corner cells (These are overlay cells;  it is not clear what is normally
    	// supposed to go under them.)

	gf180mcu_ocd_io__cor mgmt_corner [1:0] (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
	);

	gf180mcu_ocd_io__cor user1_corner (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	gf180mcu_ocd_io__cor user2_corner (
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd)
    	);

	// generated by running ./scripts/update_chip_io_rtl.py then copying ./scripts/chip_io.txt and pasting here
	gf180mcu_ocd_io__bi_t \project_pads[0]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[0]),
		.CS(project_io_schmitt_select[0]),
		.SL(project_io_slew_select[0]),
		.IE(project_io_inen[0]),
		.OE(project_io_outen[0]),
		.PU(project_io_pu_select[0]),
		.PD(project_io_pd_select[0]),
		.PDRV0(project_io_drive_sel[0]),
		.PDRV1(project_io_drive_sel[1]),
		.A(project_io_out[0]),
		.Y(project_io_in[0])
	);
	gf180mcu_ocd_io__bi_t \project_pads[1]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[1]),
		.CS(project_io_schmitt_select[1]),
		.SL(project_io_slew_select[1]),
		.IE(project_io_inen[1]),
		.OE(project_io_outen[1]),
		.PU(project_io_pu_select[1]),
		.PD(project_io_pd_select[1]),
		.PDRV0(project_io_drive_sel[2]),
		.PDRV1(project_io_drive_sel[3]),
		.A(project_io_out[1]),
		.Y(project_io_in[1])
	);
	gf180mcu_ocd_io__bi_t \project_pads[2]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[2]),
		.CS(project_io_schmitt_select[2]),
		.SL(project_io_slew_select[2]),
		.IE(project_io_inen[2]),
		.OE(project_io_outen[2]),
		.PU(project_io_pu_select[2]),
		.PD(project_io_pd_select[2]),
		.PDRV0(project_io_drive_sel[4]),
		.PDRV1(project_io_drive_sel[5]),
		.A(project_io_out[2]),
		.Y(project_io_in[2])
	);
	gf180mcu_ocd_io__bi_t \project_pads[3]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[3]),
		.CS(project_io_schmitt_select[3]),
		.SL(project_io_slew_select[3]),
		.IE(project_io_inen[3]),
		.OE(project_io_outen[3]),
		.PU(project_io_pu_select[3]),
		.PD(project_io_pd_select[3]),
		.PDRV0(project_io_drive_sel[6]),
		.PDRV1(project_io_drive_sel[7]),
		.A(project_io_out[3]),
		.Y(project_io_in[3])
	);
	gf180mcu_ocd_io__bi_t \project_pads[4]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[4]),
		.CS(project_io_schmitt_select[4]),
		.SL(project_io_slew_select[4]),
		.IE(project_io_inen[4]),
		.OE(project_io_outen[4]),
		.PU(project_io_pu_select[4]),
		.PD(project_io_pd_select[4]),
		.PDRV0(project_io_drive_sel[8]),
		.PDRV1(project_io_drive_sel[9]),
		.A(project_io_out[4]),
		.Y(project_io_in[4])
	);
	gf180mcu_ocd_io__bi_t \project_pads[5]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[5]),
		.CS(project_io_schmitt_select[5]),
		.SL(project_io_slew_select[5]),
		.IE(project_io_inen[5]),
		.OE(project_io_outen[5]),
		.PU(project_io_pu_select[5]),
		.PD(project_io_pd_select[5]),
		.PDRV0(project_io_drive_sel[10]),
		.PDRV1(project_io_drive_sel[11]),
		.A(project_io_out[5]),
		.Y(project_io_in[5])
	);
	gf180mcu_ocd_io__bi_t \project_pads[6]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[6]),
		.CS(project_io_schmitt_select[6]),
		.SL(project_io_slew_select[6]),
		.IE(project_io_inen[6]),
		.OE(project_io_outen[6]),
		.PU(project_io_pu_select[6]),
		.PD(project_io_pd_select[6]),
		.PDRV0(project_io_drive_sel[12]),
		.PDRV1(project_io_drive_sel[13]),
		.A(project_io_out[6]),
		.Y(project_io_in[6])
	);
	gf180mcu_ocd_io__bi_t \project_pads[7]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[7]),
		.CS(project_io_schmitt_select[7]),
		.SL(project_io_slew_select[7]),
		.IE(project_io_inen[7]),
		.OE(project_io_outen[7]),
		.PU(project_io_pu_select[7]),
		.PD(project_io_pd_select[7]),
		.PDRV0(project_io_drive_sel[14]),
		.PDRV1(project_io_drive_sel[15]),
		.A(project_io_out[7]),
		.Y(project_io_in[7])
	);
	gf180mcu_ocd_io__bi_t \project_pads[8]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[8]),
		.CS(project_io_schmitt_select[8]),
		.SL(project_io_slew_select[8]),
		.IE(project_io_inen[8]),
		.OE(project_io_outen[8]),
		.PU(project_io_pu_select[8]),
		.PD(project_io_pd_select[8]),
		.PDRV0(project_io_drive_sel[16]),
		.PDRV1(project_io_drive_sel[17]),
		.A(project_io_out[8]),
		.Y(project_io_in[8])
	);
	gf180mcu_ocd_io__bi_t \project_pads[9]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[9]),
		.CS(project_io_schmitt_select[9]),
		.SL(project_io_slew_select[9]),
		.IE(project_io_inen[9]),
		.OE(project_io_outen[9]),
		.PU(project_io_pu_select[9]),
		.PD(project_io_pd_select[9]),
		.PDRV0(project_io_drive_sel[18]),
		.PDRV1(project_io_drive_sel[19]),
		.A(project_io_out[9]),
		.Y(project_io_in[9])
	);
	gf180mcu_ocd_io__bi_t \project_pads[10]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[10]),
		.CS(project_io_schmitt_select[10]),
		.SL(project_io_slew_select[10]),
		.IE(project_io_inen[10]),
		.OE(project_io_outen[10]),
		.PU(project_io_pu_select[10]),
		.PD(project_io_pd_select[10]),
		.PDRV0(project_io_drive_sel[20]),
		.PDRV1(project_io_drive_sel[21]),
		.A(project_io_out[10]),
		.Y(project_io_in[10])
	);
	gf180mcu_ocd_io__bi_t \project_pads[11]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[11]),
		.CS(project_io_schmitt_select[11]),
		.SL(project_io_slew_select[11]),
		.IE(project_io_inen[11]),
		.OE(project_io_outen[11]),
		.PU(project_io_pu_select[11]),
		.PD(project_io_pd_select[11]),
		.PDRV0(project_io_drive_sel[22]),
		.PDRV1(project_io_drive_sel[23]),
		.A(project_io_out[11]),
		.Y(project_io_in[11])
	);
	gf180mcu_ocd_io__bi_t \project_pads[12]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[12]),
		.CS(project_io_schmitt_select[12]),
		.SL(project_io_slew_select[12]),
		.IE(project_io_inen[12]),
		.OE(project_io_outen[12]),
		.PU(project_io_pu_select[12]),
		.PD(project_io_pd_select[12]),
		.PDRV0(project_io_drive_sel[24]),
		.PDRV1(project_io_drive_sel[25]),
		.A(project_io_out[12]),
		.Y(project_io_in[12])
	);
	gf180mcu_ocd_io__bi_t \project_pads[13]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[13]),
		.CS(project_io_schmitt_select[13]),
		.SL(project_io_slew_select[13]),
		.IE(project_io_inen[13]),
		.OE(project_io_outen[13]),
		.PU(project_io_pu_select[13]),
		.PD(project_io_pd_select[13]),
		.PDRV0(project_io_drive_sel[26]),
		.PDRV1(project_io_drive_sel[27]),
		.A(project_io_out[13]),
		.Y(project_io_in[13])
	);
	gf180mcu_ocd_io__bi_t \project_pads[14]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[14]),
		.CS(project_io_schmitt_select[14]),
		.SL(project_io_slew_select[14]),
		.IE(project_io_inen[14]),
		.OE(project_io_outen[14]),
		.PU(project_io_pu_select[14]),
		.PD(project_io_pd_select[14]),
		.PDRV0(project_io_drive_sel[28]),
		.PDRV1(project_io_drive_sel[29]),
		.A(project_io_out[14]),
		.Y(project_io_in[14])
	);
	gf180mcu_ocd_io__bi_t \project_pads[15]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[15]),
		.CS(project_io_schmitt_select[15]),
		.SL(project_io_slew_select[15]),
		.IE(project_io_inen[15]),
		.OE(project_io_outen[15]),
		.PU(project_io_pu_select[15]),
		.PD(project_io_pd_select[15]),
		.PDRV0(project_io_drive_sel[30]),
		.PDRV1(project_io_drive_sel[31]),
		.A(project_io_out[15]),
		.Y(project_io_in[15])
	);
	gf180mcu_ocd_io__bi_t \project_pads[16]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[16]),
		.CS(project_io_schmitt_select[16]),
		.SL(project_io_slew_select[16]),
		.IE(project_io_inen[16]),
		.OE(project_io_outen[16]),
		.PU(project_io_pu_select[16]),
		.PD(project_io_pd_select[16]),
		.PDRV0(project_io_drive_sel[32]),
		.PDRV1(project_io_drive_sel[33]),
		.A(project_io_out[16]),
		.Y(project_io_in[16])
	);
	gf180mcu_ocd_io__bi_t \project_pads[17]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[17]),
		.CS(project_io_schmitt_select[17]),
		.SL(project_io_slew_select[17]),
		.IE(project_io_inen[17]),
		.OE(project_io_outen[17]),
		.PU(project_io_pu_select[17]),
		.PD(project_io_pd_select[17]),
		.PDRV0(project_io_drive_sel[34]),
		.PDRV1(project_io_drive_sel[35]),
		.A(project_io_out[17]),
		.Y(project_io_in[17])
	);
	gf180mcu_ocd_io__bi_t \project_pads[18]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[18]),
		.CS(project_io_schmitt_select[18]),
		.SL(project_io_slew_select[18]),
		.IE(project_io_inen[18]),
		.OE(project_io_outen[18]),
		.PU(project_io_pu_select[18]),
		.PD(project_io_pd_select[18]),
		.PDRV0(project_io_drive_sel[36]),
		.PDRV1(project_io_drive_sel[37]),
		.A(project_io_out[18]),
		.Y(project_io_in[18])
	);
	gf180mcu_ocd_io__bi_t \project_pads[19]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[19]),
		.CS(project_io_schmitt_select[19]),
		.SL(project_io_slew_select[19]),
		.IE(project_io_inen[19]),
		.OE(project_io_outen[19]),
		.PU(project_io_pu_select[19]),
		.PD(project_io_pd_select[19]),
		.PDRV0(project_io_drive_sel[38]),
		.PDRV1(project_io_drive_sel[39]),
		.A(project_io_out[19]),
		.Y(project_io_in[19])
	);
	gf180mcu_ocd_io__bi_t \project_pads[20]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[20]),
		.CS(project_io_schmitt_select[20]),
		.SL(project_io_slew_select[20]),
		.IE(project_io_inen[20]),
		.OE(project_io_outen[20]),
		.PU(project_io_pu_select[20]),
		.PD(project_io_pd_select[20]),
		.PDRV0(project_io_drive_sel[40]),
		.PDRV1(project_io_drive_sel[41]),
		.A(project_io_out[20]),
		.Y(project_io_in[20])
	);
	gf180mcu_ocd_io__bi_t \project_pads[21]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[21]),
		.CS(project_io_schmitt_select[21]),
		.SL(project_io_slew_select[21]),
		.IE(project_io_inen[21]),
		.OE(project_io_outen[21]),
		.PU(project_io_pu_select[21]),
		.PD(project_io_pd_select[21]),
		.PDRV0(project_io_drive_sel[42]),
		.PDRV1(project_io_drive_sel[43]),
		.A(project_io_out[21]),
		.Y(project_io_in[21])
	);
	gf180mcu_ocd_io__bi_t \project_pads[22]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[22]),
		.CS(project_io_schmitt_select[22]),
		.SL(project_io_slew_select[22]),
		.IE(project_io_inen[22]),
		.OE(project_io_outen[22]),
		.PU(project_io_pu_select[22]),
		.PD(project_io_pd_select[22]),
		.PDRV0(project_io_drive_sel[44]),
		.PDRV1(project_io_drive_sel[45]),
		.A(project_io_out[22]),
		.Y(project_io_in[22])
	);
	gf180mcu_ocd_io__bi_t \project_pads[23]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[23]),
		.CS(project_io_schmitt_select[23]),
		.SL(project_io_slew_select[23]),
		.IE(project_io_inen[23]),
		.OE(project_io_outen[23]),
		.PU(project_io_pu_select[23]),
		.PD(project_io_pd_select[23]),
		.PDRV0(project_io_drive_sel[46]),
		.PDRV1(project_io_drive_sel[47]),
		.A(project_io_out[23]),
		.Y(project_io_in[23])
	);
	gf180mcu_ocd_io__bi_t \project_pads[24]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[24]),
		.CS(project_io_schmitt_select[24]),
		.SL(project_io_slew_select[24]),
		.IE(project_io_inen[24]),
		.OE(project_io_outen[24]),
		.PU(project_io_pu_select[24]),
		.PD(project_io_pd_select[24]),
		.PDRV0(project_io_drive_sel[48]),
		.PDRV1(project_io_drive_sel[49]),
		.A(project_io_out[24]),
		.Y(project_io_in[24])
	);
	gf180mcu_ocd_io__bi_t \project_pads[25]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[25]),
		.CS(project_io_schmitt_select[25]),
		.SL(project_io_slew_select[25]),
		.IE(project_io_inen[25]),
		.OE(project_io_outen[25]),
		.PU(project_io_pu_select[25]),
		.PD(project_io_pd_select[25]),
		.PDRV0(project_io_drive_sel[50]),
		.PDRV1(project_io_drive_sel[51]),
		.A(project_io_out[25]),
		.Y(project_io_in[25])
	);
	gf180mcu_ocd_io__bi_t \project_pads[26]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[26]),
		.CS(project_io_schmitt_select[26]),
		.SL(project_io_slew_select[26]),
		.IE(project_io_inen[26]),
		.OE(project_io_outen[26]),
		.PU(project_io_pu_select[26]),
		.PD(project_io_pd_select[26]),
		.PDRV0(project_io_drive_sel[52]),
		.PDRV1(project_io_drive_sel[53]),
		.A(project_io_out[26]),
		.Y(project_io_in[26])
	);
	gf180mcu_ocd_io__bi_t \project_pads[27]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[27]),
		.CS(project_io_schmitt_select[27]),
		.SL(project_io_slew_select[27]),
		.IE(project_io_inen[27]),
		.OE(project_io_outen[27]),
		.PU(project_io_pu_select[27]),
		.PD(project_io_pd_select[27]),
		.PDRV0(project_io_drive_sel[54]),
		.PDRV1(project_io_drive_sel[55]),
		.A(project_io_out[27]),
		.Y(project_io_in[27])
	);
	gf180mcu_ocd_io__bi_t \project_pads[28]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[28]),
		.CS(project_io_schmitt_select[28]),
		.SL(project_io_slew_select[28]),
		.IE(project_io_inen[28]),
		.OE(project_io_outen[28]),
		.PU(project_io_pu_select[28]),
		.PD(project_io_pd_select[28]),
		.PDRV0(project_io_drive_sel[56]),
		.PDRV1(project_io_drive_sel[57]),
		.A(project_io_out[28]),
		.Y(project_io_in[28])
	);
	gf180mcu_ocd_io__bi_t \project_pads[29]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[29]),
		.CS(project_io_schmitt_select[29]),
		.SL(project_io_slew_select[29]),
		.IE(project_io_inen[29]),
		.OE(project_io_outen[29]),
		.PU(project_io_pu_select[29]),
		.PD(project_io_pd_select[29]),
		.PDRV0(project_io_drive_sel[58]),
		.PDRV1(project_io_drive_sel[59]),
		.A(project_io_out[29]),
		.Y(project_io_in[29])
	);
	gf180mcu_ocd_io__bi_t \project_pads[30]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[30]),
		.CS(project_io_schmitt_select[30]),
		.SL(project_io_slew_select[30]),
		.IE(project_io_inen[30]),
		.OE(project_io_outen[30]),
		.PU(project_io_pu_select[30]),
		.PD(project_io_pd_select[30]),
		.PDRV0(project_io_drive_sel[60]),
		.PDRV1(project_io_drive_sel[61]),
		.A(project_io_out[30]),
		.Y(project_io_in[30])
	);
	gf180mcu_ocd_io__bi_t \project_pads[31]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[31]),
		.CS(project_io_schmitt_select[31]),
		.SL(project_io_slew_select[31]),
		.IE(project_io_inen[31]),
		.OE(project_io_outen[31]),
		.PU(project_io_pu_select[31]),
		.PD(project_io_pd_select[31]),
		.PDRV0(project_io_drive_sel[62]),
		.PDRV1(project_io_drive_sel[63]),
		.A(project_io_out[31]),
		.Y(project_io_in[31])
	);
	gf180mcu_ocd_io__bi_t \project_pads[32]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[32]),
		.CS(project_io_schmitt_select[32]),
		.SL(project_io_slew_select[32]),
		.IE(project_io_inen[32]),
		.OE(project_io_outen[32]),
		.PU(project_io_pu_select[32]),
		.PD(project_io_pd_select[32]),
		.PDRV0(project_io_drive_sel[64]),
		.PDRV1(project_io_drive_sel[65]),
		.A(project_io_out[32]),
		.Y(project_io_in[32])
	);
	gf180mcu_ocd_io__bi_t \project_pads[33]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[33]),
		.CS(project_io_schmitt_select[33]),
		.SL(project_io_slew_select[33]),
		.IE(project_io_inen[33]),
		.OE(project_io_outen[33]),
		.PU(project_io_pu_select[33]),
		.PD(project_io_pd_select[33]),
		.PDRV0(project_io_drive_sel[66]),
		.PDRV1(project_io_drive_sel[67]),
		.A(project_io_out[33]),
		.Y(project_io_in[33])
	);
	gf180mcu_ocd_io__bi_t \project_pads[34]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[34]),
		.CS(project_io_schmitt_select[34]),
		.SL(project_io_slew_select[34]),
		.IE(project_io_inen[34]),
		.OE(project_io_outen[34]),
		.PU(project_io_pu_select[34]),
		.PD(project_io_pd_select[34]),
		.PDRV0(project_io_drive_sel[68]),
		.PDRV1(project_io_drive_sel[69]),
		.A(project_io_out[34]),
		.Y(project_io_in[34])
	);
	gf180mcu_ocd_io__bi_t \project_pads[35]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[35]),
		.CS(project_io_schmitt_select[35]),
		.SL(project_io_slew_select[35]),
		.IE(project_io_inen[35]),
		.OE(project_io_outen[35]),
		.PU(project_io_pu_select[35]),
		.PD(project_io_pd_select[35]),
		.PDRV0(project_io_drive_sel[70]),
		.PDRV1(project_io_drive_sel[71]),
		.A(project_io_out[35]),
		.Y(project_io_in[35])
	);
	gf180mcu_ocd_io__bi_t \project_pads[36]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[36]),
		.CS(project_io_schmitt_select[36]),
		.SL(project_io_slew_select[36]),
		.IE(project_io_inen[36]),
		.OE(project_io_outen[36]),
		.PU(project_io_pu_select[36]),
		.PD(project_io_pd_select[36]),
		.PDRV0(project_io_drive_sel[72]),
		.PDRV1(project_io_drive_sel[73]),
		.A(project_io_out[36]),
		.Y(project_io_in[36])
	);
	gf180mcu_ocd_io__bi_t \project_pads[37]  (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
		.PAD(project_io[37]),
		.CS(project_io_schmitt_select[37]),
		.SL(project_io_slew_select[37]),
		.IE(project_io_inen[37]),
		.OE(project_io_outen[37]),
		.PU(project_io_pu_select[37]),
		.PD(project_io_pd_select[37]),
		.PDRV0(project_io_drive_sel[74]),
		.PDRV1(project_io_drive_sel[75]),
		.A(project_io_out[37]),
		.Y(project_io_in[37])
	);
	gf180mcu_ocd_io__fill5 gf180mcu_ocd_io__fill5 [2:0] (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
	);
	gf180mcu_ocd_io__fill10 gf180mcu_ocd_io__fill10 [1044:0] (
	`ifdef USE_POWER_PINS
		.DVDD(vddio),
		.DVSS(vssio),
		.VDD(vccd),
		.VSS(vssd),
	`endif
	);

endmodule
// `default_nettype wire
