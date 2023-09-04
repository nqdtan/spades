
package com.xilinx.rapidwright.spades;

import java.util.*;
import java.util.HashSet;
import java.util.HashMap;

import java.io.BufferedInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.PriorityQueue;

import com.xilinx.rapidwright.design.*;
import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.router.*;

import com.xilinx.rapidwright.design.noc.*;
import com.xilinx.rapidwright.design.noc.*;

import com.xilinx.rapidwright.edif.*;
import com.xilinx.rapidwright.util.*;

import com.xilinx.rapidwright.router.*;

import com.xilinx.rapidwright.tests.CodePerfTracker;

import java.io.File;
import java.nio.file.Files;
import org.json.JSONArray;
import org.json.JSONObject;

public class SpadesFlow {
  public static String fullShellPrefix = "top_i/ulp/"; // FULL BLP (shell DCP)
  public static String partShellPrefix = ""; // ULP_STATIC (ulp_static_mbufgce)
  public static String prefixName = fullShellPrefix + "socket";

  public static int LLCRX = 2;
  public static int LLCRY = 2;
  public static int URCRX = 3;
  public static int URCRY = 2;

  public static int LLCRXSub = 4;
  public static int LLCRYSub = 3;
  public static int URCRXSub = 6;
  public static int URCRYSub = 3;


  public static int socketTileWidth  = 106;
  public static int socketTileHeight = 120;

  public static int getRelocCRX(int xOffset, int llCRX) {
    return llCRX + xOffset;
  }

  public static int getRelocCRY(int yOffset, int llCRY) {
    return llCRY + yOffset;
  }

  public static Tile getRelocTile(Tile t, int relocCRX, int relocCRY, int designId) {
    ClockRegion origCR = t.getClockRegion();
    int colOffset = (relocCRX / 2) * socketTileWidth;
    int rowOffset = (relocCRY / 1) * socketTileHeight;

    return t.getTileNeighbor(colOffset, rowOffset);
  }

  // From rapidwright.router
	public static List<PIP> findRoutingPath(
    RouteNode start, RouteNode end,
    HashSet<Wire> routedWires,
    int startX, int startY) {

		PriorityQueue<RouteNode> q = new PriorityQueue<RouteNode>(16, new Comparator<RouteNode>() {
			public int compare(RouteNode i, RouteNode j) {return i.getCost() - j.getCost();}});
		q.add(start);
		HashSet<Wire> visited = new HashSet<>();
		visited.add(new Wire(start.getTile(), start.getWire()));
	
    ClockRegion cr = end.getTile().getClockRegion();
    int crY = cr.getInstanceY();

		while (!q.isEmpty()) {
			RouteNode curr = q.remove();
			if (curr.equals(end)) {
				return curr.getPIPsBackToSource();
			}

      int nextX = curr.getTile().getTileXCoordinate();
      int nextY = curr.getTile().getTileYCoordinate();

      // FIXME
      if (nextX > startX && (
         (crY == 1 && (nextY < 0 || nextY > 3)) ||
         (crY == 2 && (nextY < 96 || nextY > 99)) ||
         (crY == 3 && (nextY < 192 || nextY > 195)) ||
         (crY == 4 && (nextY < 332 || nextY > 335))))
        continue;

			if (visited.size() > 100000) return null;
			for (Wire w : curr.getConnections()) {
				if (visited.contains(w)) continue;
        if (routedWires.contains(w)) continue;
				visited.add(w);
				RouteNode rn = new RouteNode(w,curr);
				rn.setCost((rn.getManhattanDistance(end) << 1) + rn.getLevel());
				q.add(rn);
			}
		}
		return null;
	}

//  public static void clockRouting(PIP srcPIP, Node snkNode,
//    HashSet<PIP> routedPIPs, ArrayList<PIP> routePath, boolean verbose) {
  public static void clockRouting(PIP srcPIP, Node snkNode,
    HashSet<Wire> routedWires, ArrayList<PIP> routePath, boolean verbose) {
    // TODO: increase maxLevel if unroutable
    int maxLevel = 48;
    ArrayList<PIP> workPath = new ArrayList<>();
    ArrayList<ArrayList<PIP>> workList = new ArrayList<>();
    workList.add(new ArrayList() {{ add(srcPIP); }});
    int curMinLen = 0;

    // Depth-first search
    while (!workList.isEmpty()) {
      if (verbose)
        System.out.println("=== workList size: " + workList.size());
      ArrayList<PIP> currentWork = workList.get(workList.size() - 1);
      if (currentWork.isEmpty()) {
        if (workList.size() == 1)
          break;
        workList.remove(workList.size() - 1);
        PIP removedPIP = workPath.remove(workPath.size() - 1);
        if (verbose)
          System.out.println("[1] Path Undo " + removedPIP);
        continue;
      }

      PIP p0 = currentWork.remove(0);
      if (verbose)
        System.out.println("Check PIP " + p0 + " === Tile " + p0.getTile());
      workPath.add(p0);

      Node enode = p0.getEndNode();
      if (p0.isBidirectional())
        enode = p0.getStartNode();

      if (enode == null) {
        workPath.remove(workPath.size() - 1);
        if (verbose)
          System.out.println("[2] Path Undo " + p0);
        continue;
      }

      if (snkNode.equals(enode)) {
        if (verbose) {
          System.out.println("Found snkNode!");
          System.out.println("***** Path: " + srcPIP + " --> " + snkNode + " length = " + workPath.size());
        }
        if (routePath.size() == 0 || routePath.size() > workPath.size()) {
          routePath.clear();
          routePath.addAll(workPath);
          curMinLen = workPath.size();
        }
        workPath.remove(workPath.size() - 1);
        continue;
      }

      if (curMinLen > 0 && workPath.size() > curMinLen) {
        workPath.remove(workPath.size() - 1);
        if (verbose)
          System.out.println("[4] Path Undo " + p0);
        continue;
      }

      if (workList.size() == maxLevel) {
        if (verbose) {
          System.out.println("Exceed maximum level! Turn back");
          System.out.println("[5] Path Undo " + p0);
        }
        workPath.remove(workPath.size() - 1);
        continue;
      }

      int curDist = enode.getTile().getTileManhattanDistance(snkNode.getTile());
      if (verbose)
        System.out.println("Current mDist = "  + curDist + " from node " + enode);
      ArrayList<PIP> nextPIPs = new ArrayList<PIP>();
      for (PIP p : enode.getAllDownhillPIPs()) {
        //if (routedPIPs.contains(p))
        //  continue;

        if (routedWires.contains(p.getStartWire()) || routedWires.contains(p.getEndWire())) {
          //System.out.println("Existing routed wire for PIP: " + p + ": " + p.getStartWire() + " *** " + p.getEndWire());
          continue;
        }

        // Possible (for bidirectional PIP)
        if (p.equals(p0))
          continue;

        // Possible loop
        if (workPath.contains(p))
          continue;

        // Avoid passing through some unused BUFG BELs
        if (p.toString().contains("I_PIN"))
          continue;

        //if (p.toString().contains("CLK_PD_OPT_DELAY"))
        //  continue;

        int nextDist = p.getEndNode().getTile().getTileManhattanDistance(snkNode.getTile());
        if (verbose)
          System.out.println("Next PIP " + p + " mDist = " + nextDist);

        if (nextDist > curDist)
          continue;
        nextPIPs.add(p);
      }
      if (!nextPIPs.isEmpty()) {
        workList.add(nextPIPs);
      } else {
        workPath.remove(workPath.size() - 1);
        if (verbose)
          System.out.println("[3] Path Undo " + p0);
      }

    }
    assert routePath.size() != 0 : "Unroutable!";

    if (verbose) {
      System.out.println("Routing path: ");
      for (PIP pip : routePath) {
        System.out.println("--> " + pip);
      }
    }
  }

