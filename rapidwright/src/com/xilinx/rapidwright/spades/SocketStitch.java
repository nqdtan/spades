
package com.xilinx.rapidwright.spades;

import java.util.*;
import java.util.HashSet;
import java.util.HashMap;

import java.io.FileNotFoundException;
import java.io.IOException;

import com.xilinx.rapidwright.design.*;
import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.router.*;

import com.xilinx.rapidwright.edif.*;
import com.xilinx.rapidwright.util.*;

import com.xilinx.rapidwright.design.Module;
import com.xilinx.rapidwright.design.ModuleInst;

import com.xilinx.rapidwright.tests.CodePerfTracker;

public class SocketStitch {
  public static String prefixName = "design_1_i/socket";

  // w=1, h=1 -- designId 0
//  public static int LLCRX = 4;
//  public static int URCRX = 6;
//  public static int LLCRY = 2;
//  public static int URCRY = 2;
//  public static int LLTLX = 52;
//  public static int URTLX = 74;
//  public static int LLTLY = 100;
//  public static int URTLY = 191;

  // w=2, h=1 -- designId 1
//  public static int LLCRX = 2;
//  public static int URCRX = 6;
//  public static int LLCRY = 2;
//  public static int URCRY = 2;
//  public static int LLTLX = 29;
//  public static int URTLX = 74;
//  public static int LLTLY = 100;
//  public static int URTLY = 191;

  // w=1, h=2 -- designId 2
//  public static int LLCRX = 4;
//  public static int URCRX = 6;
//  public static int LLCRY = 2;
//  public static int URCRY = 3;
//  public static int LLTLX = 52;
//  public static int URTLX = 74;
//  public static int LLTLY = 100;
//  public static int URTLY = 287;

  // w=1, h=3 -- designId 3
//  public static int LLCRX = 4;
//  public static int URCRX = 6;
//  public static int LLCRY = 1;
//  public static int URCRY = 3;
//  public static int LLTLX = 52;
//  public static int URTLX = 74;
//  public static int LLTLY = 4;
//  public static int URTLY = 287;

  // w=1, h=1 -- designId 4 (sub, or s)
//  public static int LLCRX = 4;
//  public static int URCRX = 6;
//  public static int LLCRY = 4;
//  public static int URCRY = 4;
//  public static int LLTLX = 52;
//  public static int URTLX = 74;
//  public static int LLTLY = 288;
//  public static int URTLY = 331;

  public static int LLCRX[] = {4, 2, 4, 4, 4};
  public static int URCRX[] = {6, 6, 6, 6, 6};
  public static int LLCRY[] = {2, 2, 2, 1, 4};
  public static int URCRY[] = {2, 2, 3, 3, 4};
  public static int LLTLX[] = {52, 29, 52, 52, 52};
  public static int URTLX[] = {74, 74, 74, 74, 74};
  public static int LLTLY[] = {100, 100, 100, 4, 288};
  public static int URTLY[] = {191, 191, 287, 287, 331};

  public static boolean isTileValid(Tile tile, int designId) {
    int x = tile.getTileXCoordinate();
    int y = tile.getTileYCoordinate();
    if ((x >= LLTLX[designId]) && (x <= URTLX[designId]) &&
        (y >= LLTLY[designId]) && (y <= URTLY[designId]))
      return true;

    return false;
  }

  public static boolean isCRValid(ClockRegion cr, int designId) {
    if (((cr.getInstanceX() >= LLCRX[designId])  &&
         (cr.getInstanceX() <= URCRX[designId])) &&
        ((cr.getInstanceY() >= LLCRY[designId])  &&
         (cr.getInstanceY() <= URCRY[designId])))
      return true;

    return false;
  }

  public static Cell copyCellCustom(Design d, EDIFNetlist nl, Cell c, boolean HasPrefix, String newPrefix) {
    SiteInst origSI = c.getSiteInst();
    Site site = origSI.getSite();
    SiteInst newSI = d.getSiteInstFromSite(site);
    if (newSI == null) {
      newSI = d.createSiteInst(site.getName(), origSI.getSiteTypeEnum(), site);
    }

    EDIFCellInst ref = c.getEDIFCellInst();
    EDIFLibrary lib  = nl.getLibrary("work");

    if (ref.getParentCell().getLibrary().getName().contains("primitives"))
      lib = nl.getLibrary("hdi_primitives");
    EDIFCell parentCell = lib.getCell(ref.getParentCell().getName());
    if (parentCell == null) {
      parentCell = new EDIFCell(lib, ref.getParentCell().getName());
    }

    EDIFCellInst newEci = parentCell.getCellInst(ref.getName());
    if (newEci == null) {
      newEci = new EDIFCellInst(ref.getName(), ref.getCellType(), parentCell);
    }

    EDIFTools.ensureCellInLibraries(nl, ref.getCellType());
    newEci.setPropertiesMap(ref.getPropertiesMap());

    String origBELName = c.getBEL().getName();
    BEL relocBEL = newSI.getBEL(c.getBEL().getName());

    // Be mindful of the cell name. It must match the hierarchy from netlist
    String cellName = cellName = newPrefix + "/" + c.getName();
    if (HasPrefix)
      cellName = newPrefix + "/" + c.getName().substring(prefixName.length() + 1);
    Cell newCell = new Cell(cellName, newSI, relocBEL);
    return newCell;
  }

