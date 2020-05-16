/* Properties of a tiling
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-15, Georg Fischer: extracted from Tiler.java
 */
// package org.teherba.ramath.tiling
// import Position;
// import PositionMap;
// import Vertex;
// import VertexType;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * This class represents a complete (k-uniform) tiling.
 * @author Georg Fischer
 */
public class Tiling implements Serializable {
  public final static String CVSID = "@(#) $Id: Vertex.java $";

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;

  /** OEIS A-number of the coordination sequence */
  private String mASeqNo;

  /** Maximum distance from origin */
  private int mMaxDistance;

  /** Allowed vertex types for this tiling */
  public static VertexType[] mVertexTypes; // [0] is reserved
  /** first free allowed VertexType */
  public static int ffVertexTypes;

  /** Allocated vertices */
  public static ArrayList<Vertex> mVertices; // [0] is reserved

  /** Positions to vertices */
  private PositionMap mPosMap; 

  /**
   * Empty Constructor.
   */
  public Tiling() {
    mASeqNo = "A000000";
    mMaxDistance = 16;
    initialize(2);
  } // Constructor(int)

  /**
   * Constructor.
   * Initializes the data structures of <em>this</em> Tiling.
   * @param numTypes number of {@link VertexTypes},
   * or 0 if only the dynamic structures are to be cleared
   * @param maxDistance maximum distance to be computed,
   * number of terms in coordination sequence
   */
  public Tiling(int numTypes, int maxDistance, String aSeqNo) {
    mASeqNo = aSeqNo;
    mMaxDistance = maxDistance;
    initialize(numTypes);
  } // Constructor(int)

  /**
   * Initializes the data structures of <em>this</em> Tiling.
   * @param numTypes number of {@link VertexTypes},
   * or 0 if only the dynamic structures are to be cleared
   */
  public void initialize(int numTypes) {
    if (numTypes > 0) { // full init
      mVertexTypes  = new VertexType[(numTypes + 1) * 2]; // "+1": [0..1] are not used / reserved
      ffVertexTypes = 0;
      addVertexType(new VertexType()); // the reserved elements [0..1]
    } // full init
    // (only) clear the dynamic structures:
    sIndent  = "";
    mPosMap = new PositionMap();
    mVertices     = new ArrayList<Vertex>(256);
    addVertex(new Vertex(mVertexTypes[0])); // [0] is not used / reserved
    addVertex(new Vertex(mVertexTypes[0])); // [1] is not used / reserved
  } // initialize

  /**
   * Join an array of integers
   * @param delim delimiter
   * @param vector integer array
   * @return a String of the form "[elem1,elem2.elem3]"
   */
  public static String join(String delim, int[] vector) {
    StringBuffer result = new StringBuffer(128);
    result.append('[');
    for (int ind = 0; ind < vector.length; ind ++) {
      if (ind > 0) {
        result.append(delim);
      }
      result.append(String.valueOf(vector[ind]));
    } // for
    result.append(']');
    return result.toString();
  } // join

  /** Amount of indenting for JSON output */
  private static String sIndent = "";

  /** Increase the indent
   */
  public static void  pushIndent() {
    sIndent += "    ";
  } // pushIndent

  /** Decrease the indent
   */
  public static void popIndent() {
    if (sIndent.length() >= 4) {
      sIndent = sIndent.substring(4);
    }
  } // popIndent

  /**
   * Adds an existing VertexType and creates and adds the flipped version
   * @param normalType the VertexType to be added
   * @return iType of the resulting, normal VertexType
   */
  public int addVertexType(VertexType normalType) {
    int result = ffVertexTypes;
    mVertexTypes[ffVertexTypes ++] = normalType;
    mVertexTypes[ffVertexTypes ++] = normalType.getFlippedClone();
    return result;
  } // addVertexType

  /**
   * Creates and adds a new VertexType from Galebach's parameters
   * together with the flipped version
   * @param aSeqNo OIES A-number of the sequence
   * @param galId Galebach's id "Gal.u.t.v"
   * @param vertexId clockwise dot-separated list of
   *     the polygones followed by the list of types and angles
   * @param taRotList clockwise semicolon-separated list of
   *     vertex type names and angles (and apostrophe if flipped)
   * @param sequence a list of initial terms of the coordination sequence
   * @return iType of the resulting VertexType
   */
  public int addVertexType(String aSeqNo, String galId, String vertexId, String taRotList, String sequence) {
    return addVertexType(new VertexType(aSeqNo, galId, vertexId, taRotList, sequence));
  } // addVertexType

