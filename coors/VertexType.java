/* Type of a vertex in a tiling 
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-15, Georg Fischer: extracted from Tiler.java
 */
// package org.teherba.ramath.tiling
// import Position;
// import Vertex;
import java.io.Serializable;

/**
 * This class represents some type of a {@link Vertex} in a tiling. 
 * @author Georg Fischer
 */
public class VertexType implements Serializable {
  public final static String CVSID = "@(#) $Id: Vertex.java $";

  int    index;         // sequential number of type, starting at 0
  String vertexId;      // e.g. "12.6.4" - decreasing polygone edge numbers at the moment
  int    edgeNo;        // number of edges; the following arrays are indexed by iedge=0..edgeNo-1
  int[]  polys;         // number of corners of the regular (3,4,6,8, or 12) polygones (shapes)
                            // which are arranged clockwise (for SVG, counter-clockwise by Galebach) around this vertex type;
                            // first edge goes from (x,y)=(0,0) to (1,0); the shape is to the left of the edge
  int[]  pxRotats;      // how many degrees must the proxy vertices be rotated, from Galebach
  int[]  pxEdges;       // which edge of the proxy is connected - not used yet
  int[]  pxOrients;     // whether the proxy vertex is oriented normally (+1) or flipped (-1)
  int[]  pxSweeps;      // positive angles from iedge to iedge+1 for (iedge=0..edgeNo) mod edgeNo
  int[]  pxTinds;       // VertexType indices of proxy vertices; preliminary during VT creation, later pxTypes are used
  VertexType[] pxTypes; // VertexTypes of proxyt vertices
/*Shas    
  int[]  leShas;        // shapes / polygones from the focus to the left  of the edge
  int[]  riShas;        // shapes / polygones from the focus to the right of the edge
Shas*/                  
  String galId;         // e.g. "Gal.2.1.1"
  String name;          // for example "A" for normal or "a" (lowercase) for flipped version
  String aSeqNo;        // OEIS A-number of the coordination sequence
  String sequence;      // list of terms of the coordination sequence (standard is 50 terms)

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;
  
  /**
   * Empty constructor
   */
  VertexType() {
    index     = 0;
    vertexId  = "";
    edgeNo    = 0;
    polys     = new int[0];
    pxRotats  = new int[0];
    pxEdges   = new int[0];
    pxOrients = new int[0];
    pxSweeps  = new int[0];
    pxTinds   = new int[0];
  /*Shas    
    leShas    = new int[0];
    riShas    = new int[0];
  Shas*/
    galId     = "Gal.0.0.0";
    name      = "Z";
    aSeqNo    = "";
    sequence  = "";
  } // VertexType()

  /**
   * Modify an existing {@link VertexType} and set the parameters of the angle notation
   * @param aSeqNo OEIS A-number of the sequence
   * @param galId Galebach's identification of a vertex type: "Gal.u.t.v"
   * @param vertexId clockwise dot-separated list of
   *     the polygones followed by the list of types and angles
   * @param taRotList clockwise semicolon-separated list of
   *     vertex type names and angles (and apostrophe if flipped)
   * @param sequence a list of initial terms of the coordination sequence
   */
  public void setAngleNotation(String aSeqNo, String galId, String vertexId, String taRotList, String sequence) {
    // for example: A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4 tabA 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
    // this.index and this.name are filled in VertexTypeArray.add()
    this.vertexId    = vertexId;
    String[] corners = vertexId.split("\\.");
    String[] parts   = taRotList.split("\\;\\s*");
    this.aSeqNo = aSeqNo;
    this.galId  = galId;
    this.sequence = sequence;
    edgeNo      = parts.length;
    polys       = new int[edgeNo];
    pxRotats    = new int[edgeNo];
    pxEdges     = new int[edgeNo];
    pxOrients   = new int[edgeNo];
    pxSweeps    = new int[edgeNo];
    pxTinds     = new int[edgeNo];
  /*Shas    
    leShas      = new int[edgeNo];
    riShas      = new int[edgeNo];
  Shas*/
    for (int iedge = 0; iedge < edgeNo; iedge ++) {
      // parts[iedge] has the form: "letter angle [,edge] [']", e.g. "A270,2'" 
      pxEdges    [iedge] = -1; // undefined so far
      pxTinds    [iedge] = parts[iedge].charAt(0) - 'A'; // A -> 0
      pxOrients  [iedge] = parts[iedge].contains("'") ? -1 : 1; // with apostrophe => proxy must be flipped
      polys      [iedge] = 0;
      pxRotats   [iedge] = 0;
      try {
        int commaPos = parts[iedge].indexOf(',');
        if (commaPos >= 0) {
          pxEdges[iedge] = parts[iedge].charAt(commaPos + 1) - '0';
        } else {
          pxEdges[iedge] = -1;
        }
        polys    [iedge] = Integer.parseInt(corners[iedge]);
        pxRotats [iedge] = Integer.parseInt(parts[iedge].replaceAll("[\\-\\D]", "")); // keep "-" and the digits only
      } catch (Exception exc) {
        System.err.println("# ** assertion 4: descriptor for \"" + galId + "\" bad");
      }
    } // for iedge
    for (int iedge = 0; iedge < edgeNo; iedge ++) { // increasing
      pxSweeps[iedge] = iedge == 0
          ? 0
          : pxSweeps[iedge - 1] + Position.mRegularAngles[polys[iedge - 1]];
    /*Shas    
      riShas[iedge] = polys[iedge];
      leShas[iedge] = polys[oedge];
    Shas*/
    } // for iedge
  } // setAngleNotation

  /**
   * Returns a simple representation of the VertexType
   * @return the most important properties
   */
  public String toString() {
    return "{" + index + name + "}";
  } // VertexType.toString

  /**
   * Returns a representation of the VertexType
   * @return JSON for all properties
   */
  public String toJSON() {
    Tiling.pushIndent(); 
    String result
        = "{ \"i\": \""       + index + "\""
        + ", \"name\": \""    + name  + "\""
        + ", \"vid\": \""     + vertexId + "\""
        + ", \"polys\": "     + Tiling.join(",", polys)
        + ", \"pxSweeps\": "  + Tiling.join(",", pxSweeps)
        + ", \"pxRotats\": "  + Tiling.join(",", pxRotats)
        + ", \"pxEdges\": "   + Tiling.join(",", pxEdges)
        + ", \"pxOrients\": " + Tiling.join(",", pxOrients)
        + ", \"pxTipes\": "   + Tiling.join(",", pxTinds)
    /*
        + ", \"leShas\": "    + Tiling.join(",", leShas)
        + ", \"riShas\": "    + Tiling.join(",", riShas)
    */
        + ", \"galId\": \""   + galId + "\""
        + " }\n";
    Tiling.popIndent();
    return result;
  } // VertexType.toJSON

  /**
   * Determines whether <em>this</em> {@link VertexType} is flipped
   * @return true if the index is odd, false otherwise
   */
  public boolean isFlipped() {
    return  (index & 1) == 1;
  } // isFlipped

} // class VertexType