  public static Cell copyCellCustom(Design d, EDIFNetlist nl, Cell c,
                                    int socketId, int relocCROffsetX, int relocCROffsetY, int designId) {
    SiteInst origSI = c.getSiteInst();
    Site origSite = origSI.getSite();
    Site relocSite = origSite.getCorrespondingSite(
      origSI.getSiteTypeEnum(),
      getRelocTile(origSite.getTile(), relocCROffsetX, relocCROffsetY, designId));
    SiteInst newSI = d.getSiteInst(relocSite.getName());
    if (newSI == null) {
      newSI = d.createSiteInst(relocSite.getName(), origSI.getSiteTypeEnum(), relocSite);
    }

    EDIFCellInst ref = c.getEDIFCellInst();
    EDIFLibrary lib  = nl.getLibrary("work_socket" + socketId);
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
    Cell newCell = new Cell(prefixName + socketId + "/" + c.getName(), newSI, relocBEL);
    return newCell;
  }

  public static void copyPhysicalCells(Design srcDesign, Design dstDesign,
    EDIFNetlist dstNetlist,
    int id, int offsetX, int offsetY,
    HashMap<Integer, HashSet<Cell>> nmuAXIMap,
    HashMap<Integer, HashSet<Cell>> nsuAXIMap,
    HashMap<Integer, HashSet<Cell>> nmuAXISMap,
    HashMap<Integer, HashSet<Cell>> nsuAXISMap,
    HashMap<SiteInst, HashSet<String>> toRemoveSiteWireMap, int designId) {

    Net vccNet = dstDesign.getNet("GLOBAL_LOGIC1");
    HashSet<Cell> nmuAXICells = new HashSet<>();
    HashSet<Cell> nsuAXICells = new HashSet<>();
    HashSet<Cell> nmuAXISCells = new HashSet<>();
    HashSet<Cell> nsuAXISCells = new HashSet<>();

    for (Cell c : srcDesign.getCells()) {
      Cell newCell = copyCellCustom(dstDesign, dstNetlist, c,
                                    id, offsetX, offsetY, designId);
      if (newCell == null) {
        System.out.println("Error! Could not place cell " + c.getName());
        System.exit(0);
      }

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

      if (newCell.getBEL() != null) {
        if (newCell.getName().contains("AXI_nmu"))
          nmuAXICells.add(newCell);
        else if (newCell.getName().contains("AXIS_nmu"))
          nmuAXISCells.add(newCell);
        else if (newCell.getName().contains("AXI_nsu"))
          nsuAXICells.add(newCell);
        else if (newCell.getName().contains("AXIS_nsu"))
          nsuAXISCells.add(newCell);
      }
    }
    nmuAXIMap.put(id, nmuAXICells);
    nsuAXIMap.put(id, nsuAXICells);
    nmuAXISMap.put(id, nmuAXISCells);
    nsuAXISMap.put(id, nsuAXISCells);
  }