  /**
   * Completes all {@link VertexType}s, that is fills the pxTypes from pxTinds
   */
  public void completeVertexTypes() {
    for (int iType = 0; iType < ffVertexTypes; iType ++) {
      VertexType vtype = getVertexType(iType);
      vtype.pxTypes = new VertexType[vtype.edgeNo];
      for (int iedge = 0; iedge < vtype.edgeNo; iedge ++) {
        vtype.pxTypes[iedge] = mVertexTypes[vtype.pxTinds[iedge]];
      } // for iedge
    } // for iType
  } // completeVertexTypes

  /**
   * Gets a VertexType
   * @param iType index of type, even for normal, odd for flipped variant
   * @return the corresponding VertexType with edges rotated clockwise in both versions
   */
  public static VertexType getVertexType(int iType) {
    return mVertexTypes[iType];
  } // getVertexType

  /**
   * Adds an existing {@link Vertex} to the array of known vertices, and to the HashMap for {@link Position}s of vertices
   * @param vertex existing Vertex
   * @return index of added Vertex in {@link #mVertices}
   */
  public int addVertex(Vertex vertex) {
    vertex.index = mVertices.size();
    mVertices.add(vertex);
    mPosMap.put(vertex);
    return vertex.index;
  } // addVertex

  /**
   * Returns a JSON representation of the tiling
   * @return JSON for {@link #mVertexTypes} and {@link #mVertices}
   */
  public String toJSON() {
    // pushIndent();
    String result  = sIndent + "{ \"ffVertexTypes\": " + ffVertexTypes  + "\n"
                   + sIndent + ", \"mVertexTypes\":\n";
    String sep = "  , ";
    for (int ind = 0; ind < ffVertexTypes; ind ++) { // even (normal) and odds (flipped) versions
      result += sIndent + (ind == 0 ? "  [ " : sep) + getVertexType(ind).toJSON();
    } // for types
    result += sIndent + "  ]\n";

    int ffVertices = mVertices.size();
    result += sIndent + ", \"ffVertices\": " + ffVertices + "\n" +  sIndent + ", \"mVertices\":\n";
    for (int ind = 0; ind < ffVertices; ind ++) {
      Vertex focus = mVertices.get(ind);
      result += sIndent + (ind == 0 ? "  [ " : sep) + focus.toJSON();
    } // for vertices
    result += sIndent + "  ]\n";
    result += mPosMap.toJSON();
    return result;
  } // toJSON

  /**
   * Draws the edges of <em>this</em> rotated {@link #Vertex} with thin
   * lines for debugging purposes.
   * @param focus Vertex to be shown
   */
  public void showSVGVertex(Vertex focus) {
     VertexType vtype = focus.getType();
     for (int iedge = 0; iedge < vtype.edgeNo; iedge ++) {
       Vertex succ = focus.getSuccessor(iedge);
       SVGFile.writeEdge(focus, succ, iedge, 2); // mode = test
     } // for iedge
     SVGFile.writeVertex(focus, 2); // mode = test
  } // showSVGVertex

