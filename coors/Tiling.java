/* Properties of a tiling
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-15, Georg Fischer: extracted from Tiler.java
 */
// package org.teherba.ramath.tiling
// import Position;
// import PositionMap;
// import Vertex;
// import VertexList;
// import VertexType;
// import VertexTypeArray;
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

  /** Possible {@link VertexType}s in this tiling */
  public VertexTypeArray mTypeArray;
  
  /** Allocated vertices */
  private VertexList mVertexList;

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
   * @param numTypes number of {@link VertexType}s,
   * or 0 if only the dynamic structures, but not the VertexTypes, are to be cleared.
   */
  public void initialize(int numTypes) {
    if (numTypes > 0) { // full init
      mTypeArray = new VertexTypeArray(numTypes); 
    } // full init

    // (only) clear the dynamic structures:
    sIndent     = "";
    mPosMap     = new PositionMap();
    mVertexList = new VertexList();
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
   * Gets a {@link VertexType}
   * @param index of the VertexType, 0=A, 1=B and so on.
   * @return a number &gt;= 0, 
   */
  public VertexType getVertexType(int index) {
    return mTypeArray.get(index);
  } // getVertexType

  /**
   * Adds an existing {@link Vertex} to the array of known vertices, and to the HashMap for {@link Position}s of vertices
   * @param vertex existing Vertex
   * @return index of added Vertex in {@link #mVertices}
   */
  public int addVertex(Vertex vertex) {
    vertex.index = mVertexList.size();
    mVertexList.put(vertex);
    mPosMap    .put(vertex);
    return vertex.index;
  } // addVertex

  /**
   * Returns a JSON representation of the tiling
   * @return JSON for all major data structures
   */
  public String toJSON() {
    return mTypeArray .toJSON()
        +  mVertexList.toJSON()
        +  mPosMap    .toJSON();
  } // toJSON

   /**
   * Creates a successor {@link Vertex} of the focus and connects the successor back to the focus
   * @param focus the Vertex which gets the new successor
   * @param iedge attach the successor at this edge of the focus
   * @param distance from the origin Vertex
   * @return index of new successor vertex, or -1 if attached to an existing vertex
   */
  public int attach(Vertex focus, int iedge, int distance) {
    int result = -1; // future result; assume that the successor already exists
    if (focus.proxies[iedge] == null) { // proxy for this edge not yet determined
      Position proxyPos = focus.getProxyPosition(iedge);
      Vertex proxy = mPosMap.get(proxyPos);
      if (proxy != null) { // found, old 
        result = -1; // do not enqueue it
      } else { // not found - create new 
        proxy = focus.createProxy(iedge, proxyPos);
        if (sDebug >= 2) {
          System.out.println("#--------\n# call attach(vertex " + focus.toString() + ", iedge " + iedge + ")");
          System.out.println("#     createProxy "
              + proxy.getName() + "@" + proxy.rotate + proxy.expos);
        }
        result = addVertex(proxy); // enqueue new
      } // not found - create new
      focus.proxies[iedge] = proxy; // attach it
      if (SVGFile.sEnabled) {
        SVGFile.writeEdge(focus, proxy, distance, 0); // normal
      }
      focus.fixedEdges ++;
    } else { // focus.proxies[iedge] != null  - ignore
    }
    return result;
  } // attach

  private static final int MAX_ERROR = 2;

  /**
   * Computes the neighbourhood of the start {@link Vertex} up to some distance
   * @param iBaseType index of the initial {@link VertexType}
   */
  public void computeNet(int iBaseType) {
    VertexType baseType = getVertexType(iBaseType);
    int maxBase = 1; // only one base vertex at the moment
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
    }
    int distance = 0; // also index for terms
    queue.add(addVertex(new Vertex(mTypeArray.get(iBaseType))));
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
          System.out.println("# VertexList: " + mVertexList.toJSON());
          System.out.println("# dequeue ifocus " + ifocus);
        }
        Vertex focus = mVertexList.get(ifocus);
        focus.distance = distance;
        for (int iedge = 0; iedge < focus.vtype.edgeNo; iedge ++) {
          int iproxy = attach(focus, iedge, distance);
          if (iproxy >= 0) { // did not yet exist
            addedVertices ++;
            queue.add(iproxy);
            if (sDebug >= 2) {
              System.out.println("# enqueue iproxy " + iproxy + ", attached to ifocus " + ifocus + " at edge " + iedge);
            }
          } else {
            // successor existed - ignore
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
    int vlSize = mVertexList.size();
    if (mPosMap.size() != vlSize) {
      if (sDebug >= 0) {
        System.err.println("# ** assertion 3 in tiling.toString: " + mPosMap.size()
            + " different positions, but " + vlSize + " vertices\n");
      }
    }
    if (sDebug >= 1) {
      System.out.println("# final net\n" + toJSON());
    }
    if (true) { // this is always output
      System.out.println(baseType.aSeqNo + "\ttiler\t0\t" + mTypeArray.get(iBaseType).galId + "\t" + coordSeq.toString());
    }
    if (BFile.sEnabled) { // close b-file
      BFile.close();
    }
    if (errorCount == MAX_ERROR || mMaxDistance == termNo - 1) { // was -1
      System.err.println("# " + baseType.aSeqNo + " " + baseType.galId + ":\t"
          + String.valueOf(mMaxDistance + 1) + " terms verified");
    }
    if (SVGFile.sEnabled) {
      for (int ind = 0; ind < vlSize; ind ++) { // ignore reserved [0..1]
        Vertex focus = mVertexList.get(ind);
        SVGFile.writeVertex(focus, maxBase, 0);
      } // for vertices
    } // SVG
  } // computeNet

} // class Tiling