  public static void main(String[] args) throws FileNotFoundException {
    CodePerfTracker t = new CodePerfTracker("Socket Stitch");
    t.start("Socket Stitch");

    boolean FullyRoute = false;
    //boolean FullyRoute = true; // for verifying purpose (to make sure
    // no route conflict between socket_cc and socket_rg_cl after stitching)
    int designId = 0;
    //int designId = 1;
    //int designId = 4;

    // Extract the socket region to a new design checkpoint
    Design design = Design.readCheckpoint("../checkpoints/socket_cc.dcp", "../checkpoints/socket_cc.edf");
    EDIFNetlist netlist = design.getNetlist();

    Device dev = design.getDevice();

    Design clDesign = Design.readCheckpoint("../checkpoints/socket_rg_cl.dcp", "../checkpoints/socket_rg_cl.edf");
    EDIFNetlist clNetlist = clDesign.getNetlist();

    EDIFCell socketCell = netlist.getCell("socket_imp_8EZPJT");
    Design socketDesign = new Design("socket_design", design.getPartName());
    socketDesign.setAutoIOBuffers(false);
    EDIFNetlist socketNetlist = socketDesign.getNetlist();

    EDIFCell top = socketNetlist.getTopCell();
    EDIFLibrary plib = socketNetlist.getLibrary("hdi_primitives");
    EDIFLibrary wlib = socketNetlist.getLibrary("work");

    Net clGndNet = clDesign.getNet("GLOBAL_LOGIC0");
    Net clVccNet = clDesign.getNet("GLOBAL_LOGIC1");
    HashMap<Net, HashSet<PIP>> staticNetPIPMap = new HashMap<>();
    HashMap<Net, HashSet<SitePinInst>> staticNetSPIMap = new HashMap<>();

    HashSet<PIP> clGndPIPs = new HashSet<>();
    HashSet<PIP> clVccPIPs = new HashSet<>();

    clGndPIPs.addAll(clGndNet.getPIPs());
    clVccPIPs.addAll(clVccNet.getPIPs());

    System.out.println("Before ModInst");
    System.out.println(clGndNet + " " + clGndNet.getPIPs().size());
    System.out.println(clVccNet + " " + clVccNet.getPIPs().size());

    Module clModule = new Module(clDesign);
    HashSet<Net> toRemoveNets = new HashSet<>();
    for (Net net : clModule.getNets()) {
      if (net.getName().contains("ff_bridge/net_b") ||
          net.getName().equals("cl_ctrl_addr[11]") ||
          net.getName().equals("cl_ctrl_addr[10]") ||
          net.getName().equals("cl_ctrl_addr[9]") ||
          net.getName().equals("cl_ctrl_addr[8]") ||
          //net.getName().equals("GLOBAL_USEDNET") ||
          net.getName().equals("cl_ctrl_we") ||
          net.getName().equals("cl_ctrl_ce") ||
          net.getName().equals("stub_in") ||
          net.getName().equals("clk_BUFG_LOPT_OOC") ||
          net.getName().equals("clk") ||
          net.getName().equals("socket_reset")
      ) {
        toRemoveNets.add(net);
      }
    }
    for (Net net : toRemoveNets) {
      clModule.removeNet(net);
    }

    Site clAnchorSite = clModule.getAnchor();
    System.out.println(clAnchorSite);

    ModuleInst clModuleInst = socketDesign.createModuleInst("socket_cl_inst", clModule);

    System.out.println("After ModInst");
    System.out.println(clGndNet + " " + clGndNet.getPIPs().size());
    System.out.println(clVccNet + " " + clVccNet.getPIPs().size());

    EDIFCellInst clECI = top.getCellInst("socket_cl_inst");
    EDIFCell clEC = clECI.getCellType();
    clEC.setView("socket_cl");
    clEC.rename("socket_cl");
    clECI.setViewref(new EDIFName("socket_cl"));
    socketNetlist.consolidateAllToWorkLibrary();

    clModuleInst.place(clAnchorSite);

    EDIFCell socketCCCell = new EDIFCell(wlib, "socket_cc");
    socketNetlist.cloneNetlistFromTopCell(socketCell, socketCCCell);
    EDIFCellInst socketCCInst = new EDIFCellInst("socket_cc_inst", socketCCCell, top);

    EDIFCell socketCLCell = clEC;
    EDIFCellInst socketCLInst = clECI;

    // create logical connections between SocketCC and SocketCL
    EDIFNet[] lsu0Port0AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu0Port0AddrLNet[i] = top.createNet("lsu0_port0_addr_" + i);
      lsu0Port0AddrLNet[i].createPortInst(socketCCCell.getPort("lsu0_port0_addr"), 12 - 1 - i, socketCCInst);
      lsu0Port0AddrLNet[i].createPortInst(socketCLCell.getPort("lsu0_port0_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port1AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu0Port1AddrLNet[i] = top.createNet("lsu0_port1_addr_" + i);
      lsu0Port1AddrLNet[i].createPortInst(socketCCCell.getPort("lsu0_port1_addr"), 12 - 1 - i, socketCCInst);
      lsu0Port1AddrLNet[i].createPortInst(socketCLCell.getPort("lsu0_port1_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port2AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu0Port2AddrLNet[i] = top.createNet("lsu0_port2_addr_" + i);
      lsu0Port2AddrLNet[i].createPortInst(socketCCCell.getPort("lsu0_port2_addr"), 12 - 1 - i, socketCCInst);
      lsu0Port2AddrLNet[i].createPortInst(socketCLCell.getPort("lsu0_port2_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port3AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu0Port3AddrLNet[i] = top.createNet("lsu0_port3_addr_" + i);
      lsu0Port3AddrLNet[i].createPortInst(socketCCCell.getPort("lsu0_port3_addr"), 12 - 1 - i, socketCCInst);
      lsu0Port3AddrLNet[i].createPortInst(socketCLCell.getPort("lsu0_port3_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet lsu0Port0CELNet = top.createNet("lsu0_port0_ce");
    lsu0Port0CELNet.createPortInst(socketCCCell.getPort("lsu0_port0_ce"), socketCCInst);
    lsu0Port0CELNet.createPortInst(socketCLCell.getPort("lsu0_port0_ce"), socketCLInst);
    EDIFNet lsu0Port0WELNet = top.createNet("lsu0_port0_we");
    lsu0Port0WELNet.createPortInst(socketCCCell.getPort("lsu0_port0_we"), socketCCInst);
    lsu0Port0WELNet.createPortInst(socketCLCell.getPort("lsu0_port0_we"), socketCLInst);

    EDIFNet lsu0Port1CELNet = top.createNet("lsu0_port1_ce");
    lsu0Port1CELNet.createPortInst(socketCCCell.getPort("lsu0_port1_ce"), socketCCInst);
    lsu0Port1CELNet.createPortInst(socketCLCell.getPort("lsu0_port1_ce"), socketCLInst);
    EDIFNet lsu0Port1WELNet = top.createNet("lsu0_port1_we");
    lsu0Port1WELNet.createPortInst(socketCCCell.getPort("lsu0_port1_we"), socketCCInst);
    lsu0Port1WELNet.createPortInst(socketCLCell.getPort("lsu0_port1_we"), socketCLInst);

    EDIFNet lsu0Port2CELNet = top.createNet("lsu0_port2_ce");
    lsu0Port2CELNet.createPortInst(socketCCCell.getPort("lsu0_port2_ce"), socketCCInst);
    lsu0Port2CELNet.createPortInst(socketCLCell.getPort("lsu0_port2_ce"), socketCLInst);
    EDIFNet lsu0Port2WELNet = top.createNet("lsu0_port2_we");
    lsu0Port2WELNet.createPortInst(socketCCCell.getPort("lsu0_port2_we"), socketCCInst);
    lsu0Port2WELNet.createPortInst(socketCLCell.getPort("lsu0_port2_we"), socketCLInst);

    EDIFNet lsu0Port3CELNet = top.createNet("lsu0_port3_ce");
    lsu0Port3CELNet.createPortInst(socketCCCell.getPort("lsu0_port3_ce"), socketCCInst);
    lsu0Port3CELNet.createPortInst(socketCLCell.getPort("lsu0_port3_ce"), socketCLInst);
    EDIFNet lsu0Port3WELNet = top.createNet("lsu0_port3_we");
    lsu0Port3WELNet.createPortInst(socketCCCell.getPort("lsu0_port3_we"), socketCCInst);
    lsu0Port3WELNet.createPortInst(socketCLCell.getPort("lsu0_port3_we"), socketCLInst);

    EDIFNet lsu0DpModeLNet = top.createNet("lsu0_dp_mode");
    lsu0DpModeLNet.createPortInst(socketCCCell.getPort("lsu0_dp_mode"), socketCCInst);
    lsu0DpModeLNet.createPortInst(socketCLCell.getPort("lsu0_dp_mode"), socketCLInst);

    EDIFNet[] lsu0Port0DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port0DLNet[i] = top.createNet("lsu0_port0_d_" + i);
      lsu0Port0DLNet[i].createPortInst(socketCCCell.getPort("lsu0_port0_d"), 64 - 1 - i, socketCCInst);
      lsu0Port0DLNet[i].createPortInst(socketCLCell.getPort("lsu0_port0_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port1DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port1DLNet[i] = top.createNet("lsu0_port1_d_" + i);
      lsu0Port1DLNet[i].createPortInst(socketCCCell.getPort("lsu0_port1_d"), 64 - 1 - i, socketCCInst);
      lsu0Port1DLNet[i].createPortInst(socketCLCell.getPort("lsu0_port1_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port2DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port2DLNet[i] = top.createNet("lsu0_port2_d_" + i);
      lsu0Port2DLNet[i].createPortInst(socketCCCell.getPort("lsu0_port2_d"), 64 - 1 - i, socketCCInst);
      lsu0Port2DLNet[i].createPortInst(socketCLCell.getPort("lsu0_port2_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port3DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port3DLNet[i] = top.createNet("lsu0_port3_d_" + i);
      lsu0Port3DLNet[i].createPortInst(socketCCCell.getPort("lsu0_port3_d"), 64 - 1 - i, socketCCInst);
      lsu0Port3DLNet[i].createPortInst(socketCLCell.getPort("lsu0_port3_d"), 64 - 1 - i, socketCLInst);
    }

    EDIFNet[] lsu0Port0QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port0QLNet[i] = top.createNet("lsu0_port0_q_" + i);
      lsu0Port0QLNet[i].createPortInst(socketCCCell.getPort("lsu0_port0_q"), 64 - 1 - i, socketCCInst);
      lsu0Port0QLNet[i].createPortInst(socketCLCell.getPort("lsu0_port0_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port1QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port1QLNet[i] = top.createNet("lsu0_port1_q_" + i);
      lsu0Port1QLNet[i].createPortInst(socketCCCell.getPort("lsu0_port1_q"), 64 - 1 - i, socketCCInst);
      lsu0Port1QLNet[i].createPortInst(socketCLCell.getPort("lsu0_port1_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port2QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port2QLNet[i] = top.createNet("lsu0_port2_q_" + i);
      lsu0Port2QLNet[i].createPortInst(socketCCCell.getPort("lsu0_port2_q"), 64 - 1 - i, socketCCInst);
      lsu0Port2QLNet[i].createPortInst(socketCLCell.getPort("lsu0_port2_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu0Port3QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu0Port3QLNet[i] = top.createNet("lsu0_port3_q_" + i);
      lsu0Port3QLNet[i].createPortInst(socketCCCell.getPort("lsu0_port3_q"), 64 - 1 - i, socketCCInst);
      lsu0Port3QLNet[i].createPortInst(socketCLCell.getPort("lsu0_port3_q"), 64 - 1 - i, socketCLInst);
    }

    EDIFNet[] lsu0RamEnLNet = new EDIFNet[5];
    for (int i = 0; i < 5; i++) {
      lsu0RamEnLNet[i] = top.createNet("lsu0_ram_en_" + i);
      lsu0RamEnLNet[i].createPortInst(socketCCCell.getPort("lsu0_ram_en"), 5 - 1 - i, socketCCInst);
      lsu0RamEnLNet[i].createPortInst(socketCLCell.getPort("lsu0_ram_en"), 5 - 1 - i, socketCLInst);
    }

    EDIFNet[] lsu1Port0AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu1Port0AddrLNet[i] = top.createNet("lsu1_port0_addr_" + i);
      lsu1Port0AddrLNet[i].createPortInst(socketCCCell.getPort("lsu1_port0_addr"), 12 - 1 - i, socketCCInst);
      lsu1Port0AddrLNet[i].createPortInst(socketCLCell.getPort("lsu1_port0_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port1AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu1Port1AddrLNet[i] = top.createNet("lsu1_port1_addr_" + i);
      lsu1Port1AddrLNet[i].createPortInst(socketCCCell.getPort("lsu1_port1_addr"), 12 - 1 - i, socketCCInst);
      lsu1Port1AddrLNet[i].createPortInst(socketCLCell.getPort("lsu1_port1_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port2AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu1Port2AddrLNet[i] = top.createNet("lsu1_port2_addr_" + i);
      lsu1Port2AddrLNet[i].createPortInst(socketCCCell.getPort("lsu1_port2_addr"), 12 - 1 - i, socketCCInst);
      lsu1Port2AddrLNet[i].createPortInst(socketCLCell.getPort("lsu1_port2_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port3AddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      lsu1Port3AddrLNet[i] = top.createNet("lsu1_port3_addr_" + i);
      lsu1Port3AddrLNet[i].createPortInst(socketCCCell.getPort("lsu1_port3_addr"), 12 - 1 - i, socketCCInst);
      lsu1Port3AddrLNet[i].createPortInst(socketCLCell.getPort("lsu1_port3_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet lsu1Port0CELNet = top.createNet("lsu1_port0_ce");
    lsu1Port0CELNet.createPortInst(socketCCCell.getPort("lsu1_port0_ce"), socketCCInst);
    lsu1Port0CELNet.createPortInst(socketCLCell.getPort("lsu1_port0_ce"), socketCLInst);
    EDIFNet lsu1Port0WELNet = top.createNet("lsu1_port0_we");
    lsu1Port0WELNet.createPortInst(socketCCCell.getPort("lsu1_port0_we"), socketCCInst);
    lsu1Port0WELNet.createPortInst(socketCLCell.getPort("lsu1_port0_we"), socketCLInst);

    EDIFNet lsu1Port1CELNet = top.createNet("lsu1_port1_ce");
    lsu1Port1CELNet.createPortInst(socketCCCell.getPort("lsu1_port1_ce"), socketCCInst);
    lsu1Port1CELNet.createPortInst(socketCLCell.getPort("lsu1_port1_ce"), socketCLInst);
    EDIFNet lsu1Port1WELNet = top.createNet("lsu1_port1_we");
    lsu1Port1WELNet.createPortInst(socketCCCell.getPort("lsu1_port1_we"), socketCCInst);
    lsu1Port1WELNet.createPortInst(socketCLCell.getPort("lsu1_port1_we"), socketCLInst);

    EDIFNet lsu1Port2CELNet = top.createNet("lsu1_port2_ce");
    lsu1Port2CELNet.createPortInst(socketCCCell.getPort("lsu1_port2_ce"), socketCCInst);
    lsu1Port2CELNet.createPortInst(socketCLCell.getPort("lsu1_port2_ce"), socketCLInst);
    EDIFNet lsu1Port2WELNet = top.createNet("lsu1_port2_we");
    lsu1Port2WELNet.createPortInst(socketCCCell.getPort("lsu1_port2_we"), socketCCInst);
    lsu1Port2WELNet.createPortInst(socketCLCell.getPort("lsu1_port2_we"), socketCLInst);

    EDIFNet lsu1Port3CELNet = top.createNet("lsu1_port3_ce");
    lsu1Port3CELNet.createPortInst(socketCCCell.getPort("lsu1_port3_ce"), socketCCInst);
    lsu1Port3CELNet.createPortInst(socketCLCell.getPort("lsu1_port3_ce"), socketCLInst);
    EDIFNet lsu1Port3WELNet = top.createNet("lsu1_port3_we");
    lsu1Port3WELNet.createPortInst(socketCCCell.getPort("lsu1_port3_we"), socketCCInst);
    lsu1Port3WELNet.createPortInst(socketCLCell.getPort("lsu1_port3_we"), socketCLInst);

    EDIFNet lsu1DpModeLNet = top.createNet("lsu1_dp_mode");
    lsu1DpModeLNet.createPortInst(socketCCCell.getPort("lsu1_dp_mode"), socketCCInst);
    lsu1DpModeLNet.createPortInst(socketCLCell.getPort("lsu1_dp_mode"), socketCLInst);

    EDIFNet[] lsu1Port0DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port0DLNet[i] = top.createNet("lsu1_port0_d_" + i);
      lsu1Port0DLNet[i].createPortInst(socketCCCell.getPort("lsu1_port0_d"), 64 - 1 - i, socketCCInst);
      lsu1Port0DLNet[i].createPortInst(socketCLCell.getPort("lsu1_port0_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port1DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port1DLNet[i] = top.createNet("lsu1_port1_d_" + i);
      lsu1Port1DLNet[i].createPortInst(socketCCCell.getPort("lsu1_port1_d"), 64 - 1 - i, socketCCInst);
      lsu1Port1DLNet[i].createPortInst(socketCLCell.getPort("lsu1_port1_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port2DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port2DLNet[i] = top.createNet("lsu1_port2_d_" + i);
      lsu1Port2DLNet[i].createPortInst(socketCCCell.getPort("lsu1_port2_d"), 64 - 1 - i, socketCCInst);
      lsu1Port2DLNet[i].createPortInst(socketCLCell.getPort("lsu1_port2_d"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port3DLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port3DLNet[i] = top.createNet("lsu1_port3_d_" + i);
      lsu1Port3DLNet[i].createPortInst(socketCCCell.getPort("lsu1_port3_d"), 64 - 1 - i, socketCCInst);
      lsu1Port3DLNet[i].createPortInst(socketCLCell.getPort("lsu1_port3_d"), 64 - 1 - i, socketCLInst);
    }

    EDIFNet[] lsu1Port0QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port0QLNet[i] = top.createNet("lsu1_port0_q_" + i);
      lsu1Port0QLNet[i].createPortInst(socketCCCell.getPort("lsu1_port0_q"), 64 - 1 - i, socketCCInst);
      lsu1Port0QLNet[i].createPortInst(socketCLCell.getPort("lsu1_port0_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port1QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port1QLNet[i] = top.createNet("lsu1_port1_q_" + i);
      lsu1Port1QLNet[i].createPortInst(socketCCCell.getPort("lsu1_port1_q"), 64 - 1 - i, socketCCInst);
      lsu1Port1QLNet[i].createPortInst(socketCLCell.getPort("lsu1_port1_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port2QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port2QLNet[i] = top.createNet("lsu1_port2_q_" + i);
      lsu1Port2QLNet[i].createPortInst(socketCCCell.getPort("lsu1_port2_q"), 64 - 1 - i, socketCCInst);
      lsu1Port2QLNet[i].createPortInst(socketCLCell.getPort("lsu1_port2_q"), 64 - 1 - i, socketCLInst);
    }
    EDIFNet[] lsu1Port3QLNet = new EDIFNet[64];
    for (int i = 0; i < 64; i++) {
      lsu1Port3QLNet[i] = top.createNet("lsu1_port3_q_" + i);
      lsu1Port3QLNet[i].createPortInst(socketCCCell.getPort("lsu1_port3_q"), 64 - 1 - i, socketCCInst);
      lsu1Port3QLNet[i].createPortInst(socketCLCell.getPort("lsu1_port3_q"), 64 - 1 - i, socketCLInst);
    }

    EDIFNet[] lsu1RamEnLNet = new EDIFNet[5];
    for (int i = 0; i < 5; i++) {
      lsu1RamEnLNet[i] = top.createNet("lsu1_ram_en_" + i);
      lsu1RamEnLNet[i].createPortInst(socketCCCell.getPort("lsu1_ram_en"), 5 - 1 - i, socketCCInst);
      lsu1RamEnLNet[i].createPortInst(socketCLCell.getPort("lsu1_ram_en"), 5 - 1 - i, socketCLInst);
    }

    EDIFNet[] clCtrlAddrLNet = new EDIFNet[12];
    for (int i = 0; i < 12; i++) {
      clCtrlAddrLNet[i] = top.createNet("cl_ctrl_addr_" + i);
      clCtrlAddrLNet[i].createPortInst(socketCCCell.getPort("cl_ctrl_addr"), 12 - 1 - i, socketCCInst);
      clCtrlAddrLNet[i].createPortInst(socketCLCell.getPort("cl_ctrl_addr"), 12 - 1 - i, socketCLInst);
    }
    EDIFNet clCtrlCELNet = top.createNet("cl_ctrl_ce");
    clCtrlCELNet.createPortInst(socketCCCell.getPort("cl_ctrl_ce"), socketCCInst);
    clCtrlCELNet.createPortInst(socketCLCell.getPort("cl_ctrl_ce"), socketCLInst);
    EDIFNet clCtrlWELNet = top.createNet("cl_ctrl_we");
    clCtrlWELNet.createPortInst(socketCCCell.getPort("cl_ctrl_we"), socketCCInst);
    clCtrlWELNet.createPortInst(socketCLCell.getPort("cl_ctrl_we"), socketCLInst);
    EDIFNet socketResetCELNet = top.createNet("socket_reset");
    socketResetCELNet.createPortInst(socketCCCell.getPort("socket_reset"), socketCCInst);
    socketResetCELNet.createPortInst(socketCLCell.getPort("socket_reset"), socketCLInst);
    EDIFNet clDoneLNet = top.createNet("cl_done");
    clDoneLNet.createPortInst(socketCCCell.getPort("cl_done"), socketCCInst);
    clDoneLNet.createPortInst(socketCLCell.getPort("cl_done"), socketCLInst);

    EDIFNet[] clCtrlDLNet = new EDIFNet[32];
    for (int i = 0; i < 32; i++) {
      clCtrlDLNet[i] = top.createNet("cl_ctrl_d_" + i);
      clCtrlDLNet[i].createPortInst(socketCCCell.getPort("cl_ctrl_d"), 32 - 1 - i, socketCCInst);
      clCtrlDLNet[i].createPortInst(socketCLCell.getPort("cl_ctrl_d"), 32 - 1 - i, socketCLInst);
    }

    EDIFNet[] clCtrlQLNet = new EDIFNet[32];
    for (int i = 0; i < 32; i++) {
      clCtrlQLNet[i] = top.createNet("cl_ctrl_q_" + i);
      clCtrlQLNet[i].createPortInst(socketCCCell.getPort("cl_ctrl_q"), 32 - 1 - i, socketCCInst);
      clCtrlQLNet[i].createPortInst(socketCLCell.getPort("cl_ctrl_q"), 32 - 1 - i, socketCLInst);
    }

    String clock1NetName = "design_1_i/mbufgce_primitive_0/inst/clk_out_o1";
    String clock2NetName = "design_1_i/mbufgce_primitive_0/inst/clk_out_o2";
    Net vccNet = socketDesign.createNet("GLOBAL_LOGIC1");
    Net gndNet = socketDesign.createNet("GLOBAL_LOGIC0");

    // Remove unused logical cells and nets
    EDIFCellInst bufgECI = socketCLCell.getCellInst("clk_BUFGCE_inst_LOPT_OOC");
    HashMap<EDIFNet, EDIFPortInst> bufgEPIMap = new HashMap<>();
    for (EDIFPortInst epi : bufgECI.getPortInsts()) {
      EDIFNet enet = epi.getNet();
      bufgEPIMap.put(enet, epi);
    }

    for (Map.Entry<EDIFNet, EDIFPortInst> entry : bufgEPIMap.entrySet()) {
      EDIFNet enet = entry.getKey();
      EDIFPortInst epi = entry.getValue();
      enet.removePortInst(epi);
    }

    socketCLCell.removeNet("clk_BUFG_LOPT_OOC");
    socketCLCell.removeCellInst(socketCLCell.getCellInst("clk_BUFGCE_inst_LOPT_OOC"));
    socketCCCell.removeNet("clk_ce");

    String stubCellInstName = "i_0";
    if (socketCLCell.getCellInst(stubCellInstName) == null)
      stubCellInstName = "i_3_0"; // in some case, Vivado assigns a different name to this

    assert (socketCLCell.getCellInst(stubCellInstName) != null) : "Could not find stub cell with name " + stubCellInstName;

    for (EDIFPortInst epi : socketCLCell.getCellInst(stubCellInstName).getPortInsts()) {
      EDIFNet enet = epi.getNet();
      enet.removePortInst(epi);
    }

    socketCLCell.removeNet("stub_in");
    socketCLCell.removeNet("stub_out");
    socketCLCell.removeCellInst(socketCLCell.getCellInst(stubCellInstName));

    HashSet<Cell> toRemoveCells = new HashSet<>();
    SiteInst stubCellSI = null;
    for (Cell c : socketDesign.getCells()) {
      if (c.getName().equals("socket_cl_inst/clk_BUFGCE_inst_LOPT_OOC") ||
          c.getName().equals("socket_cl_inst/" + stubCellInstName)) {
        toRemoveCells.add(c);
        if (c.getName().equals("socket_cl_inst/" + stubCellInstName)) {
          stubCellSI = c.getSiteInst();
        }
      }
    }
    // stubCell actually maps to two different BELs, hence need to manually remove it
    // again from its SiteInst
    stubCellSI.removeCell(stubCellSI.getBEL("H1_IMR"));
    HashSet<SiteInst> toRemoveSIs = new HashSet<>();
    for (Cell c : toRemoveCells) {
      socketDesign.removeCell(c);
      toRemoveSIs.add(c.getSiteInst());
    }

    EDIFNet logicalClk1Net = top.createNet("f_clk");
    EDIFNet logicalClk2Net = top.createNet("clk");
    Net physClk1Net = socketDesign.createNet("f_clk");
    Net physClk2Net = socketDesign.createNet("clk");

    logicalClk1Net.createPortInst(socketCCCell.getPort("f_clk"), socketCCInst);
    logicalClk1Net.createPortInst(socketCLCell.getPort("clk"), socketCLInst);
    logicalClk2Net.createPortInst(socketCCCell.getPort("s_clk"), socketCCInst);

    socketCLCell.getNet("clk").createPortInst(socketCLCell.getPort("clk"));

    EDIFPort fclkPort = top.createPort("f_clk", EDIFDirection.OUTPUT, 1);
    logicalClk1Net.createPortInst(fclkPort);
    EDIFPort clkPort = top.createPort("clk", EDIFDirection.OUTPUT, 1);
    logicalClk2Net.createPortInst(clkPort);

    HashMap<SiteInst, HashSet<String>> toRemoveSiteWireMap = new HashMap<>();

    HashSet<Cell> cells = new HashSet<>();
    for (Cell c : design.getCells()) {
      if (c.getName().contains(prefixName)) {
        cells.add(c);
      }
    }

    // Copy the cell placement info from the reference design to the socketDesign
    // This doesn't work for design that has encrypted netlist
    boolean check = false;
    for (Cell c : cells) {
      Cell newCell = null;
      if (c.getName().contains(prefixName)) {
        newCell = copyCellCustom(socketDesign, socketNetlist, c, true, "socket_cc_inst");
      }

      if (newCell == null)
        System.out.println("Error! Could not place cell " + c.getName());

      newCell.setBELFixed(false);
      newCell.setSiteFixed(false);

      // Copy pin mappings from ref cell to new cell
      HashSet<String> oldPPins = new HashSet<String>();
      for (String ppin : newCell.getPinMappingsP2L().keySet()) {
        oldPPins.add(ppin);
      }

      for (String ppin : oldPPins) {
        newCell.removePinMapping(ppin);
      }

      for (Map.Entry<String, String> entry : c.getPinMappingsP2L().entrySet()) {
        String ppin = entry.getKey();
        String lpin  = entry.getValue();
        newCell.addPinMapping(ppin, lpin);
      }

      SiteInst newSI = newCell.getSiteInst();
      SiteInst origSI = c.getSiteInst();
      HashSet<String> invalidSiteWires = new HashSet<>();
      // Remove invalid connection for <const1> net caused by
      // cell placement (e.g., LUT A6 pin)
      for (String siteWire : newSI.getSiteWiresFromNet(gndNet)) {
        if (!origSI.getSiteWiresFromNet(vccNet).contains(siteWire)) {
          invalidSiteWires.add(siteWire);
        }
      }
      toRemoveSiteWireMap.put(newSI, invalidSiteWires);
    }

    for (Map.Entry<SiteInst, HashSet<String>> entry : toRemoveSiteWireMap.entrySet()) {
      SiteInst si = entry.getKey();
      for (String siteWire : entry.getValue()) {
        HashSet<BELPin> outputSet = new HashSet<BELPin>();
        HashSet<BELPin> inputSet  = new HashSet<BELPin>();
        for (BELPin bp : si.getSiteWirePins(siteWire)) {
          if (bp.getDir() == BELPin.Direction.OUTPUT)
            outputSet.add(bp);
          else
            inputSet.add(bp);
        }

        assert outputSet.size() == 1 : "Expect outputSize size to be 1";
        for (BELPin output : outputSet) {
          for (BELPin input : inputSet) {
            boolean unrouteStatus = si.unrouteIntraSiteNet(output, input);
            //System.out.println("Unroute " + output.getName() + " ---> " + input + " for " + si + " " + unrouteStatus);
          }
        }
      }
    }

    // Copy the net routing from the reference design to socketDesign
    boolean IsClockNet;
    for (Net net : design.getNets()) {
      Net newNet;
      IsClockNet = false;
      if (net.getName().equals(clock1NetName)) {
        newNet = physClk1Net;
        IsClockNet = true;
      } else if (net.getName().equals(clock2NetName)) {
        newNet = physClk2Net;
        IsClockNet = true;
      } else if (net.isStaticNet()) {
        newNet = socketDesign.getNet(net.getName());
      } else if (net.getName().contains(prefixName)) {
        newNet = socketDesign.createNet("socket_cc_inst" + "/" + net.getName().substring(prefixName.length() + 1));
      } else {
        continue;
      }

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());

      // For multi-clock design that uses MBUFGCE, it is sufficient to just add
      // PIPs for clock routing
      if (!IsClockNet) {
        for (SitePinInst spi : net.getPins()) {
          SiteInst origSI = spi.getSiteInst();

          ClockRegion cr = origSI.getTile().getClockRegion();
          if (!isCRValid(cr, designId))
            continue;

          SiteInst newSI  = socketDesign.getSiteInstFromSite(origSI.getSite());
          if (newSI == null)
            newSI = socketDesign.createSiteInst(origSI.getName(),
                                               origSI.getSiteTypeEnum(),
                                               origSI.getSite());
          for (SitePIP spip : origSI.getUsedSitePIPs()) {
            newSI.addSitePIP(spip);
          }

          boolean FoundSPI = false;
          for (SitePinInst s : newNet.getPins()) {
            if (s.equals(spi)) {
              FoundSPI = true;
              break;
            }
          }

          if (!FoundSPI) {
            if (newSI.getSitePinInst(spi.getName()) == null) {
              SitePinInst newSpi = newNet.createPin(spi.getName(), newSI);
              newSpi.setSiteInst(newSI);
            }
          }

        }
      }

      for (SiteInst origSI : net.getSiteInsts()) {
        ClockRegion cr = origSI.getTile().getClockRegion();
        if (!isCRValid(cr, designId))
          continue;

        SiteInst newSI  = socketDesign.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = socketDesign.createSiteInst(origSI.getName(),
                                             origSI.getSiteTypeEnum(),
                                             origSI.getSite());
        for (String siteWire : origSI.getSiteWiresFromNet(net)) {
          HashSet<BELPin> outputSet = new HashSet<BELPin>();
          HashSet<BELPin> inputSet  = new HashSet<BELPin>();
          for (BELPin bp : origSI.getSiteWirePins(siteWire)) {
            if (bp.getDir() == BELPin.Direction.OUTPUT)
              outputSet.add(bp);
            else
              inputSet.add(bp);
          }
          assert outputSet.size() == 1 : "Expect outputSize size to be 1";
          for (BELPin output : outputSet) {
            for (BELPin input : inputSet) {
              boolean routeStatus = newSI.routeIntraSiteNet(newNet, output, input);
              //System.out.println("Route " + output.getName() + " ---> " + input + " for " + newSI + " " + routeStatus + " " + newNet);
            }
          }
        }
      }

      for (PIP pip : net.getPIPs()) {
        if (!IsClockNet) {
          if (pip.getTile().getName().contains("INT_X") && !isTileValid(pip.getTile(), designId)) {
            System.out.println("[WARNING] Outside PIP " + pip + " from net " + net);
            if (!FullyRoute) {
              //System.out.println("[WARNING] Outside PIP " + pip + " from net " + net);
              continue;
            }
          }

          ClockRegion cr = pip.getTile().getClockRegion();
          if (!isCRValid(cr, designId)) {
            if (!FullyRoute)
              continue;
          }
        }

        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;

        pipSet.add(pip);
      }
      newNet.setPIPs(pipSet);
    }

    // Copy the clock routing and ff_bridge/net_a* (originated from SocketCL)
    // from the reference clDesign to socketDesign
    for (Net net : clDesign.getNets()) {
      Net newNet;
      IsClockNet = false;

      if (net.getName().equals("clk")) {
        newNet = physClk1Net;
        IsClockNet = true;
      } else if (net.getName().contains("ff_bridge/net_a")) {
        String netNameId = net.getName().substring(15);
        newNet = socketDesign.getNet("socket_cl_inst/ff_bridge/net_a" + netNameId);
        Net netRef = design.getNet("design_1_i/ff_bridge_0/inst/net_a" + netNameId);
        if (netRef.getPIPs().size() != 0)
          net = netRef;
      } else
        continue;

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());
      for (SiteInst origSI : net.getSiteInsts()) {
        ClockRegion cr = origSI.getTile().getClockRegion();
        if (!isCRValid(cr, designId))
          continue;

        SiteInst newSI  = socketDesign.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = socketDesign.createSiteInst(origSI.getName(),
                                             origSI.getSiteTypeEnum(),
                                             origSI.getSite());
        for (String siteWire : origSI.getSiteWiresFromNet(net)) {
          HashSet<BELPin> outputSet = new HashSet<BELPin>();
          HashSet<BELPin> inputSet  = new HashSet<BELPin>();
          for (BELPin bp : origSI.getSiteWirePins(siteWire)) {
            if (bp.getDir() == BELPin.Direction.OUTPUT)
              outputSet.add(bp);
            else
              inputSet.add(bp);
          }
          assert outputSet.size() == 1 : "Expect outputSize size to be 1";
          for (BELPin output : outputSet) {
            for (BELPin input : inputSet) {
              boolean routeStatus = newSI.routeIntraSiteNet(newNet, output, input);
              //System.out.println("Route " + output.getName() + " ---> " + input + " for " + newSI + " " + routeStatus + " " + newNet);
            }
          }
        }
      }

      for (PIP pip : net.getPIPs()) {
        if (!IsClockNet) {
          if (pip.getTile().getName().contains("INT_X") && !isTileValid(pip.getTile(), designId)) {
            System.out.println("[WARNING-1] Outside PIP " + pip + " from net " + net);
            continue;
          }

          ClockRegion cr = pip.getTile().getClockRegion();
          if (!isCRValid(cr, designId)) {
            System.out.println("[WARNING-2] Outside PIP " + pip + " from net " + net);
            continue;
          }
        }

        if (IsClockNet) {
          // Overlapping Clk route of ff_bridge on socket_cc side
          int x = pip.getTile().getTileXCoordinate();
          int y = pip.getTile().getTileYCoordinate();
          // also caused by stub cells (cell_c*) in ff_bridge_extract
          if ((x >= 65 && x <= 73) &&
              (y <= 191) &&
              (pip.getTile().getName().contains("CLE_BC_CORE") ||
               pip.getTile().getName().contains("RCLK_CLE_CORE") ||
               pip.getTile().getName().contains("CLK_VNOC_BBA") ||
               pip.getTile().getName().contains("CLK_REBUF_VERT_VNOC_BBA")
              )) {
            //System.out.println(pip + " " + pip.getTile());
            continue;
          }
        }
        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;

        pipSet.add(pip);
      }
      newNet.setPIPs(pipSet);
    }

    // Route GND and VCC. Simpy copying the routing info from the reference clDesign
    // Weird stuff: after Module instantiation, the static nets' PIPs vanish,
    // so need to store them beforehand!
    HashSet<Net> staticNets = new HashSet<>();
    staticNets.add(clGndNet);
    staticNets.add(clVccNet);
    staticNetPIPMap.put(clGndNet, clGndPIPs);
    staticNetPIPMap.put(clVccNet, clVccPIPs);

    for (Net net : staticNets) {
      Net newNet = socketDesign.getNet(net.getName());

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());
      for (PIP pip : staticNetPIPMap.get(net)) {
        if (pip.getTile().getName().contains("INT_X") && !isTileValid(pip.getTile(), designId)) {
          System.out.println("[WARNING-1] Outside PIP " + pip + " from net " + net);
          continue;
        }

        ClockRegion cr = pip.getTile().getClockRegion();
        if (!isCRValid(cr, designId)) {
          System.out.println("[WARNING-2] Outside PIP " + pip + " from net " + net);
          continue;
        }
        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;

        pipSet.add(pip);
      }
      newNet.setPIPs(pipSet);
    }

    System.out.println(gndNet + " " + gndNet.getPIPs().size());
    System.out.println(vccNet + " " + vccNet.getPIPs().size());

//    if (designId == 1) {
//      socketDesign.getNet("f_clk").removePIP(
//        dev.getPIP("RCLK_BRAM_CLKBUF_CORE_X58Y143/RCLK_BRAM_CLKBUF_CORE.IF_HCLK_R_CLK_HDISTR11<<->>IF_HCLK_L_CLK_HDISTR11"));
//    }

//    if (designId == 2) {
//      socketDesign.getNet("f_clk").removePIP(
//        dev.getPIP("CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/CLK_REBUF_VERT_VNOC_BAA_TILE.IF_WRAP_CLK_V_BOT_CLK_VROUTE11->>CLK_CMT_MUX_4TO1_4_CLK_OUT"));
//      socketDesign.getNet("f_clk").removePIP(
//        dev.getPIP("CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/CLK_REBUF_VERT_VNOC_BAA_TILE.CLK_CMT_MUX_4TO1_4_CLK_OUT->>IF_WRAP_CLK_V_BOT_CLK_VDISTR11"));
//    }

    if (FullyRoute) {
      vccNet.addPIP(dev.getPIP("INT_X35Y0/INT.VCC_WIRE->>IMUX_B_W51"));
      vccNet.addPIP(dev.getPIP("BLI_CLE_BOT_CORE_X35Y0/BLI_CLE_BOT_CORE_MY.INTF_IRI_QUADRANT_RED_12_IMUX_IN15->>INTF_IRI_QUADRANT_RED_12_IMUX_IN15_PIN"));
      vccNet.addPIP(dev.getPIP("BLI_CLE_BOT_CORE_X35Y0/BLI_CLE_BOT_CORE_MY.INTF_IRI_QUADRANT_RED_12_IMUX_IN15_PIN->>INTF_IRI_QUADRANT_RED_12_IMUX_O15_PIN"));
      vccNet.addPIP(dev.getPIP("BLI_CLE_BOT_CORE_X35Y0/BLI_CLE_BOT_CORE_MY.INTF_IRI_QUADRANT_RED_12_IMUX_O15_PIN->>INTF_IRI_QUADRANT_RED_12_IMUX_O15"));
      vccNet.addPIP(dev.getPIP("CLK_REBUF_BUFGS_HSR_CORE_X31Y0/CLK_REBUF_BUFGS_HSR_CORE.CLK_BUFGCE_33_CE->>CLK_BUFGCE_33_CE_PIN"));
    }

    if (designId == 4) {
      // caused by stub cells (cell_c*) in ff_bridge_extract
      socketDesign.getNet("f_clk").removePIP(dev.getPIP("RCLK_CLE_CORE_X70Y288/RCLK_CLE_CORE.CLK_LEAF_SITES_0_I_PIN->>CLK_LEAF_SITES_0_O_PIN"));
      socketDesign.getNet("f_clk").removePIP(dev.getPIP("RCLK_CLE_CORE_X70Y288/RCLK_CLE_CORE.CLK_LEAF_SITES_0_O_PIN->>CLK_LEAF_SITES_0_O"));
      socketDesign.getNet("f_clk").removePIP(dev.getPIP("RCLK_CLE_CORE_X70Y288/RCLK_CLE_CORE.CLK_LEAF_SITES_0_I->>CLK_LEAF_SITES_0_I_PIN"));
      socketDesign.getNet("f_clk").removePIP(dev.getPIP("RCLK_CLE_CORE_X70Y288/RCLK_CLE_CORE.IF_HCLK_CLK_HDISTR_LOC11->>CLK_LEAF_SITES_0_I"));
    }

    HashSet<PIP> toRemovePIPs = new HashSet<>();
    PIP clkPIP = dev.getPIP("CLK_REBUF_BUFGS_HSR_CORE_X31Y0/CLK_REBUF_BUFGS_HSR_CORE.CLK_BUFGCE_33_O_PIN->>CLK_BUFGCE_33_O"); // Clk Track 11
    int cnt = 1;

    while (!isTileValid(clkPIP.getTile(), designId)) {
      toRemovePIPs.add(clkPIP);
      Node enode = clkPIP.getEndNode();
      if (clkPIP.isBidirectional())
        enode = clkPIP.getStartNode();

      cnt = 0;
      for (PIP pip : enode.getAllDownhillPIPs()) {
        if (toRemovePIPs.contains(pip))
          continue;

        if (physClk1Net.getPIPs().contains(pip)) {
          clkPIP = pip;
          //cnt += 1;
          break;
        }
      }
    }

    if (!FullyRoute) {
      for (PIP pip : toRemovePIPs) {
        System.out.println("toRemove PIP " + pip);
        socketDesign.getNet("f_clk").removePIP(pip);
      }
    }

    if (!FullyRoute) {
      if (designId == 2 || designId == 3)
        socketDesign.getNet("f_clk").removePIP(dev.getPIP("CLK_REBUF_VERT_VNOC_CBA_TILE_X69Y87/CLK_REBUF_VERT_VNOC_CBA_TILE.IF_WRAP_CLK_V_TOP_CLK_VROUTE11<<->>IF_WRAP_CLK_V_BOT_CLK_VROUTE11"));
    }

    // Combine the BEL attributes of the two designs
    Map<Site, SiteConfig> socketBELAttrs = new HashMap<>();
    socketBELAttrs.putAll(design.getBELAttrs());
    socketBELAttrs.putAll(clDesign.getBELAttrs());

    System.out.println("[socket_cc] Num. BELAttrs: " + design.getBELAttrs().size());
    System.out.println("[socket_cl] Num. BELAttrs: " + clDesign.getBELAttrs().size());
    System.out.println("Num. BELAttrs: " + socketBELAttrs.size());

    for (Map.Entry<Site, SiteConfig> entry0 : socketBELAttrs.entrySet()) {
      Site site = entry0.getKey();
      SiteTypeEnum type = site.getSiteTypeEnum();
      SiteConfig siteConfig = entry0.getValue();
      for (Map.Entry<BEL, Map<String, BELAttr>> entry1 : siteConfig.getBELAttributes().entrySet()) {
        BEL bel = entry1.getKey();
        for (Map.Entry<String, BELAttr> entry2 : entry1.getValue().entrySet()) {
          String name = entry2.getKey();
          BELAttr belAttr = entry2.getValue();

          Net belAttrNet = null;
          if (belAttr.getNet().getName().equals(clock1NetName) || belAttr.getNet().getName().equals("clk"))
            belAttrNet = physClk1Net;
          else if (belAttr.getNet().getName().equals(clock2NetName))
            belAttrNet = physClk2Net;
          else {
            //TODO: check this
            //belAttrNet = socketDesign.getNet(belAttr.getNet().getName().substring(prefixName.length() + 1));
            belAttrNet = physClk1Net;
          }
          socketDesign.addBELAttr(belAttrNet, site, type, bel, name, belAttr.getValue());
        }
      }
    }

    if (FullyRoute) {
      // Create a clock source
      Cell mbufgCell = socketDesign.createAndPlaceCell(
        socketNetlist.getTopCell(),
        "MBUFGCE_inst", Unisim.MBUFGCE,
        dev.getSite("BUFGCE_X4Y11"),
        dev.getSite("BUFGCE_X4Y11").getBEL("BUFCE"));

      EDIFNet mbufgceClrnLNet = top.createNet("mbufgce_clr_n");
      EDIFPort mbufgceClrnPort = top.createPort("mbufgce_clr_n", EDIFDirection.INPUT, 1);
      mbufgceClrnLNet.createPortInst(mbufgceClrnPort);
      mbufgceClrnLNet.createPortInst(socketCCCell.getPort("mbufgce_clr_n"), socketCCInst);

      EDIFCellInst mbufgECI = mbufgCell.getEDIFCellInst();
      EDIFCell mbufgEC = mbufgECI.getCellType();
      mbufgCell.addProperty("IS_CE_INVERTED", 0);
      mbufgCell.addProperty("IS_I_INVERTED", 0);
      mbufgCell.addProperty("MODE", "PERFORMANCE");

      logicalClk1Net.createPortInst(mbufgEC.getPort("O1"), mbufgECI);
      logicalClk2Net.createPortInst(mbufgEC.getPort("O2"), mbufgECI);
      mbufgceClrnLNet.createPortInst(mbufgEC.getPort("CLRB_LEAF"), mbufgECI);

      SitePinInst mbufgOSPI = socketDesign.getNet("f_clk").createPin("O", mbufgCell.getSiteInst());

      EDIFPort clkTopPort = socketNetlist.getTopCell().createPort("clk_top", EDIFDirection.INPUT, 1);
      EDIFNet clkTopENet = socketNetlist.getTopCell().createNet(clkTopPort.getName());
      clkTopENet.createPortInst(clkTopPort);
      clkTopENet.createPortInst(mbufgEC.getPort("I"), mbufgECI);
    }
    socketDesign.removeNet(socketDesign.getNet("GLOBAL_USEDNET"));

    socketDesign.getNetlist().addEncryptedCells(clDesign.getNetlist().getEncryptedCells());
    socketDesign.writeCheckpoint("../checkpoints/socket_rw_full_v" + designId + ".dcp");
    EDIFTools.writeEDIFFile("../checkpoints/socket_rw_full_v" + designId + ".edf", socketNetlist, socketDesign.getPart().getName());

    t.stop();
    System.out.println("Done.");
  }
}