  public static void copyPhysicalNets(Design srcDesign, Design dstDesign,
                                      Net clk1Net,
                                      Net clk2Net,
                                      String netPrefixName,
                                      int offsetX,
                                      int offsetY,
                                      int designId
                                      ) {
    Device dev = dstDesign.getDevice();
    for (Net net : srcDesign.getNets()) {
      if (net.getName().equals("GLOBAL_USEDNET"))
        continue;

      boolean IsClockNet = false;
      Net newNet = null;
      //if (net.getName().equals("clk_out_o1")) {
      if (net.getName().equals("f_clk")) {
        newNet = clk1Net;
        IsClockNet = true;
      //} else if (net.getName().equals("clk_h")) {
      } else if (net.getName().equals("clk")) {
        newNet = clk2Net;
        IsClockNet = true;
      } else if (net.isStaticNet()) {
        newNet = dstDesign.getNet(net.getName());
      } else {
        newNet = dstDesign.createNet(
          netPrefixName + net.getName());
      }

      assert newNet != null : "Could not find physical net!";

      if (!IsClockNet) {
        for (SitePinInst spi : net.getPins()) {
          SiteInst origSI = spi.getSiteInst();
          Site relocSite = origSI.getSite().getCorrespondingSite(
            origSI.getSiteTypeEnum(),
            getRelocTile(origSI.getSite().getTile(), offsetX, offsetY, designId));
          SiteInst newSI = dstDesign.getSiteInstFromSite(relocSite);
          if (newSI == null)
            newSI = dstDesign.createSiteInst(relocSite.getName(), origSI.getSiteTypeEnum(), relocSite);
          SitePinInst newSpi = newNet.createPin(spi.getName(), newSI);
          newSpi.setSiteInst(newSI);
          for (SitePIP spip : origSI.getUsedSitePIPs()) {
            newSI.addSitePIP(spip);
          }
        }
      }

      for (SiteInst origSI : net.getSiteInsts()) {
        Site relocSite = origSI.getSite().getCorrespondingSite(
          origSI.getSiteTypeEnum(),
          getRelocTile(origSI.getSite().getTile(), offsetX, offsetY, designId));
        SiteInst newSI = dstDesign.getSiteInstFromSite(relocSite);
        if (newSI == null)
          newSI = dstDesign.createSiteInst(relocSite.getName(), origSI.getSiteTypeEnum(), relocSite);

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

      HashSet<PIP> pipSet = new HashSet<>();
      pipSet.addAll(newNet.getPIPs());
      for (PIP pip : net.getPIPs()) {
        Tile relocTile = getRelocTile(pip.getTile(), offsetX, offsetY, designId);
        PIP relocPIP0 = relocTile.getPIP(
          pip.getStartWireIndex(),
          pip.getEndWireIndex());

        PIP relocPIP = new PIP(pip, relocTile);
        assert relocPIP != null : "Could not find relocated PIP!";

        if (relocPIP0 == null) {
          //System.out.println("Found null relocPIP for " + pip + " " + pip.getTile() + " " + relocTile + " from net " + net);
          SitePin sp = pip.getEndNode().getSitePin();
          if (sp == null)
            sp = pip.getStartNode().getSitePin();
          Site si = sp.getSite();
          //System.out.println("Site " + si + " " + si.getSiteIndexInTile() + " " + sp.getPinName());
          // special case
          if (si.getName().contains("GCLK_DELAY")) {
            int y = si.getInstanceY() % 48;
            Site si1 = dev.getSite("GCLK_DELAY_X2Y" + y);
            Node n1 = si1.getConnectedNode(sp.getPinName());
            relocPIP = n1.getAllUphillPIPs().get(0);
            if (pipSet.contains(relocPIP))
              relocPIP = n1.getAllDownhillPIPs().get(0);
            //System.out.println("Resolved relocPIP: " + relocPIP);
          } else
            assert true : "Could not find any relocatable PIP!";
        }

        // Skip if pip is already there
        if (pipSet.contains(relocPIP)) {
          continue;
        }

        pipSet.add(relocPIP);
      }
      newNet.setPIPs(pipSet);
      //if (newNet.getPIPs().size() == 0)
      //  System.out.println("Net " + newNet + " " + newNet.getPIPs().size() + " " + net + " " + net.getPIPs().size());
    }
  }

  public static void main(String[] args) throws FileNotFoundException {
    // Stitch socket and shell (hw_bb_locked + ulp_static)
    String cfgStr = "";
    try {
      cfgStr = Files.readString(new File(args[0]).toPath());
    } catch (IOException ex) {
      System.out.println("Invalid input config file!");
      System.exit(0);
    }

    JSONObject jsoCfg = new JSONObject(cfgStr);
    //System.out.println(jsoCfg);

    // select between full shell (BLP + ULP static) or partial shell (ULP static)
    // non-full shell is for debugging purpose because it loads faster
    boolean FullShell = jsoCfg.getBoolean("FullShell");
    boolean SeparateCCCLFlow = jsoCfg.getBoolean("SeparateCCCLFlow");

    String shellPrefix = fullShellPrefix;
    if (!FullShell) {
      shellPrefix = partShellPrefix;
      prefixName = partShellPrefix + "socket";
    }

    CodePerfTracker t = new CodePerfTracker("Socket Flow");
    t.start("Socket Flow -- Copying cells");

    Design socket_design = null;
    EDIFNetlist socket_netlist;

    HashMap<Integer, Design> socketDesigns = new HashMap<>();

    JSONArray jsoSocketDesigns = jsoCfg.getJSONArray("SocketDesigns");
    for (int i = 0; i < jsoSocketDesigns.length(); i++) {
      JSONObject jsoSocketDesign = jsoSocketDesigns.getJSONObject(i);
      int DesignId = jsoSocketDesign.getInt("DesignId");
      String DcpName = jsoSocketDesign.getString("DcpName");
      Design socketDesignX = Design.readCheckpoint("../checkpoints/" + DcpName + ".dcp",
                                                   "../checkpoints/" + DcpName + ".edf");
      socketDesigns.put(DesignId, socketDesignX);
    }

    // SOCKET <socket_id, design_id, x_offset, y_offset>
    HashMap<Integer, Pair<Integer, Pair<Integer, Integer>>> socketIds = new HashMap<>();
    JSONArray jsoSocketIds = jsoCfg.getJSONArray("SocketIds");
    for (int i = 0; i < jsoSocketIds.length(); i++) {
      JSONObject jsoSocketId = jsoSocketIds.getJSONObject(i);
      int DesignId = jsoSocketId.getInt("DesignId");
      int SocketId = jsoSocketId.getInt("SocketId");
      int XOffset = jsoSocketId.getInt("XOffset");
      int YOffset = jsoSocketId.getInt("YOffset");
      socketIds.put(SocketId, new Pair(DesignId, new Pair(XOffset, YOffset)));
    }

    HashSet<Pair<Pair<Integer, String>, Pair<Integer, String>>> socketAXIConnects = new HashSet<>();
    HashSet<Pair<Pair<Integer, String>, Pair<Integer, String>>> socketAXISConnects = new HashSet<>();
    JSONArray jsoSocketConnects = jsoCfg.getJSONArray("SocketConnects");
    for (int i = 0; i < jsoSocketConnects.length(); i++) {
      JSONObject jsoSocketConnect = jsoSocketConnects.getJSONObject(i);
      int NMUSocketId = jsoSocketConnect.getInt("NMUSocketId");
      int NSUSocketId = jsoSocketConnect.getInt("NSUSocketId");
      String NMUName = jsoSocketConnect.getString("NMUName");
      String NSUName = jsoSocketConnect.getString("NSUName");
      String typeConnect = jsoSocketConnect.getString("Type");
      if (typeConnect.equals("AXIS")) {
        socketAXISConnects.add(new Pair(new Pair(NMUSocketId, NMUName), new Pair(NSUSocketId, NSUName)));
      }
      if (typeConnect.equals("AXI")) {
        socketAXIConnects.add(new Pair(new Pair(NMUSocketId, NMUName), new Pair(NSUSocketId, NSUName)));
      }
    }

    Design shell_design;
    EDIFNetlist shell_netlist;

    // ULP or SHELL (BLP)
    if (FullShell)
      shell_design = Design.readCheckpoint("../checkpoints/shell_static.dcp",
                                           "../checkpoints/shell_static.edf");
    else
      shell_design = Design.readCheckpoint("../checkpoints/ulp_static_rezip.dcp",
                                           "../checkpoints/ulp_static.edf");

    shell_netlist = shell_design.getNetlist();

    Device dev = shell_design.getDevice();

    HashSet<String> toRemoveNOCMasters = new HashSet<>();
    NOCDesign nd = shell_design.getNOCDesign();
    if (FullShell) {
      for (Map.Entry<String, NOCMaster> entry : nd.getMasterClients().entrySet()) {
        if (entry.getKey().contains("M01_INI_stub_nmu") ||
            entry.getKey().contains("M02_INI_stub_nmu")) {
          toRemoveNOCMasters.add(entry.getKey());
        }
      }

      for (String name : toRemoveNOCMasters) {
        nd.getMasterClients().remove(name);
      }

      HashSet<NOCConnection> toRemoveNOCConns = new HashSet<>();
      for (NOCConnection nconn : nd.getAllConnections()) {
        NOCMaster nm = nconn.getSource();
        if (nm.getName().contains("M01_INI_stub_nmu") ||
            nm.getName().contains("M02_INI_stub_nmu"))
          toRemoveNOCConns.add(nconn);
      }
      for (NOCConnection nconn : toRemoveNOCConns) {
        nd.getAllConnections().remove(nconn);
      }
    }

    EDIFCell top     = shell_netlist.getTopCell();
    EDIFLibrary plib = shell_netlist.getLibrary("hdi_primitives");
    EDIFLibrary wlib = shell_netlist.getLibrary("work");
    if (!FullShell)
      wlib = shell_netlist.getLibrary("work_ulp");

    Net mbufgceClrnNets[] = new Net [12];
    PIP mbufgceClrnSrcPIPs[] = new PIP [12];
    for (int i = 0; i < 12; i++) {
      mbufgceClrnNets[i] = shell_design.getNet(shellPrefix + "socket_manager_0/inst/control/mbufgce_clr_reg/mbufgce" + i + "_clr_n");
    }

    for (int i = 0; i < 12; i++) {
      EDIFPortInst epi0 = null;
      EDIFCellInst eci0 = null;

      for (EDIFPortInst epi : mbufgceClrnNets[i].getLogicalNet().getPortInsts()) {
        EDIFCellInst eci = epi.getCellInst();
        if (eci == null)
          continue;

        if (epi.getName().equals("O") && eci.getName().equals("mbufgce" + i + "_clr_n_INST_0")) {
          epi0 = epi;
          eci0 = eci;
          break;
        }
      }

      for (Cell c : shell_design.getCells()) {
        EDIFCellInst eci = c.getEDIFCellInst();
        if (eci == null)
          continue;
        if (eci.equals(eci0)) {
          BELPin bp = c.getBELPin(epi0);
          mbufgceClrnSrcPIPs[i] = bp.getExternalNode(c.getSite()).getAllDownhillPIPs().get(0);
        }
      }
    }

    PIP mbufgceClkO1PIPs[] = new PIP [12];
    EDIFCell mbufgceEC = shell_netlist.getCell("ulp_mbufgce_primitive_0_1");

    EDIFCell ulpEC;

    if (FullShell) {
      EDIFCellInst top_i = top.getCellInst("top_i");
      EDIFCellInst ulp = top_i.getCellType().getCellInst("ulp");
      ulpEC = ulp.getCellType();
    } else
      ulpEC = top; // for ULP

    Net mbufgceClk1Nets[] = new Net [12];
    Net mbufgceClk2Nets[] = new Net [12];
    EDIFNet mbufgceClrnLNets[] = new EDIFNet [12];
    EDIFNet mbufgceClk1LNets[] = new EDIFNet [12];
    EDIFNet mbufgceClk2LNets[] = new EDIFNet [12];

    for (int i = 0; i < 12; i++) {
      mbufgceClk1Nets[i] = shell_design.getNet(shellPrefix + "mbufgce_primitive_" + i + "/inst/clk_out_o1");
      mbufgceClk2Nets[i] = shell_design.getNet(shellPrefix + "mbufgce_primitive_" + i + "/inst/clk_out_o2");

      mbufgceClrnLNets[i] = ulpEC.getNet("socket_manager_0_mbufgce" + i + "_clr_n");
      EDIFPortInst epi0 = null;
      EDIFCellInst eci0 = null;
      for (EDIFPortInst epi : mbufgceClk1Nets[i].getLogicalNet().getPortInsts()) {
        EDIFCellInst eci = epi.getCellInst();
        if (epi.getName().equals("O1") && eci.getName().equals("MBUFGCE_inst")) {
          epi0 = epi;
          eci0 = eci;
          break;
        }
      }
 
      for (Cell c : shell_design.getCells()) {
        EDIFCellInst eci = c.getEDIFCellInst();
        if (eci == null)
          continue;
        if (eci.equals(eci0)) {
          BELPin bp = c.getBELPin(epi0);
          mbufgceClkO1PIPs[i] = bp.getExternalNode(c.getSite()).getAllDownhillPIPs().get(0);
        }
      }

      EDIFCell tmp1EC = shell_netlist.getCellInstFromHierName(shellPrefix + "mbufgce_primitive_" + i).getCellType();
      EDIFCell tmp0EC = tmp1EC.getCellInsts().iterator().next().getCellType();

      EDIFNet tmp1Clk1LNet = tmp1EC.createNet("clk_out" + i + "_o1");
      tmp1Clk1LNet.createPortInst(tmp0EC.getPort("clk_out_o1"), tmp1EC.getCellInst("inst"));
      tmp1Clk1LNet.createPortInst(tmp1EC.getPort("clk_out_o1"));
      EDIFNet tmp1Clk2LNet = tmp1EC.createNet("clk_out" + i + "_o2");
      tmp1Clk2LNet.createPortInst(tmp0EC.getPort("clk_out_o2"), tmp1EC.getCellInst("inst"));
      tmp1Clk2LNet.createPortInst(tmp1EC.getPort("clk_out_o2"));

      mbufgceClk1LNets[i] = ulpEC.createNet("clk_out" + i + "_o1");
      mbufgceClk2LNets[i] = ulpEC.createNet("clk_out" + i + "_o2");
      mbufgceClk1LNets[i].createPortInst(tmp1EC.getPort("clk_out_o1"), ulpEC.getCellInst("mbufgce_primitive_" + i));
      mbufgceClk2LNets[i].createPortInst(tmp1EC.getPort("clk_out_o2"), ulpEC.getCellInst("mbufgce_primitive_" + i));
    }


    int numSockets = socketIds.size();
    for (Map.Entry<Integer, Pair<Integer, Pair<Integer, Integer>>> entry0 : socketIds.entrySet()) {
      int i = entry0.getKey();
      int designId = entry0.getValue().getFirst();
      int relocCROffsetX = entry0.getValue().getSecond().getFirst();
      int relocCROffsetY = entry0.getValue().getSecond().getSecond();

      socket_design = socketDesigns.get(designId);
      socket_netlist = socket_design.getNetlist();

      shell_netlist.addLibrary(new EDIFLibrary("work_socket" + i));
      EDIFCell ulpSocketLCell = new EDIFCell(shell_netlist.getLibrary("work_socket" + i), "socket" + i);

      shell_netlist.cloneNetlistFromTopCell(socket_netlist.getTopCell(), ulpSocketLCell);

      ulpSocketLCell.setView("socket" + i);
      EDIFCellInst socketECI = new EDIFCellInst("socket" + i, ulpSocketLCell, ulpEC);
      socketECI.setViewref(ulpSocketLCell.getEDIFView());

      mbufgceClk1LNets[i].createPortInst(ulpSocketLCell.getPort("f_clk"), socketECI);
      mbufgceClk2LNets[i].createPortInst(ulpSocketLCell.getPort("clk"), socketECI);

      Map<Site, SiteConfig> socketBELAttrs = socket_design.getBELAttrs();
      for (Map.Entry<Site, SiteConfig> entry : socketBELAttrs.entrySet()) {
        Site site = entry.getKey();
        SiteTypeEnum type = site.getSiteTypeEnum();
        Site relocSite = site.getCorrespondingSite(
          type,
          getRelocTile(site.getTile(), relocCROffsetX, relocCROffsetY, designId));

        SiteConfig siteConfig = entry.getValue();
        for (Map.Entry<BEL, Map<String, BELAttr>> entry1 : siteConfig.getBELAttributes().entrySet()) {
          BEL bel = entry1.getKey();
          for (Map.Entry<String, BELAttr> entry2 : entry1.getValue().entrySet()) {
            String name = entry2.getKey();
            BELAttr belAttr = entry2.getValue();

            Net belAttrNet = null;
            if (belAttr.getNet().getName().contains("f_clk"))
              belAttrNet = mbufgceClk1Nets[i];
            else
              belAttrNet = mbufgceClk2Nets[i];
            shell_design.addBELAttr(belAttrNet, relocSite, type, bel, name, belAttr.getValue());
          }
        }
      }
    }

    // Rearrange the libraries to make sure that the work_socket libs appear first
    EDIFLibrary workUlpLib = shell_netlist.getLibrary("work_ulp");
    EDIFLibrary workLib = shell_netlist.getLibrary("work");
    shell_netlist.removeLibrary("work_ulp");
    shell_netlist.removeLibrary("work");
    shell_netlist.addLibrary(workUlpLib);
    if (FullShell)
      shell_netlist.addLibrary(workLib);

    Net vccNet = shell_design.getNet("GLOBAL_LOGIC1");

    HashSet<String> ddrmcNames = new HashSet<>();
    HashMap<Integer, HashSet<Cell>> socketAXINMUs = new HashMap<>();
    HashMap<Integer, HashSet<Cell>> socketAXINSUs = new HashMap<>();
    HashMap<Integer, HashSet<Cell>> socketAXISNMUs = new HashMap<>();
    HashMap<Integer, HashSet<Cell>> socketAXISNSUs = new HashMap<>();

    Cell socketManagerNMUCell = null;
    Cell socketManagerNSUCell = null;

    for (Cell c : shell_design.getCells()) {
      if (c.getName().contains("u_ddrmc_main")) {
        ddrmcNames.add(c.getName());
      } else if (c.getName().contains("ulp/axi_noc_kernel0/inst/S00_AXI_nmu") &&
                 c.getBEL().getName().contains("NMU")) {
        socketManagerNMUCell = c;
      } else if (c.getName().contains("ulp/axi_noc_h2c/inst/M01_AXI_nsu") &&
                 c.getBEL().getName().contains("NSU")) {
        socketManagerNSUCell = c;
      }
    }

    if (FullShell) {
      assert socketManagerNMUCell != null : "Could not find socket_manager NMU NOC cell!";
      assert socketManagerNSUCell != null : "Could not find socket_manager NSU NOC cell!";
    }

    HashMap<SiteInst, HashSet<String>> toRemoveSiteWireMap = new HashMap<>();
    for (Map.Entry<Integer, Pair<Integer, Pair<Integer, Integer>>> entry0 : socketIds.entrySet()) {
      int socketId = entry0.getKey();
      int designId = entry0.getValue().getFirst();
      int relocCROffsetX = entry0.getValue().getSecond().getFirst();
      int relocCROffsetY = entry0.getValue().getSecond().getSecond();

      socket_design = socketDesigns.get(designId);
      socket_netlist = socket_design.getNetlist();

      copyPhysicalCells(socket_design, shell_design, shell_netlist,
                        socketId, relocCROffsetX, relocCROffsetY,
                        socketAXINMUs, socketAXINSUs,
                        socketAXISNMUs, socketAXISNSUs,
                        toRemoveSiteWireMap, designId);

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

    // NOC Connectivity Builder
    // Setup NOC Traffic for socket cells
    if (FullShell) {
      int axiDataWidth = 512;

      HashMap<Integer, HashSet<NOCMaster>> nocMasterAXIMap = new HashMap<>();
      HashMap<Integer, HashSet<NOCSlave>> nocSlaveAXIMap = new HashMap<>();
      HashMap<Integer, HashSet<NOCMaster>> nocMasterAXISMap = new HashMap<>();
      HashMap<Integer, HashSet<NOCSlave>> nocSlaveAXISMap = new HashMap<>();

      for (Map.Entry<Integer, HashSet<Cell>> entry : socketAXINMUs.entrySet()) {
        int socketId = entry.getKey();
        HashSet<Cell> nmuCells = entry.getValue();
        HashSet<NOCMaster> nmus = new HashSet<>();
        for (Cell c : nmuCells) {
          //System.out.println("NMU-AXI Cell " + c + " from socket " + socketId);
          JSONObject jsobj = new JSONObject();
          jsobj.put("Name", c.getName());
          jsobj.put("IsMaster", true);
          jsobj.put("CompType", "PL_NMU");
          jsobj.put("Protocol", "AXI_MM");
          jsobj.put("ReadTC", "BE");
          jsobj.put("WriteTC", "BE");
          jsobj.put("AxiDataWidth", axiDataWidth);
          NOCMaster nocMaster = new NOCMaster(jsobj);
          nocMaster.setLocation(c.getSite().getName());
          nd.getMasterClients().put(nocMaster.getName(), nocMaster);
          nmus.add(nocMaster);
        }
        nocMasterAXIMap.put(socketId, nmus);
      }

      long sysAddrBase = 0x20100000000L;
      long sysAddrSize = 0x40000000L;
      for (Map.Entry<Integer, HashSet<Cell>> entry : socketAXINSUs.entrySet()) {
        int socketId = entry.getKey();
        HashSet<Cell> nmuCells = entry.getValue();
        HashSet<NOCSlave> nsus = new HashSet<>();
        for (Cell c : nmuCells) {
          //System.out.println("NSU-AXI Cell " + c + " from socket " + socketId);
          JSONObject jsobj = new JSONObject();
          jsobj.put("Name", c.getName());
          jsobj.put("IsMaster", false);
          jsobj.put("CompType", "PL_NSU");
          jsobj.put("Protocol", "AXI_MM");
          jsobj.put("AxiDataWidth", axiDataWidth);
          JSONArray jsarr = new JSONArray();
          JSONObject jsobj1 = new JSONObject();
          jsobj1.put("Base", "0x" + Long.toHexString(sysAddrBase));
          jsobj1.put("Size", "0x" + Long.toHexString(sysAddrSize));
          jsarr.put(jsobj1);
          jsobj.put("SysAddresses", jsarr);
          NOCSlave nocSlave = new NOCSlave(jsobj);
          nocSlave.setLocation(c.getSite().getName());
          nd.getSlaveClients().put(nocSlave.getName(), nocSlave);
          sysAddrBase += sysAddrSize;
          // Skip this address since it overlaps with other clients in the shell
          if (sysAddrBase == 0x20200000000L)
            sysAddrBase += sysAddrSize;
          nsus.add(nocSlave);
        }
        nocSlaveAXIMap.put(socketId, nsus);
      }

      for (Map.Entry<Integer, HashSet<Cell>> entry : socketAXISNMUs.entrySet()) {
        int socketId = entry.getKey();
        HashSet<Cell> nocCells = entry.getValue();
        HashSet<NOCMaster> nmus = new HashSet<>();
        for (Cell c : nocCells) {
          //System.out.println("NMU-AXIS Cell " + c + " from socket " + socketId);
          JSONObject jsobj = new JSONObject();
          jsobj.put("Name", c.getName());
          jsobj.put("IsMaster", true);
          jsobj.put("CompType", "PL_NMU");
          jsobj.put("Protocol", "AXI_STRM");
          jsobj.put("AxiDataWidth", 256);
          jsobj.put("SysAddresses", new JSONArray());
          jsobj.put("ReadTC", "BE");
          jsobj.put("WriteTC", "BE");

          NOCMaster nocMaster = new NOCMaster(jsobj);
          nocMaster.setLocation(c.getSite().getName());
          nd.getMasterClients().put(nocMaster.getName(), nocMaster);
          nmus.add(nocMaster);
        }
        nocMasterAXISMap.put(socketId, nmus);
      }

      for (Map.Entry<Integer, HashSet<Cell>> entry : socketAXISNSUs.entrySet()) {
        int socketId = entry.getKey();
        HashSet<Cell> nocCells = entry.getValue();
        HashSet<NOCSlave> nsus = new HashSet<>();
        for (Cell c : nocCells) {
          //System.out.println("NSU-AXIS Cell " + c + " from socket " + socketId);
          JSONObject jsobj = new JSONObject();
          jsobj.put("Name", c.getName());
          jsobj.put("IsMaster", false);
          jsobj.put("CompType", "PL_NSU");
          jsobj.put("Protocol", "AXI_STRM");
          jsobj.put("AxiDataWidth", 256);
          jsobj.put("SysAddresses", new JSONArray());

          NOCSlave nocSlave = new NOCSlave(jsobj);
          nocSlave.setLocation(c.getSite().getName());
          nd.getSlaveClients().put(nocSlave.getName(), nocSlave);
          nsus.add(nocSlave);
        }
        nocSlaveAXISMap.put(socketId, nsus);
      }

      for (Pair<Pair<Integer, String>, Pair<Integer, String>> pair : socketAXIConnects) {
        Pair<Integer, String> socketNMU = pair.getFirst();
        Pair<Integer, String> socketNSU = pair.getSecond();

        int socketNMUId = socketNMU.getFirst();
        String socketNMUName = socketNMU.getSecond();
        int socketNSUId = socketNSU.getFirst();
        String socketNSUName = socketNSU.getSecond();
        NOCMaster nmu = null;
        for (NOCMaster noc : nocMasterAXIMap.get(socketNMUId)) {
          if (noc.getName().contains(socketNMUName + "_AXI_nmu")) {
            nmu = noc;
            break;
          }
        }
        NOCSlave nsu = null;
        if (nocSlaveAXIMap.containsKey(socketNSUId)) {
          for (NOCSlave noc : nocSlaveAXIMap.get(socketNSUId)) {
            if (noc.getName().contains(socketNSUName + "_AXI_nsu")) {
              nsu = noc;
              break;
            }
          }
        }
        //System.out.println("Build NOC Connection " + nmu + " --> " + nsu + "(" + socketNSUId + ")");
        if (socketNSUId == 28) {
          // --> DDRMC
          for (String ddrmcName : ddrmcNames) {
            JSONObject jsobj = new JSONObject();
            jsobj.put("Phase", 0);
            jsobj.put("From", nmu.getName());
            jsobj.put("To", ddrmcName);
            jsobj.put("Port", "PORT" + socketNSUName);
            jsobj.put("CommType", "MM_ReadWrite");
            jsobj.put("ReadBW", 800);
            jsobj.put("ReadLatency", 300);
            jsobj.put("ReadAvgBurst", 4);
            jsobj.put("WriteBW", 800);
            jsobj.put("WriteLatency", 300);
            jsobj.put("WriteAvgBurst", 4);
            NOCConnection nocConn = new NOCConnection(jsobj, nd);
            nd.getAllConnections().add(nocConn);
          }
        } else {
          JSONObject jsobj = new JSONObject();
          jsobj.put("Phase", 0);
          jsobj.put("From", nmu.getName());
          jsobj.put("To", nsu.getName());
          jsobj.put("Port", "PORT0");
          jsobj.put("CommType", "MM_ReadWrite");
          jsobj.put("ReadBW", 5);
          jsobj.put("ReadLatency", 300);
          jsobj.put("ReadAvgBurst", 4);
          jsobj.put("WriteBW", 5);
          jsobj.put("WriteLatency", 300);
          jsobj.put("WriteAvgBurst", 4);
          NOCConnection nocConn = new NOCConnection(jsobj, nd);
          nd.getAllConnections().add(nocConn);
        }
      }

      // --> socket_manager
      for (Map.Entry<Integer, HashSet<NOCMaster>> entry : nocMasterAXIMap.entrySet()) {
        for (NOCMaster nmu : entry.getValue()) {
          if (nmu.getName().contains("S00_AXI_nmu")) { 
            JSONObject jsobj = new JSONObject();
            jsobj.put("Phase", 0);
            jsobj.put("From", nmu.getName());
            jsobj.put("To", socketManagerNSUCell.getName());
            jsobj.put("Port", "PORT0");
            jsobj.put("CommType", "MM_ReadWrite");
            jsobj.put("ReadBW", 5);
            jsobj.put("ReadLatency", 300);
            jsobj.put("ReadAvgBurst", 4);
            jsobj.put("WriteBW", 5);
            jsobj.put("WriteLatency", 300);
            jsobj.put("WriteAvgBurst", 4);
            NOCConnection nocConn = new NOCConnection(jsobj, nd);
            nd.getAllConnections().add(nocConn);
          }
        }
      }

      // <-- socket_manager
      for (Map.Entry<Integer, HashSet<NOCSlave>> entry : nocSlaveAXIMap.entrySet()) {
        for (NOCSlave nsu : entry.getValue()) {
          if (nsu.getName().contains("M00_AXI_nsu")) { 
            JSONObject jsobj = new JSONObject();
            jsobj.put("Phase", 0);
            jsobj.put("From", socketManagerNMUCell.getName());
            jsobj.put("To", nsu.getName());
            jsobj.put("Port", "PORT0");
            jsobj.put("CommType", "MM_ReadWrite");
            jsobj.put("ReadBW", 5);
            jsobj.put("ReadLatency", 300);
            jsobj.put("ReadAvgBurst", 4);
            jsobj.put("WriteBW", 5);
            jsobj.put("WriteLatency", 300);
            jsobj.put("WriteAvgBurst", 4);
            NOCConnection nocConn = new NOCConnection(jsobj, nd);
            nd.getAllConnections().add(nocConn);
          }
        }
      }

      for (Pair<Pair<Integer, String>, Pair<Integer, String>> pair : socketAXISConnects) {
        Pair<Integer, String> socketNMU = pair.getFirst();
        Pair<Integer, String> socketNSU = pair.getSecond();

        int socketNMUId = socketNMU.getFirst();
        String socketNMUName = socketNMU.getSecond();
        int socketNSUId = socketNSU.getFirst();
        String socketNSUName = socketNSU.getSecond();
        NOCMaster nmu = null;
        for (NOCMaster noc : nocMasterAXISMap.get(socketNMUId)) {
          if (noc.getName().contains(socketNMUName + "_AXIS_nmu")) {
            nmu = noc;
            break;
          }
        }
        NOCSlave nsu = null;
        for (NOCSlave noc : nocSlaveAXISMap.get(socketNSUId)) {
          if (noc.getName().contains(socketNSUName + "_AXIS_nsu")) {
            nsu = noc;
            break;
          }
        }
        System.out.println("Build NOC Connection " + nmu + " --> " + nsu);
        JSONObject jsobj = new JSONObject();
        jsobj.put("Phase", 0);
        jsobj.put("From", nmu.getName());
        jsobj.put("To", nsu.getName());
        jsobj.put("Port", "PORT0");
        jsobj.put("CommType", "STRM");
        jsobj.put("ReadBW", 0);
        jsobj.put("ReadLatency", 0);
        jsobj.put("ReadAvgBurst", 0);
        jsobj.put("WriteBW", 5);
        jsobj.put("WriteLatency", 300);
        jsobj.put("WriteAvgBurst", 4);
        NOCConnection nocConn = new NOCConnection(jsobj, nd);
        nd.getAllConnections().add(nocConn);
      }
    }

    t.stop().printSummary();

    t.start("Socket Flow -- Copying nets");

    for (Map.Entry<Integer, Pair<Integer, Pair<Integer, Integer>>> entry0 : socketIds.entrySet()) {
      int socketId = entry0.getKey();
      int designId = entry0.getValue().getFirst();
      int relocCROffsetX = entry0.getValue().getSecond().getFirst();
      int relocCROffsetY = entry0.getValue().getSecond().getSecond();

      socket_design = socketDesigns.get(designId);
      socket_netlist = socket_design.getNetlist();

      if (designId < 10) {
        if (SeparateCCCLFlow) {
          if (designId == 3) {
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X74Y4/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ2_PIN->>CLE_SLICEL_TOP_0_HQ2"));
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X74Y4/INT.LOGIC_OUTS_W23->>OUT_NN7_BEG3"));
          } else if (designId == 4) {
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X66Y331/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ_PIN->>CLE_SLICEL_TOP_0_HQ"));
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X66Y331/INT.LOGIC_OUTS_W22->>OUT_SS7_BEG3"));
          } else {
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X74Y100/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ2_PIN->>CLE_SLICEL_TOP_0_HQ2"));
            socket_design.getNet("socket_cc_inst/lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X74Y100/INT.LOGIC_OUTS_W23->>OUT_NN7_BEG3"));
          }
        } else {
          if (designId == 3) {
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X74Y4/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ2_PIN->>CLE_SLICEL_TOP_0_HQ2"));
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X74Y4/INT.LOGIC_OUTS_W23->>OUT_NN7_BEG3"));
          } else if (designId == 4) {
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X66Y331/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ_PIN->>CLE_SLICEL_TOP_0_HQ"));
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X66Y331/INT.LOGIC_OUTS_W22->>OUT_SS7_BEG3"));
          } else {
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("CLE_E_CORE_X74Y100/CLE_E_CORE.CLE_SLICEL_TOP_0_HQ2_PIN->>CLE_SLICEL_TOP_0_HQ2"));
            socket_design.getNet("lut1_primitive_0/inst/O").removePIP(dev.getPIP("INT_X74Y100/INT.LOGIC_OUTS_W23->>OUT_NN7_BEG3"));
          }
        }
      }
      copyPhysicalNets(socket_design, shell_design,
                       mbufgceClk1Nets[socketId],
                       mbufgceClk2Nets[socketId], prefixName + socketId + "/",
                       relocCROffsetX,
                       relocCROffsetY, designId);
    }

    HashSet<PIP> allRoutedPIPs = new HashSet<>();
    HashSet<Wire> allRoutedWires = new HashSet<>();

    for (Net net : shell_design.getNets()) { 
      for (PIP pip : net.getPIPs()) {
        allRoutedPIPs.add(pip);
        allRoutedWires.add(pip.getStartWire());
        allRoutedWires.add(pip.getEndWire());
      }
    }

    // Fix NOC cells to assist NOC compiler in routing
    for (Cell c : shell_design.getCells()) {
      if (c.getBEL() != null &&
          (c.getType().equals("NOC_NMU512") || c.getType().equals("NOC_NSU512"))) {
        c.setBELFixed(true);
        c.setSiteFixed(true);
      }
    }
    t.stop().printSummary();

    t.start("Socket Flow -- Clock and Reset routing");
    int startXs[] = new int [12];
    startXs[0]  = 27;
    startXs[1]  = 26;
    startXs[2]  = 27;
    startXs[3]  = 26;
    startXs[4]  = 27;
    startXs[5]  = 27;
    startXs[6]  = 27;
    startXs[7]  = 27;
    startXs[8]  = 26;
    startXs[9]  = 27;
    startXs[10] = 27;
    startXs[11] = 26;

    HashSet<EDIFCell> toRemoveECs = new HashSet<>();
    HashSet<EDIFCellInst> toRemoveECIs = new HashSet<>();
    EDIFCell lut1EC = shell_netlist.getCell("design_1_lut1_primitive_0_0");

    toRemoveECs.add(lut1EC);
    for (EDIFCellInst eci : lut1EC.getCellInsts()) {
      toRemoveECs.add(eci.getCellType());
    }
    for (EDIFCell ec:  toRemoveECs) {
      lut1EC.getLibrary().removeCell(ec);
    }

    HashSet<PIP> routedPIPs = new HashSet<>();
    HashSet<Node> allRoutedEnodes = new HashSet<Node>();
    for (PIP pip : allRoutedPIPs) {
      Node enode = pip.getEndNode();
      allRoutedEnodes.add(enode);
    }


//    shell_netlist.getCell("design_1_lut1_primitive_0_0").getLibrary().removeCell(
//      shell_netlist.getCell("design_1_lut1_primitive_0_0")
//    );

    for (Integer i : socketIds.keySet()) {
      EDIFLibrary socketLib = shell_netlist.getLibrary("work_socket" + i);
      EDIFCell toRemoveEC = null;
      for (EDIFCell ec : socketLib.getCells()) {
        if (ec.getName().contains("design_1_lut1_primitive_0_0")) {
          toRemoveEC = ec;
          break;
        }
      }
      if (toRemoveEC == null)
        continue;
      socketLib.removeCell(toRemoveEC);
    }

    for (Map.Entry<Integer, Pair<Integer, Pair<Integer, Integer>>> entry0 : socketIds.entrySet()) {
      int socketId = entry0.getKey();
      int designId = entry0.getValue().getFirst();
      int relocCROffsetX = entry0.getValue().getSecond().getFirst();
      int relocCROffsetY = entry0.getValue().getSecond().getSecond();

      socket_design = socketDesigns.get(designId);
      socket_netlist = socket_design.getNetlist();

      //String socketName = "top_i/ulp/socket" + socketId;
      String socketName = shellPrefix + "socket" + socketId;
      EDIFCell socketEC = shell_netlist.getCell("socket" + socketId);

      if (designId < 10) {
        EDIFCellInst lut1ECI;
        if (SeparateCCCLFlow)
          lut1ECI = socketEC.getCellInst("socket_cc_inst").getCellType().removeCellInst("lut1_primitive_0");
        else
          lut1ECI = socketEC.removeCellInst("lut1_primitive_0");

        for (EDIFPortInst epi : lut1ECI.getPortInsts()) {
          for (EDIFPortInst epi1 : epi.getNet().getPortInsts()) {
            epi1.getParentCell().removePort(epi1.getPort());
          }
          if (SeparateCCCLFlow)
            socketEC.getCellInst("socket_cc_inst").getCellType().removeNet(epi.getNet());
          else
            socketEC.removeNet(epi.getNet());
        }

        Cell lut1Cell;
        if (SeparateCCCLFlow)
          lut1Cell = shell_design.getCell(socketName + "/socket_cc_inst/lut1_primitive_0/inst/lut1_inst");
        else
          lut1Cell = shell_design.getCell(socketName + "/lut1_primitive_0/inst/lut1_inst");

        //Net lut1INet = shell_design.getNet(socketName + "/lut1_in");
        Net lut1ONet;
        if (SeparateCCCLFlow)
          lut1ONet = shell_design.getNet(socketName + "/socket_cc_inst/lut1_primitive_0/inst/O");
        else
          lut1ONet = shell_design.getNet(socketName + "/lut1_primitive_0/inst/O");

        lut1Cell.getEDIFCellInst().getParentCell().removeCellInst(lut1Cell.getEDIFCellInst());
        lut1Cell.getEDIFCellInst().getParentCell().getLibrary().removeCell(lut1Cell.getEDIFCellInst().getParentCell());

        for (PIP pip : lut1ONet.getPIPs()) {
          mbufgceClrnNets[socketId].addPIP(pip);
        }
  //      shell_design.removeNet(lut1INet);
        shell_design.removeNet(lut1ONet);
        shell_design.removeCell(lut1Cell);

        // Reset Routing (mbufgce_clr_n)
        //Tile relocTile0 = getRelocTile(dev.getTile("INT_X52Y98"), relocCROffsetX, relocCROffsetY, designId);
        //Tile relocTile1 = getRelocTile(dev.getTile("INT_X52Y100"), relocCROffsetX, relocCROffsetY, designId);
        Tile relocTile0 = getRelocTile(dev.getTile("INT_X74Y98"), relocCROffsetX, relocCROffsetY, designId);
        Tile relocTile1 = getRelocTile(dev.getTile("INT_X74Y100"), relocCROffsetX, relocCROffsetY, designId);

        if (designId == 3) {
          //relocTile0 = getRelocTile(dev.getTile("INT_X52Y2"), relocCROffsetX, relocCROffsetY, designId);
          //relocTile1 = getRelocTile(dev.getTile("INT_X52Y4"), relocCROffsetX, relocCROffsetY, designId);
          relocTile0 = getRelocTile(dev.getTile("INT_X74Y2"), relocCROffsetX, relocCROffsetY, designId);
          relocTile1 = getRelocTile(dev.getTile("INT_X74Y4"), relocCROffsetX, relocCROffsetY, designId);
        }
        if (designId == 4) {
          relocTile0 = getRelocTile(dev.getTile("INT_X66Y333"), relocCROffsetX, relocCROffsetY, designId);
          relocTile1 = getRelocTile(dev.getTile("INT_X66Y331"), relocCROffsetX, relocCROffsetY, designId);
        }

        //System.out.println("RelocTile: " + relocTile0 + " " + relocTile1);
        Node mbufgceClrnSnkNode = dev.getNode(relocTile0 + "/OUT_NN2_E_BEG3");
        if (designId == 4)
          mbufgceClrnSnkNode = dev.getNode(relocTile0 + "/OUT_NN7_BEG3");

        int startY = mbufgceClrnSrcPIPs[socketId].getTile().getTileYCoordinate();
        RouteNode startRouteNode = new RouteNode(mbufgceClrnSrcPIPs[socketId].getStartNode());
        RouteNode endRouteNode   = new RouteNode(mbufgceClrnSnkNode);

        List<PIP> routingPath = findRoutingPath(
          startRouteNode,
          endRouteNode,
          allRoutedWires,
          startXs[socketId],
          startY);

        assert routingPath != null : "Unroutable!";
        boolean verbose = false;
        if (verbose) {
          System.out.println("routingPath: " + startRouteNode + " -> " + endRouteNode +
                             " len " + routingPath.size());
        }
        for (PIP pip : routingPath) {
          if (verbose)
            System.out.println("--> " + pip);
          mbufgceClrnNets[socketId].addPIP(pip);
          allRoutedWires.add(pip.getStartWire());
          allRoutedWires.add(pip.getEndWire());
        }

        if (designId == 4)
          mbufgceClrnNets[socketId].addPIP(dev.getPIP(relocTile1 + "/INT.IN_SS7_END3->>OUT_SS7_BEG3"));
        else
          mbufgceClrnNets[socketId].addPIP(dev.getPIP(relocTile1 + "/INT.IN_NN2_E_END3->>OUT_NN7_BEG3"));

        allRoutedPIPs.addAll(mbufgceClrnNets[socketId].getPIPs());
        for (PIP pip : mbufgceClrnNets[socketId].getPIPs()) {
          Node enode = pip.getEndNode();
          allRoutedEnodes.add(enode);
        }
      }

      // Clock Routing
      int clockTrack = mbufgceClkO1PIPs[socketId].getStartNode().getSitePin().getSite().getInstanceY();
      routedPIPs.addAll(mbufgceClk1Nets[socketId].getPIPs());
      ArrayList<PIP> routePath = new ArrayList<>();

      Tile relocClkTile = getRelocTile(dev.getTile("CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183"), relocCROffsetX, relocCROffsetY, designId);
      if (designId == 4)
        relocClkTile = getRelocTile(dev.getTile("CLK_REBUF_VERT_VNOC_TOP_COA_TILE_X69Y327"), relocCROffsetX, relocCROffsetY, designId);

      //Node snkNode = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR" + clockTrack);
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV2_11
      Node snkNode = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV2_" + clockTrack);
      // CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/IF_WRAP_CLK_V_BOT_CLK_VDISTR11
      //Node snkNode = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR" + clockTrack);
      if (designId == 3)
        snkNode = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VROUTE" + clockTrack);

      HashMap<PIP, PIP> clkPIPMap = new HashMap<>();
      // IF_HCLK_CLK_HDISTR/VDISTR
      // IF_HCLK_CLK_HDISTR_LOC11
      // IF_WRAP_CLK_V_BOT_CLK_VDISTR0 -> CLK_PD_OPT_DELAY_97_I, CLK_PD_OPT_DELAY_121_I
      // IF_WRAP_CLK_V_BOT_CLK_VDISTR0 -> CLK_PD_OPT_DELAY_108_I, CLK_PD_OPT_DELAY_132_I
      for (PIP pip : mbufgceClk1Nets[socketId].getPIPs()) {
        boolean FoundNewPIP = false;
        String newPIPName = pip.toString();
        if (newPIPName.contains("DISTR11") && !newPIPName.contains("IF_WRAP_CLK_V_TOP_CLK_VDISTR")) {
          newPIPName = pip.toString().replaceAll("DISTR11", "DISTR" + clockTrack);
          FoundNewPIP = true;
        }
//        if (newPIPName.contains("LEV1_11")) {
//          newPIPName = pip.toString().replaceAll("LEV1_11", "LEV1_" + clockTrack);
//          FoundNewPIP = true;
//        }
//        if (newPIPName.contains("LEV2_11")) {
//          newPIPName = pip.toString().replaceAll("LEV2_11", "LEV2_" + clockTrack);
//          FoundNewPIP = true;
//        }
        if (newPIPName.contains("VROUTE11")) {
          //newPIPName = pip.toString().replaceAll("VROUTE11", "VROUTE" + clockTrack);
          //FoundNewPIP = true;
        }
        if (newPIPName.contains("HDISTR_LOC11")) {
          newPIPName = pip.toString().replaceAll("HDISTR_LOC11", "HDISTR_LOC" + clockTrack);
          FoundNewPIP = true;
        }
        if (newPIPName.contains("CLK_PD_OPT_DELAY_108")) {
          int optDelayNum = 97 + clockTrack;
          newPIPName = newPIPName.replaceAll("CLK_PD_OPT_DELAY_108", "CLK_PD_OPT_DELAY_" + optDelayNum);
          FoundNewPIP = true;
        }
        if (newPIPName.contains("CLK_PD_OPT_DELAY_132")) {
          int optDelayNum = 121 + clockTrack;
          newPIPName = newPIPName.replaceAll("CLK_PD_OPT_DELAY_132", "CLK_PD_OPT_DELAY_" + optDelayNum);
          FoundNewPIP = true;
        }
        // Special case for tile CLK_VNOC_PSS_CCA_TILE_X23Y47
        if (newPIPName.contains("CLK_VNOC_PSS_CCA_TILE_X23Y47") &&
            newPIPName.contains("CLK_PD_OPT_DELAY_144")) {
          int optDelayNum = 133 + clockTrack;
          newPIPName = newPIPName.replaceAll("CLK_PD_OPT_DELAY_144", "CLK_PD_OPT_DELAY_" + optDelayNum);
          FoundNewPIP = true;
        }

        if (!FoundNewPIP)
          continue;

        PIP newPIP = dev.getPIP(newPIPName);
        clkPIPMap.put(pip, newPIP);
      }

      for (Map.Entry<PIP, PIP> entry : clkPIPMap.entrySet()) {
        PIP origPIP = entry.getKey();
        PIP newPIP = entry.getValue();
        mbufgceClk1Nets[socketId].removePIP(origPIP);
        mbufgceClk1Nets[socketId].addPIP(newPIP);
      }

      //clockRouting(mbufgceClkO1PIPs[socketId], snkNode, allRoutedPIPs, routePath, true);
      clockRouting(mbufgceClkO1PIPs[socketId], snkNode, allRoutedWires, routePath, false);

      //System.out.println("Route to " + snkNode + " length = " + routePath.size());
      for (PIP pip : routePath) {
        if (!mbufgceClk1Nets[socketId].getPIPs().contains(pip))
          mbufgceClk1Nets[socketId].addPIP(pip);
        //System.out.println("Routing clkPIP " + pip);
      }
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/IF_WRAP_CLK_V_BOT_CLK_VDISTR16
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/CLK_REBUF_VERT_VNOC_BAA_TILE.CLK_CMT_MUX_4TO1_14_CLK_OUT->>IF_WRAP_CLK_V_BOT_CLK_VDISTR16
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/CLK_REBUF_VERT_VNOC_BAA_TILE.IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV1_16->>CLK_CMT_MUX_4TO1_14_CLK_OUT
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV1_16
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/CLK_REBUF_VERT_VNOC_BAA_TILE.IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV2_16->>CLK_CMT_MUX_4TO1_62_CLK_OUT
      //CLK_REBUF_VERT_VNOC_BAA_TILE_X69Y183/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV2_16
      // Switch between VDISTR_LEV12_16 -> VDISTR_LEV1_16 -> VDISTR16

      HashSet<PIP> toRemovePIPs = new HashSet<>();
      for (PIP pip : mbufgceClk1Nets[socketId].getPIPs()) {
        if (pip.toString().contains("IF_WRAP_CLK_V_BOT_CLK_VDISTR") && pip.toString().contains("CLK_CMT_MUX_4TO1")) {
          //System.out.println("[1] to remove PIP " + pip);
          toRemovePIPs.add(pip);
        }
        if (designId == 2 || designId == 3) {
          if (pip.toString().contains("IF_WRAP_CLK_V_TOP_CLK_VDISTR") && pip.toString().contains("CLK_CMT_MUX_4TO1")) {
            System.out.println("[2] to remove PIP " + pip);
            toRemovePIPs.add(pip);
          }
          if (pip.toString().contains("IF_WRAP_CLK_V_BOT_CLK_VROUTE11") && pip.toString().contains("CLK_CMT_MUX_4TO1")) {
            System.out.println("[2] to remove PIP " + pip);
            toRemovePIPs.add(pip);
          }
        }
        if (designId == 3) {
          if (pip.toString().contains("IF_WRAP_CLK_V_BOT_CLK_VDISTR") && pip.toString().contains("CLK_CMT_MUX_3TO1")) {
            //System.out.println("[3] to remove PIP " + pip);
            toRemovePIPs.add(pip);
          }
          if (pip.toString().contains("IF_WRAP_CLK_V_BOT_CLK_VROUTE") && pip.toString().contains("CLK_CMT_MUX_3TO1")) {
            //System.out.println("[4] to remove PIP " + pip);
            toRemovePIPs.add(pip);
          }
        }
      }
      for (PIP pip : toRemovePIPs) {
        mbufgceClk1Nets[socketId].removePIP(pip);
      }

      Node snkNode0 = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR" + clockTrack);
      Node snkNode1 = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV1_" + clockTrack);
      // for case [w=1, h=2] -- stretching clock regions in y-direction
      Node snkNode2 = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_TOP_CLK_VDISTR" + clockTrack);

      Node n0 = null;
      for (PIP pip : snkNode0.getAllUphillPIPs()) {
        if (pip.toString().contains("CLK_CMT_MUX_4TO1")) {
          //System.out.println(pip);
          mbufgceClk1Nets[socketId].addPIP(pip);
          n0 = pip.getStartNode();
          break;
        }
      }
      for (PIP pip : n0.getAllUphillPIPs()) {
        if (pip.getStartNode().equals(snkNode1)) {
          //System.out.println(pip);
          mbufgceClk1Nets[socketId].addPIP(pip);
          break;
        }
      }
      for (PIP pip : snkNode1.getAllUphillPIPs()) {
        if (pip.toString().contains("CLK_CMT_MUX_4TO1")) {
          n0 = pip.getStartNode();
          //System.out.println(pip);
          mbufgceClk1Nets[socketId].addPIP(pip);
          break;
        }
      }
      for (PIP pip : n0.getAllUphillPIPs()) {
        if (pip.getStartNode().equals(snkNode)) {
          //System.out.println(pip);
          mbufgceClk1Nets[socketId].addPIP(pip);
          break;
        }
      }
      if (designId == 2 || designId == 3) {
        // for case [w=1, h=2]
        for (PIP pip : snkNode2.getAllUphillPIPs()) {
          if (pip.toString().contains("CLK_CMT_MUX_4TO1") && pip.getTile().equals(relocClkTile)) {
            n0 = pip.getStartNode();
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            break;
          }
        }
        // for case [w=1, h=2]
        for (PIP pip : n0.getAllUphillPIPs()) {
          if (pip.getStartNode().equals(snkNode1)) {
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            break;
          }
        }
      }

      if (designId == 3) {
        relocClkTile = getRelocTile(dev.getTile("CLK_REBUF_VERT_VNOC_CBA_TILE_X69Y87"), relocCROffsetX, relocCROffsetY, designId);

        Node snkNode3 = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR" + clockTrack);
        Node snkNode4 = dev.getNode(relocClkTile + "/IF_WRAP_CLK_V_BOT_CLK_VDISTR_LEV1_" + clockTrack);

        n0 = null;
        for (PIP pip : snkNode3.getAllUphillPIPs()) {
          if (pip.toString().contains("CLK_CMT_MUX_4TO1")) {
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            n0 = pip.getStartNode();
            break;
          }
        }
        for (PIP pip : n0.getAllUphillPIPs()) {
          if (pip.getStartNode().equals(snkNode4)) {
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            break;
          }
        }
        for (PIP pip : snkNode4.getAllUphillPIPs()) {
          if (pip.toString().contains("CLK_CMT_MUX_4TO1")) {
            n0 = pip.getStartNode();
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            break;
          }
        }
        for (PIP pip : n0.getAllUphillPIPs()) {
          if (pip.getStartNode().equals(snkNode)) {
            //System.out.println(pip);
            mbufgceClk1Nets[socketId].addPIP(pip);
            break;
          }
        }
      }
    }

    t.stop().printSummary();

    shell_design.writeCheckpoint("../checkpoints/full_design.dcp");
    EDIFTools.writeEDIFFile("../checkpoints/full_design.edf", shell_netlist, shell_design.getPart().getName());

    System.out.println("Done.");
  }
}
