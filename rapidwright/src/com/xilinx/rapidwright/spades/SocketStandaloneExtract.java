
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

import com.xilinx.rapidwright.tests.CodePerfTracker;

public class SocketStandaloneExtract {
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
//  public static int LLCRX = 4;
//  public static int URCRX = 8;
//  public static int LLCRY = 2;
//  public static int URCRY = 2;
//  public static int LLTLX = 52;
//  public static int URTLX = 97;
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

  public static int LLCRX[] = {4, 4, 4, 4};
  public static int URCRX[] = {6, 8, 6, 6};
  public static int LLCRY[] = {2, 2, 2, 1};
  public static int URCRY[] = {2, 2, 3, 3};
  public static int LLTLX[] = {52, 52, 52, 52};
  public static int URTLX[] = {74, 97, 74, 74};
  public static int LLTLY[] = {100, 100, 100, 4};
  public static int URTLY[] = {191, 191, 287, 287};

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

  public static Cell copyCellCustom(Design d, EDIFNetlist nl, Cell c) {
    SiteInst origSI = c.getSiteInst();
    Site site = origSI.getSite();
    SiteInst newSI = d.getSiteInst(site.getName());
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
    Cell newCell = new Cell(c.getName().substring(prefixName.length() + 1), newSI, relocBEL);
    return newCell;
  }

  public static EDIFCell getEDIFCellFromRef(EDIFCell ref, EDIFNetlist nl) {
    EDIFLibrary lib = nl.getLibrary("work");
    if (ref.getLibrary().getName().contains("primitives"))
      lib = nl.getLibrary("hdi_primitives");
    EDIFCell ecell = lib.getCell(ref.getName());
    assert ecell != null : "Could not find EDIFCell from ref!";

    return ecell;
  }

  public static void main(String[] args) throws FileNotFoundException {
    CodePerfTracker t = new CodePerfTracker("SocketStandalone Extract");
    t.start("Socket Extract");

    int designId = 0;

    // Extract the socket region to a new design checkpoint
    Design design = Design.readCheckpoint("../checkpoints/socket_standalone.dcp", "../checkpoints/socket_standalone.edf");
    EDIFNetlist netlist = design.getNetlist();

    //System.out.println("[Design] Num. cells: " + design.getCells().size());

    Device dev = design.getDevice();
    EDIFCell top = netlist.getTopCell();

    EDIFCell socket_cell = netlist.getCell("socket_imp_8EZPJT");
    Design socket_design = new Design("socket_design", design.getDevice().getName());
    socket_design.setAutoIOBuffers(false);
    EDIFNetlist socket_netlist = socket_design.getNetlist();

    EDIFCell top1 = socket_netlist.getTopCell();
    EDIFLibrary plib = socket_netlist.getLibrary("hdi_primitives");
    EDIFLibrary wlib = socket_netlist.getLibrary("work");

    socket_netlist.cloneNetlistFromTopCell(socket_cell, top1);

    String clock1NetName = "design_1_i/mbufgce_primitive_0/inst/clk_out_o1";
    String clock2NetName = "design_1_i/mbufgce_primitive_0/inst/clk_out_o2";
    Net vccNet = socket_design.createNet("GLOBAL_LOGIC1");
    Net gndNet = socket_design.createNet("GLOBAL_LOGIC0");
    EDIFNet gnd = EDIFTools.getStaticNet(NetType.GND, top1, socket_design.getNetlist());
    Net const0Net = socket_design.createNet(gnd.getName());
    EDIFNet pwr = EDIFTools.getStaticNet(NetType.VCC, top1, socket_design.getNetlist());
    Net const1Net = socket_design.createNet(pwr.getName());

    HashMap<SiteInst, HashSet<String>> toRemoveSiteWireMap = new HashMap<>();

    boolean check = false;
    for (Cell c : design.getCells()) {
      if (c.getName().contains(prefixName)) {
        Cell newCell = copyCellCustom(socket_design, socket_netlist, c);
//        SiteInst origSI0 = c.getSiteInst();
//        Site site = origSI0.getSite();
//        SiteInst newSI0 = socket_design.getSiteInst(site.getName());
//        if (newSI0 == null) {
//          newSI0 = socket_design.createSiteInst(site.getName(), origSI0.getSiteTypeEnum(), site);
//        }
//        Cell newCell = socket_design.copyCell(c, c.getName().substring(prefixName.length() + 1));

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
        for (String siteWire : newSI.getSiteWiresFromNet(vccNet)) {
          if (!origSI.getSiteWiresFromNet(vccNet).contains(siteWire)) {
            invalidSiteWires.add(siteWire);
          }
        }
        toRemoveSiteWireMap.put(newSI, invalidSiteWires);
      }
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

//    EDIFNet logicalClk1Net = top1.getNet("clk_out_o1");
//    EDIFNet logicalClk2Net = top1.getNet("clk_h");
//    Net physClk1Net = socket_design.createNet("clk_out_o1", logicalClk1Net);
//    Net physClk2Net = socket_design.createNet("clk_h", logicalClk2Net);

    EDIFNet logicalClk1Net = top1.getNet("f_clk");
    EDIFNet logicalClk2Net = top1.getNet("clk");
    Net physClk1Net = socket_design.createNet("f_clk");
    Net physClk2Net = socket_design.createNet("clk");

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
        if (net.getType() == NetType.GND)
          newNet = gndNet;
        else
          newNet = vccNet;
        //newNet = socket_design.getNet(net.getName());
      } else if (net.getName().contains(prefixName)) {
        newNet = socket_design.createNet(net.getName().substring(prefixName.length() + 1));
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

          SiteInst newSI  = socket_design.getSiteInstFromSite(origSI.getSite());
          if (newSI == null)
            newSI = socket_design.createSiteInst(origSI.getName(),
                                               origSI.getSiteTypeEnum(),
                                               origSI.getSite());
          for (SitePIP spip : origSI.getUsedSitePIPs()) {
            newSI.addSitePIP(spip);
          }

          SitePinInst newSpi = newNet.createPin(spi.getName(), newSI);
          newSpi.setSiteInst(newSI);
        }
      }

