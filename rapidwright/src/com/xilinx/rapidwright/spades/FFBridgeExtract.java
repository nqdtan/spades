
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

public class FFBridgeExtract {
  public static String prefixName = "design_1_i/ff_bridge_0/inst";

  public static Cell copyCellCustom(Design d, EDIFNetlist nl, Cell c) {
    SiteInst origSI = c.getSiteInst();
    Site site = origSI.getSite();
    SiteInst newSI = d.getSiteInst(site.getName());
    if (newSI == null) {
      newSI = d.createSiteInst(site.getName(), origSI.getSiteTypeEnum(), site);
    }

//    EDIFCellInst ref = c.getEDIFCellInst();
//    EDIFLibrary lib  = nl.getLibrary("work");
//
//    if (ref.getParentCell().getLibrary().getName().contains("primitives"))
//      lib = nl.getLibrary("hdi_primitives");
//    EDIFCell parentCell = lib.getCell(ref.getParentCell().getName());
//    if (parentCell == null) {
//      parentCell = new EDIFCell(lib, ref.getParentCell().getName());
//    }
//
//    EDIFCellInst newEci = parentCell.getCellInst(ref.getName());
//    if (newEci == null) {
//      newEci = new EDIFCellInst(ref.getName(), ref.getCellType(), parentCell);
//    }
//
//    EDIFTools.ensureCellInLibraries(nl, ref.getCellType());
//    newEci.setPropertiesMap(ref.getPropertiesMap());
//
//    String origBELName = c.getBEL().getName();
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
    CodePerfTracker t = new CodePerfTracker("ff_bridge Extract");
    t.start("ff_bridge Extract");

    int designId = 0;

    // Extract the socket region to a new design checkpoint
    Design design = Design.readCheckpoint("../checkpoints/socket_cc.dcp", "../checkpoints/socket_cc.edf");
    EDIFNetlist netlist = design.getNetlist();

    Device dev = design.getDevice();
    EDIFCell top = netlist.getTopCell();

//    EDIFCell ff_bridge_cell = netlist.getCell("design_1_ff_bridge_0_0");
    EDIFCell ff_bridge_cell = null;
    for (EDIFCellInst eci : netlist.getCell("design_1_ff_bridge_0_0").getCellInsts()) {
      ff_bridge_cell = eci.getCellType();
      break;
    }

    Design ff_bridge_design = new Design("ff_bridge_ex", design.getDevice().getName());
    ff_bridge_design.setAutoIOBuffers(false);
    EDIFNetlist ff_bridge_netlist = ff_bridge_design.getNetlist();

    EDIFCell top1 = ff_bridge_netlist.getTopCell();
    EDIFLibrary plib = ff_bridge_netlist.getLibrary("hdi_primitives");
    EDIFLibrary wlib = ff_bridge_netlist.getLibrary("work");

    ff_bridge_netlist.cloneNetlistFromTopCell(ff_bridge_cell, top1);

    Net vccNet = ff_bridge_design.createNet("GLOBAL_LOGIC1");
    Net gndNet = ff_bridge_design.createNet("GLOBAL_LOGIC0");
    EDIFNet gnd = EDIFTools.getStaticNet(NetType.GND, top1, ff_bridge_design.getNetlist());
    Net const0Net = ff_bridge_design.createNet(gnd.getName());
    EDIFNet pwr = EDIFTools.getStaticNet(NetType.VCC, top1, ff_bridge_design.getNetlist());
    Net const1Net = ff_bridge_design.createNet(pwr.getName());

    HashMap<SiteInst, HashSet<String>> toRemoveSiteWireMap = new HashMap<>();

    boolean check = false;
    for (Cell c : design.getCells()) {
      if (c.getName().contains(prefixName)) {
        Cell newCell = copyCellCustom(ff_bridge_design, ff_bridge_netlist, c);
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

    HashSet<SiteInst> siSet = new HashSet<>();
    for (Cell cell : ff_bridge_design.getCells()) {
      siSet.add(cell.getSiteInst());
//      EDIFCellInst eci = cell.getEDIFCellInst();
//      System.out.println(eci);
//      for (EDIFPortInst epi : eci.getPortInsts()) {
//        System.out.println("--- " + epi + " "+ epi.getNet());
//      }
    }

    HashMap<Net, HashSet<PIP>> pipMap = new HashMap<>();
    HashMap<Pair<Cell, Boolean>, HashSet<Cell>> cellMap = new HashMap<>();

    int netCount = 0;
    for (Net net : design.getNets()) {
//      boolean ValidNet = false;
//      for (SiteInst origSI : net.getSiteInsts()) {
//        for (SiteInst si : siSet) {
//          if (origSI.getSite().equals(si.getSite())) {
//            ValidNet = true;
//            break;
//          }
//        }
//
//        if (ValidNet)
//          break;
//      }
//
//      if (!ValidNet)
//        continue;

      EDIFHierNet ehnet = net.getLogicalHierNet();
      if (ehnet == null)
        continue;

      String cellId = "";
      boolean IsOutput = false;
      boolean ValidNet = false;
      //System.out.println("Net " + net + " " + net.getPIPs().size() + " " + ehnet);
      Cell ffbCell = null;
      HashSet<Cell> connCells = new HashSet<>();
      for (EDIFHierPortInst ehpi : ehnet.getLeafHierPortInsts()) {
        if (ehpi == null)
          continue;

        if (ehpi.getPhysicalCell(design).getName().contains("cell_a")) {
          ValidNet = true;
          cellId = ehpi.getPhysicalCell(design).getName().substring("design_1_i/ff_bridge_0/inst/cell_a".length());
          IsOutput = ehpi.isOutput();
          ffbCell = ehpi.getPhysicalCell(design);
        } else
          connCells.add(ehpi.getPhysicalCell(design));
      }
      if (ffbCell != null && connCells.size() != 0)
        cellMap.put(new Pair<>(ffbCell, IsOutput), connCells);

      if (!ValidNet)
        continue;

      //System.out.println("Net " + net + " " + cellId + " " + IsOutput);
      Net newNet;
      boolean IsClockNet = false;
      if (net.getName().equals("ff_bridge_clk")) {
        newNet = ff_bridge_design.createNet("clk0");
        IsClockNet = true;
      } else if (IsOutput) {
        newNet = ff_bridge_design.createNet("net_a" + cellId);
      } else {
        newNet = ff_bridge_design.createNet("net_b" + cellId);
      }

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());

      for (SitePinInst spi : net.getPins()) {
        //System.out.println("--- spi " + spi + " " + spi.getBELPin() + " " + spi.getBELPin().getSourcePin());
        SiteInst origSI = spi.getSiteInst();
        SiteInst newSI  = ff_bridge_design.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = ff_bridge_design.createSiteInst(origSI.getName(),
                                             origSI.getSiteTypeEnum(),
                                             origSI.getSite());
        for (SitePIP spip : origSI.getUsedSitePIPs()) {
          newSI.addSitePIP(spip);
        }

        SitePinInst newSpi = newNet.createPin(spi.getName(), newSI);
        newSpi.setSiteInst(newSI);
      }

      for (SiteInst origSI : net.getSiteInsts()) {
        SiteInst newSI  = ff_bridge_design.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = ff_bridge_design.createSiteInst(origSI.getName(),
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
          //assert outputSet.size() == 1 : "Expect outputSize size to be 1";
          for (BELPin output : outputSet) {
            for (BELPin input : inputSet) {
              boolean routeStatus = newSI.routeIntraSiteNet(newNet, output, input);
              //System.out.println("Route " + output.getName() + " ---> " + input + " for " + newSI + " " + routeStatus);
            }
          }
        }
      }

      for (PIP pip : net.getPIPs()) {
        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;
        pipSet.add(pip);
      }

      for (PIP pip : pipSet) {
        newNet.addPIP(pip);
      }
      //pipMap.put(newNet, pipSet);
    }

    for (Net net : design.getNets()) {
      Net newNet;
      if (net.isStaticNet()) {
        newNet = ff_bridge_design.getNet(net.getName());
      } else {
        continue;
      }

      if (newNet.equals(gndNet))
        continue;

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());

      for (SitePinInst spi : net.getPins()) {
        SiteInst origSI = spi.getSiteInst();
        SiteInst newSI  = ff_bridge_design.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = ff_bridge_design.createSiteInst(origSI.getName(),
                                             origSI.getSiteTypeEnum(),
                                             origSI.getSite());
        for (SitePIP spip : origSI.getUsedSitePIPs()) {
          newSI.addSitePIP(spip);
        }

        SitePinInst newSpi = newNet.createPin(spi.getName(), newSI);
        newSpi.setSiteInst(newSI);
      }

      for (SiteInst origSI : net.getSiteInsts()) {
        SiteInst newSI  = ff_bridge_design.getSiteInstFromSite(origSI.getSite());
        if (newSI == null)
          newSI = ff_bridge_design.createSiteInst(origSI.getName(),
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
          //assert outputSet.size() == 1 : "Expect outputSize size to be 1";
          for (BELPin output : outputSet) {
            for (BELPin input : inputSet) {
              boolean routeStatus = newSI.routeIntraSiteNet(newNet, output, input);
              //System.out.println("Route " + output.getName() + " ---> " + input + " for " + newSI + " " + routeStatus);
            }
          }
        }
      }

      for (PIP pip : net.getPIPs()) {
        // Skip if pip is already there
        if (pipSet.contains(pip))
          continue;
        //System.out.println("Tile " + pip.getTile());
        int tileX = pip.getTile().getTileXCoordinate();
        int tileY = pip.getTile().getTileYCoordinate();
        //if ((tileX >= 62 && tileX <= 64) && (tileY >= 296 && tileY <= 319))
          pipSet.add(pip);
      }

      for (PIP pip : pipSet) {
        newNet.addPIP(pip);
      }
      //pipMap.put(newNet, pipSet);
    }
//    Net stubNet = ff_bridge_design.createNet("stub");
//    for (Map.Entry<Net, HashSet<PIP>> entry : pipMap.entrySet()) {
//      for (PIP pip : entry.getValue()) {
//        if (pip.toString().contains("PIN"))
//          continue;
//        stubNet.addPIP(pip);
//      }
//    }

    for (Map.Entry<Pair<Cell, Boolean>, HashSet<Cell>> entry : cellMap.entrySet()) {
      Cell ffbCell = entry.getKey().getFirst();
      boolean IsOutput = entry.getKey().getSecond();
      HashSet<Cell> connCells = entry.getValue();
      //System.out.println("Cell " + ffbCell + " " + IsOutput);
      String cellId = ffbCell.getName().substring("design_1_i/ff_bridge_0/inst/cell_a".length());
      for (Cell c : connCells) {
        //System.out.println("--> " + c);
        SiteInst origSI = c.getSiteInst();
        Site site = origSI.getSite();
        SiteInst newSI = ff_bridge_design.getSiteInst(site.getName());
        if (newSI == null) {
          newSI = ff_bridge_design.createSiteInst(site.getName(), origSI.getSiteTypeEnum(), site);
        }
        BEL bel = newSI.getBEL(c.getBEL().getName());
        if (!bel.isFF())
          continue;

        //Cell connCell = new Cell("cell_c" + cellId, newSI, bel);
        String locStr = newSI.getSiteName() + "/" + bel.getName();
        Cell connCell = ff_bridge_design.createAndPlaceCell("cell_c" + cellId, Unisim.FDRE, locStr);
        connCell.getEDIFCellInst().setViewref(new EDIFName("FDRE"));
        if (connCell == null)
          System.out.println("Error! Could not place cell cell_c" + cellId);
        EDIFNet aLNet = top1.getNet("net_a" + cellId);
        EDIFNet bLNet = top1.getNet("net_b" + cellId);
        //System.out.println("--> " + connCell + " " + aLNet + " " + bLNet);

        if (IsOutput) {
          aLNet.createPortInst("D", connCell);
        } else {
          bLNet.createPortInst("Q", connCell);
        }

        Net clk0Net = ff_bridge_design.getNet("clk0");
        EDIFNet clk0LNet = clk0Net.getLogicalNet();
        clk0LNet.createPortInst("C", connCell);

        //SitePinInst clk0Spi = clk0Net.createPin("CLK", connCell.getSiteInst());
        connCell.getSiteInst().addSitePIP("CLKINV", "CLK");
        connCell.getSiteInst().routeIntraSiteNet(clk0Net,
          connCell.getSiteInst().getSite().getBEL("CLKINV").getPin("OUT"),
          connCell.getBEL().getPin("CLK"));


      }
    }
//    Net stubNet = ff_bridge_design.getNet("stub");
//    System.out.println(stubNet + " " + stubNet.getPIPs());
//    stubNet.addPIP(dev.getPIP("RCLK_DSP_CORE_X52Y143/RCLK_DSP_CORE.VCC_WIRE->>CLK_LEAF_SITES_36_I"));

    Net stubNet = ff_bridge_design.createNet("stub");
//    EDIFPort stubIPort = top1.createPort("stub_in", EDIFDirection.INPUT, 1);
//    EDIFPort stubOPort = top1.createPort("stub_out", EDIFDirection.OUTPUT, 1);
//    stubLNet.createPortInst(stubIPort);
//    stubLNet.createPortInst(stubOPort);
    stubNet.addPIP(dev.getPIP("RCLK_DSP_CORE_X52Y143/RCLK_DSP_CORE.VCC_WIRE->>CLK_LEAF_SITES_36_I"));
    stubNet.addPIP(dev.getPIP("RCLK_DSP_CORE_X29Y143/RCLK_DSP_CORE.VCC_WIRE->>CLK_LEAF_SITES_36_I"));

    ff_bridge_design.setName("ff_bridge");
    ff_bridge_netlist.changeTopName("ff_bridge");
    ff_bridge_design.writeCheckpoint("../checkpoints/ff_bridge_extracted.dcp");
    EDIFTools.writeEDIFFile("../checkpoints/ff_bridge_extracted.edf", ff_bridge_netlist, ff_bridge_design.getPart().getName());

    t.stop();
    System.out.println("Done.");
  }
}