   /**
   * Creates a successor {@link Vertex} of the focus and connects the successor back to the focus
   * @param focus the Vertex which gets the new successor
   * @param iedge attach the successor at this edge of the focus
   * @param distance from the origin Vertex
   * @return index of new successor vertex, or 0 if attached to an existing vertex
   */
  public int attach_99(Vertex focus, int iedge, int distance) {
    int isucc = 0; // future result; assume that the successor already exists
    VertexType foType = focus.getType();
    if (focus.succs[iedge] == 0) { // determine successor
      Vertex succ = focus.getSuccessor(iedge);
      if (sDebug >= 2) {
        System.out.println("#--------\n# call attach(vertex " + focus.toString() + ", iedge " + iedge + ")");
        System.out.println("#     candidate successor is "
            + succ.getName() + "@" + succ.rotate + succ.expos + ", bedge " + succ.bedge);
      }
      int suEdge = succ.bedge;
      if (suEdge < 0) { // not found
        if (SVGFile.sEnabled) {
          showSVGVertex(succ);
        }
        if (sDebug >= 0) {
          System.out.println("# ** assertion 1 in attach(focus " + focus.index + focus.getName() + "\t, edge " + iedge
              + "): no match in succ " + succ.toString());
        }
        if (SVGFile.sEnabled) {
          SVGFile.writeEdge(focus, succ, iedge, 1);
        }
      } else { // matching angles
        Vertex proxy = mPosMap.get(succ.expos);
        int ioldv = proxy == null ? -1 : proxy.index; // does the successor Vertex already exist?
        if (ioldv < 0) { // not found
          isucc = addVertex(succ);
          focus.succs[iedge] = isucc; // set forward link
        } else { // old, successor Vertex already exist
          // succ  = mVertices.get(ioldv);
          focus.succs[iedge] = ioldv; // set forward link
          isucc = 0; // do not enqueue it
        } // successor Vertex already exist
        if (succ.succs[suEdge] == 0) { // edge was not yet connected
          succ.succs[suEdge] = focus.index; // set backward link
        } else if (succ.succs[suEdge] != focus.index) {
          if (SVGFile.sEnabled) {
            showSVGVertex(succ);
          }
          if (sDebug >= 0) { // always show bad assertion
            System.out.println("# ** assertion 2 in attach(focus " + focus.toString()
            + "\t, edge " + iedge + "): focus not in succ " + succ.toString()
            + "[" + suEdge + "]=" + succ.succs[suEdge] + " <> " + focus.index);
          }
          succ.succs[suEdge] = focus.index;
        }
        if (sDebug >= 2) {
          System.out.println("#   attached focus " + focus.toString()
              + ", iedge "  + iedge
              + " -> succ " + succ.toString()
              + ", suEdge " + suEdge
              );
        }
        if (SVGFile.sEnabled) {
          SVGFile.writeEdge(focus, succ, distance, 0); // normal
        }
      } // matching angles
      focus.fixedEdges ++;
    } else { // focus.succs[iedge] != 0 - ignore
    /*
      if (sDebug >= 2) {
        System.out.println("#   attach(" + focus.toString() + ", " + iedge
            + "): ignore attached edge " + iedge + " -> " + focus.succs[iedge]);
      }
    */
    }
    return isucc;
  } // attach_99

   /**
   * Creates a successor {@link Vertex} of the focus and connects the successor back to the focus
   * @param focus the Vertex which gets the new successor
   * @param iedge attach the successor at this edge of the focus
   * @param distance from the origin Vertex
   * @return index of new successor vertex, or 0 if attached to an existing vertex
   */
  public int attach(Vertex focus, int iedge, int distance) {
    int result = 0; // future result; assume that the successor already exists
    VertexType foType = focus.getType();
    if (focus.succs[iedge] == 0) { // successor for this edge not yet determined
      Position proxyPos = focus.getProxyPosition(iedge);
      Vertex succ = mPosMap.get(proxyPos);
      if (succ != null) { // found, old
        focus.succs[iedge]   = succ.index; // set forward link
        focus.proxies[iedge] = succ;
        result = 0; // do not enqueue it
      } else { // attach new successor
        succ = focus.getSuccessor(iedge);
        if (sDebug >= 2) {
          System.out.println("#--------\n# call attach(vertex " + focus.toString() + ", iedge " + iedge + ")");
          System.out.println("#     candidate successor is "
              + succ.getName() + "@" + succ.rotate + succ.expos + ", bedge " + succ.bedge);
        }
        int suEdge = succ.bedge;
        if (suEdge < 0) { // not found
          if (SVGFile.sEnabled) {
            showSVGVertex(succ);
          }
          if (sDebug >= 0) {
            System.out.println("# ** assertion 1 in attach(focus " + focus.index + focus.getName() + "\t, edge " + iedge
                + "): no match in succ " + succ.toString());
          }
          if (SVGFile.sEnabled) {
            SVGFile.writeEdge(focus, succ, iedge, 1);
          }
        } else { // matching angles
        } // matching angles
        result = addVertex(succ);
        focus.succs[iedge]   = result; // set forward link
        focus.proxies[iedge] = succ;
      } // not found - attach new successor
      
      focus.fixedEdges ++;
      if (SVGFile.sEnabled) {
        SVGFile.writeEdge(focus, succ, distance, 0); // normal
      }
    } else { // focus.succs[iedge] != 0 - ignore
    }
    return result;
  } // attach

  private static final int MAX_ERROR = 2;