      for (SiteInst origSI : net.getSiteInsts()) {
        ClockRegion cr = origSI.getTile().getClockRegion();
        if (!isCRValid(cr, designId))
          continue;

        SiteInst newSI  = socket_design.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = socket_design.createSiteInst(origSI.getName(),
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
              //System.out.println("Route " + output.getName() + " ---> " + input + " for " + newSI + " " + routeStatus);
            }
          }
        }
      }

      for (PIP pip : net.getPIPs()) {
        if (!IsClockNet) {
        if (pip.getTile().getName().contains("INT_X") && !isTileValid(pip.getTile(), designId)) {
          System.out.println("[WARNING] Outside PIP " + pip + " from net " + net);
          continue;
        }

        ClockRegion cr = pip.getTile().getClockRegion();
        if (!isCRValid(cr, designId))
          continue;
        }

        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;

        pipSet.add(pip);
      }

      for (PIP pip : pipSet) {
        newNet.addPIP(pip);
      }
    }

    HashSet<PIP> toRemovePIPs = new HashSet<>();
    PIP clkPIP = dev.getPIP("CLK_REBUF_BUFGS_HSR_CORE_X31Y0/CLK_REBUF_BUFGS_HSR_CORE.CLK_BUFGCE_33_O_PIN->>CLK_BUFGCE_33_O"); // Clk Track 11
    //PIP clkPIP = dev.getPIP("CLK_REBUF_BUFGS_HSR_CORE_X19Y0/CLK_REBUF_BUFGS_HSR_CORE.CLK_BUFGCE_48_O_PIN->>CLK_BUFGCE_48_O"); // Clk Track 17
    System.out.println("clkPIP " + clkPIP);
    int cnt = 1;

    //while (!clkPIP.getTile().getName().contains("CLK_VNOC_BBA_TILE")) {
    //while (cnt == 1) {
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

    for (PIP pip : toRemovePIPs) {
      //System.out.println("toRemove PIP " + pip);
      //socket_design.getNet("clk_out_o1").removePIP(pip);
      socket_design.getNet("f_clk").removePIP(pip);
    }

    if (designId == 3)
      //socket_design.getNet("clk_out_o1").removePIP(dev.getPIP("CLK_REBUF_VERT_VNOC_CBA_TILE_X69Y87/CLK_REBUF_VERT_VNOC_CBA_TILE.IF_WRAP_CLK_V_TOP_CLK_VROUTE11<<->>IF_WRAP_CLK_V_BOT_CLK_VROUTE11"));
      socket_design.getNet("f_clk").removePIP(dev.getPIP("CLK_REBUF_VERT_VNOC_CBA_TILE_X69Y87/CLK_REBUF_VERT_VNOC_CBA_TILE.IF_WRAP_CLK_V_TOP_CLK_VROUTE11<<->>IF_WRAP_CLK_V_BOT_CLK_VROUTE11"));

    Map<Site, SiteConfig> socketBELAttrs = design.getBELAttrs();
    for (Map.Entry<Site, SiteConfig> entry0 : socketBELAttrs.entrySet()) {
      Site site = entry0.getKey();
      SiteTypeEnum type = site.getSiteTypeEnum();
      SiteConfig siteConfig = entry0.getValue();
      for (Map.Entry<BEL, Map<String, BELAttr>> entry1 : siteConfig.getBELAttributes().entrySet()) {
        BEL bel = entry1.getKey();
        for (Map.Entry<String, BELAttr> entry2 : entry1.getValue().entrySet()) {
          String name = entry2.getKey();
          BELAttr belAttr = entry2.getValue();

          //System.out.println("CHECK " + site + " " + belAttr.getNet() + " " + bel + " " + name + " " + belAttr.getValue() + " " + belAttr.getName());
          Net belAttrNet = null;
          if (belAttr.getNet().getName().equals(clock1NetName))
            belAttrNet = physClk1Net;
          else if (belAttr.getNet().getName().equals(clock2NetName))
            belAttrNet = physClk2Net;
          else {
            //System.out.println(belAttr.getNet());
            belAttrNet = socket_design.getNet(belAttr.getNet().getName().substring(prefixName.length() + 1));
          }
          socket_design.addBELAttr(belAttrNet, site, type, bel, name, belAttr.getValue());
        }
      }
    }


