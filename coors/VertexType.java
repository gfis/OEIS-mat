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

  int    index;    // even for normal type, odd for flipped version
  String vertexId; // e.g. "12.6.4"
  int    edgeNo;   // number of edges; the following arrays are indexed by iedge=0..edgeNo-1
  int[]  polys;    // number of corners of the regular (3,4,6,8, or 12) polygones (shapes)
                   // are arranged clockwise (for SVG, counter-clockwise by Galebach) around this vertex type.
                   // First edge goes from (x,y)=(0,0) to (1,0); the shape is to the left of the edge
  VertexType[] proxyTypes; // VertexTypes of target vertices - set only in completeVertexTypes
  int[]  tipes;    // VertexType indices of target vertices (normally even, odd if flipped / C')
  int[]  rotas;    // how many degrees must the target vertices be rotated, from Galebach
  int[]  sweeps;   // positive angles from iedge to iedge+1 for (iedge=0..edgeNo) mod edgeNo
/*Shas    
  int[]  leShas;   // shapes / polygones from the focus to the left  of the edge
  int[]  riShas;   // shapes / polygones from the focus to the right of the edge
Shas*/
  String galId;    // e.g. "Gal.2.1.1"
  String name;     // for example "A" for normal or "a" (lowercase) for flipped version
  String aSeqNo;   // OEIS A-number of {@link #sequence}
  String sequence; // list of terms of the coordination sequence

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;
  
  /**
   * Empty constructor
   */
  VertexType() {
    index    = 0;
    vertexId = "";
    edgeNo   = 0;
    polys    = new int[0];
    tipes    = new int[0];
    rotas    = new int[0];
  /*Shas    
    leShas   = new int[0];
    riShas   = new int[0];
  Shas*/
    sweeps   = new int[0];
    galId    = "Gal.0.0.0";
    name     = "Z";
    aSeqNo   = "";
    sequence = "";
  } // VertexType()

  /**
   * Constructor from input file parameters
   * @param aSeqNo OEIS A-number of the sequence
   * @param galId Galebach's identification of a vertex type: "Gal.u.t.v"
   * @param vertexId clockwise dot-separated list of
   *     the polygones followed by the list of types and angles
   * @param taRotList clockwise semicolon-separated list of
   *     vertex type names and angles (and apostrophe if flipped)
   * @param sequence a list of initial terms of the coordination sequence
   */
  VertexType(String aSeqNo, String galId, String vertexId, String taRotList, String sequence) {
    // for example: A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4 tabA 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
    this.vertexId    = vertexId;
    String[] corners = vertexId.split("\\.");
    String[] parts   = taRotList.split("\\;\\s*");
    index  = Tiling.ffVertexTypes; // even = not flipped
    name   = "ZABCDEFGHIJKLMNOP".substring(index >> 1, (index >> 1) + 1);
    this.aSeqNo = aSeqNo;
    this.galId  = galId;
    this.sequence = sequence;
    edgeNo = parts.length;
    polys  = new int[edgeNo];
    tipes  = new int[edgeNo];
    rotas  = new int[edgeNo];
  /*Shas    
    leShas = new int[edgeNo];
    riShas = new int[edgeNo];
  Shas*/
    sweeps = new int[edgeNo];
    for (int iedge = 0; iedge < edgeNo; iedge ++) {
      try {
        tipes[iedge] = (parts[iedge].charAt(0) - 'A' + 1) * 2; // even, A -> 2
        if (parts[iedge].endsWith("'")) { // with apostrophe => is flipped
          tipes[iedge] ++; // make it odd
          parts[iedge] = parts[iedge].replaceAll("\\'",""); // remove apostrophe
        }
        polys[iedge] = 0;
        rotas[iedge] = 0;
        polys[iedge] = Integer.parseInt(corners[iedge]);
        rotas[iedge] = Integer.parseInt(parts[iedge].replaceAll("\\D", "")); // keep the digits only
      } catch (Exception exc) {
        if (sDebug >= 1) {
          System.err.println("# ** assertion 4: descriptor for \"" + galId + "\" bad");
        }
      }
    } // for iedge
    for (int iedge = 0; iedge < edgeNo; iedge ++) { // increasing
      sweeps[iedge] = iedge == 0
          ? 0
          : sweeps[iedge - 1] + Position.mRegularAngles[polys[iedge - 1]];
    /*Shas    
      int dedge = edgeNo - 1 - iedge; // decreasing
      riShas[iedge] = polys[iedge];
      leShas[iedge] = polys[dedge];
    Shas*/
    } // for iedge
  } // VertexType(String, String, String)

  /**
   * Returns a new, flipped version of <em>this</em> VertexType,
   * which must be normal.
   * @return a VertexType which is a deep copy of <em>this</em>.
   * The index becomes odd, and all edges are visited in reverse orientation.
   */
  public VertexType getFlippedClone() {
    VertexType result = new VertexType();
    result.index    = index + 1; // odd -> edges turn counter-clockwise
    result.galId    = galId;
    result.sequence = sequence;
    result.edgeNo   = edgeNo;
    result.polys    = new int[edgeNo];
    result.tipes    = new int[edgeNo];
    result.rotas    = new int[edgeNo];
  /*Shas    
    result.leShas   = new int[edgeNo];
    result.riShas   = new int[edgeNo];
  Shas*/

    // now determine chirality; reverse the vertexId
    StringBuffer revId = new StringBuffer(128);
    result.sweeps   = new int[edgeNo];
    for (int iedge = 0; iedge < edgeNo; iedge ++) { // increasing
      int dedge = edgeNo - 1 - iedge; // decreasing
      result.tipes [iedge] =   tipes [iedge];
      result.rotas [iedge] =   rotas [iedge];
      result.sweeps[iedge] =   sweeps[iedge];
      result.polys [iedge] =   polys [iedge];
      /*Shas    
        result.riShas[iedge] =   polys [iedge];
        result.leShas[iedge] =   polys [iedge];
      Shas*/
      revId.append('.');
      revId.append(String.valueOf(polys[dedge]));
    } // for iedge
    revId.append(revId.substring(0, revId.length())); // duplicate it
    revId.append('.');
    boolean chiral = revId.indexOf("." + vertexId + ".") < 0; // is it found in some rotation?
    if (sDebug >= 3) {
      System.out.println("# determine chiral: \"." + vertexId + ".\" contained in \"" + revId + "\" ? -> " + chiral);
    }
    result.name     = chiral ? name.toLowerCase() : name;
    return result;
  } // getFlippedClone

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
        = "{ \"i\": \""     + index + "\""
        + ", \"name\": \""  + name  + "\""
        + ", \"vid\": \""   + vertexId + "\""
        + ", \"polys\": "   + Tiling.join(",", polys)
        + ", \"sweeps\": "  + Tiling.join(",", sweeps)
        + ", \"rotas\": "   + Tiling.join(",", rotas)
        + ", \"tipes\": "   + Tiling.join(",", tipes)
    /*
        + ", \"leShas\": "  + Tiling.join(",", leShas)
        + ", \"riShas\": "  + Tiling.join(",", riShas)
    */
        + ", \"galId\": \"" + galId + "\""
        + " }\n";
    Tiling.popIndent();
    return result;
  } // VertexType.toJSON

  /**
   * Limits the index of an edge of <em>this</em> VertexType to the range 0..edgeNo - 1.
   * @param iedge number of edge, maybe negative
   * @return an edge number in the range 0..edgeNo - 1
   */
  public int normEdge(int iedge) {
    int result = iedge;
    while (result < 0) { // ensure non-negative
      result += edgeNo;
    } // while negative
    return result % edgeNo;
  } // normEdge
  
  /**
   * Determines whether <em>this</em> {@link VertexType} is flipped
   * @return true if the index is odd, false otherwise
   */
  public boolean isFlipped() {
    return  (index & 1) == 1;
  } // isFlipped

} // class VertexType