  /**
   * Computes the neighbourhood of the start vertex up to some distance
   * @param iBaseType index of the initial vertex type
   */
  public void computeNet(int iBaseType) {
    VertexType baseType = getVertexType(iBaseType);
    int errorCount = MAX_ERROR;
    LinkedList<Integer> queue = new LinkedList<Integer>();
    initialize(0); // reset dynamic structures only
    String[] parts = baseType.sequence.split("\\,");
    int termNo = parts.length;
    int[] terms = new int[termNo];
    for (int iterm = 0; iterm < termNo; iterm ++) {
      try {
        terms[iterm] = Integer.parseInt(parts[iterm]);
      } catch (Exception exc) {
      }
    } // for iterm
    if (mMaxDistance == -1) {
      mMaxDistance = termNo - 1;
    }
    if (mASeqNo != null) {
      baseType.aSeqNo = mASeqNo;
    }
    if (BFile.sEnabled) { // open b-file
      BFile.open(baseType.aSeqNo);
    }
    if (sDebug >= 3) {
      System.out.println("# compute neighbours of vertex type " + iBaseType + " up to distance " + mMaxDistance);
      String result  = sIndent + "# \"ffVertexTypes\": " + ffVertexTypes  + "\n"
                   + sIndent + ", \"mVertexTypes\":\n";
      String sep = "  , ";
      for (int ind = 0; ind < ffVertexTypes; ind ++) { // even (normal) and odds (flipped) versions
        result += sIndent + (ind == 0 ? "  [ " : sep) + getVertexType(ind).toJSON();
      } // for types
      result += sIndent + "  ]\n";
      System.out.println(result);
    }
    int distance = 0; // also index for terms
    queue.add(addVertex(new Vertex(mVertexTypes[iBaseType])));
    int addedVertices = 1;
    StringBuffer coordSeq = new StringBuffer(256);
    coordSeq.append("1");
    if (BFile.sEnabled) { // data line
      BFile.write(distance + " " + addedVertices);
    }

    distance ++;
    while (distance <= mMaxDistance) {
      addedVertices = 0;
      int levelPortion = queue.size();
      while (levelPortion > 0 && queue.size() > 0) { // queue not empty
        int ifocus = queue.poll();
        if (sDebug >= 2) {
          System.out.println("# dequeue ifocus " + ifocus);
        }
        Vertex focus = mVertices.get(ifocus);
        focus.distance = distance;
        VertexType foType = mVertexTypes[focus.iType];
        for (int iedge = 0; iedge < foType.edgeNo; iedge ++) {
          int isucc = attach(focus, iedge, distance);
          if (isucc > 0) { // did not yet exist
            addedVertices ++;
            queue.add(isucc);
            if (sDebug >= 2) {
              System.out.println("# enqueue isucc " + isucc + ", attached to ifocus " + ifocus + " at edge " + iedge);
            }
          }
        } // for iedge
        levelPortion --;
      } // while portion not exhausted and queue not empty
      if (distance < terms.length && terms[distance] != addedVertices && errorCount > 0) {
        System.out.println("# ** assertion 6: " + baseType.aSeqNo + " " + baseType.galId
            + ":\tdifference in terms[" + distance + "], expected " + terms[distance] + ", computed " +addedVertices);
        errorCount --;
      }
      coordSeq.append(',');
      coordSeq.append(String.valueOf(addedVertices));
      if (BFile.sEnabled) { // data line
        BFile.write(distance + " " + addedVertices);
      }
      if (sDebug >= 2) {
        System.out.println("# distance " + distance + ": " + addedVertices + " vertices added\n");
      }
      distance ++;
    } // while distance
    int ffVertices = mVertices.size();
    if (mPosMap.size() != ffVertices - 2) {
      if (sDebug >= 3) {
        System.out.println("# ** assertion 3 in tiling.toString: " + mPosMap.size()
            + " different positions, but " + (ffVertices - 2) + " vertices\n");
      }
    }
    if (sDebug >= 3) {
      System.out.println("# final net\n" + toJSON());
    }
    if (true) { // this is always output
      System.out.println(baseType.aSeqNo + "\ttiler\t0\t" + mVertexTypes[iBaseType].galId + "\t" + coordSeq.toString());
    }
    if (BFile.sEnabled) { // close b-file
      BFile.close();
    }
    if (errorCount == MAX_ERROR || mMaxDistance == termNo - 1) { // was -1
      System.err.println("# " + baseType.aSeqNo + " " + baseType.galId + ":\t"
          + String.valueOf(mMaxDistance + 1) + " terms verified");
    }
    if (SVGFile.sEnabled) {
      for (int ind = 2; ind < ffVertices; ind ++) { // ignore reserved [0..1]
        Vertex focus = mVertices.get(ind);
        SVGFile.writeVertex(focus, 0);
      } // for vertices
    } // SVG
  } // computeNet

} // class Tiling