//    Cell mbufgCell = socket_design.createAndPlaceCell(
//      socket_netlist.getTopCell(),
//      "MBUFGCE_inst", Unisim.MBUFGCE,
//      dev.getSite("BUFGCE_X3Y17"),
//      dev.getSite("BUFGCE_X3Y17").getBEL("BUFCE"));
//
//    EDIFCellInst mbufgECI = mbufgCell.getEDIFCellInst();
//    EDIFCell mbufgEC = mbufgECI.getCellType();
//    mbufgCell.addProperty("IS_CE_INVERTED", 0);
//    mbufgCell.addProperty("IS_I_INVERTED", 0);
//    mbufgCell.addProperty("MODE", "PERFORMANCE");
//
//    EDIFNet mbufgceClrnLNet = socket_netlist.getTopCell().getNet("mbufgce_clr_n");
//
//    logicalClk1Net.createPortInst(mbufgEC.getPort("O1"), mbufgECI);
//    logicalClk2Net.createPortInst(mbufgEC.getPort("O2"), mbufgECI);
//    mbufgceClrnLNet.createPortInst(mbufgEC.getPort("CLRB_LEAF"), mbufgECI);
//
//    SitePinInst mbufgOSPI = socket_design.getNet("clk_out_o1").createPin("O", mbufgCell.getSiteInst());
//
//    EDIFPort clkTopPort = socket_netlist.getTopCell().createPort("clk_top", EDIFDirection.INPUT, 1);
//    EDIFNet clkTopENet = socket_netlist.getTopCell().createNet(clkTopPort.getName());
//    clkTopENet.createPortInst(clkTopPort);
//    clkTopENet.createPortInst(mbufgEC.getPort("I"), mbufgECI);
//
//    System.out.println(physClk1Net + " " + physClk1Net.getSiteInsts().size() + " " + physClk1Net.getPIPs().size());
//    System.out.println(physClk2Net + " " + physClk2Net.getSiteInsts().size() + " " + physClk2Net.getPIPs().size());

    socket_design.writeCheckpoint("../checkpoints/socket_rw_full_v" + designId + ".dcp");
    EDIFTools.writeEDIFFile("../checkpoints/socket_rw_full_v" + designId + ".edf", socket_netlist, socket_design.getPart().getName());

    t.stop();
    System.out.println("Done.");
  }
}
