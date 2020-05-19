/* Properties and methods for a uniform tiling and its coordination sequences
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-15, Georg Fischer: extracted from Tiler.java
 */
// package $(PACK);
// import $(PACK).Position;
// import $(PACK).PositionMap;
// import $(PACK).Vertex;
// import $(PACK).VertexList;
// import $(PACK).VertexType;
// import $(PACK).VertexTypeArray;
// import $(PACK).Z;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * This class generates coordination sequences for k-uniform tilings
 * in the OEIS as specified by Brian Galebach.
 * A uniform tiling is built from a subset of the regular polygones
 * triangle, square, hexagon and dodecagon (other regular polygones like
 * the pentagon cannot be used). All edges are of unit length.
 * At the corners one of the 11 archimedian vertex types occur,
 * maybe in reverse (flipped) orientation. 
 * A coordination sequence enumerates the number of vertices
 * which have a certain minimal distance to the base vertex.
 * @author Georg Fischer
 */
public class TilingSequence implements Serializable
    // , Sequence
    {
  public final static String CVSID = "@(#) $Id: Vertex.java $";

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;

  /** Possible {@link VertexType}s in this tiling */
  public VertexTypeArray mTypeArray;
  
  /** Allocated vertices */
  public VertexList mVertexList;

  /** Positions to vertices */
  public PositionMap mPosMap; 

  /** Index of the base {@link Vertex} for the coordination sequence */
  public int mBaseIndex; 

  /** Queue for vertices which must be investigated for next shell */
  private LinkedList<Integer> mQueue = new LinkedList<Integer>();
  
  /** Distance of the current shell to the baseVertex */
  private int mDistance; 
  
  /** how many vertices were added for current shell */
  private int mShellCount;
  
  /**
   * Empty Constructor - not used.
   */
  public TilingSequence() {
  } // Constructor(int)

  /**
   * Constructor.
   * Initializes the data structures of <em>this</em> TilingSequence.
   * @param typeArray array of {@link VertexTypes} for this TilingSequence
   * @param maxDistance maximum distance to be computed,
   * number of terms in coordination sequence
   */
  public TilingSequence(final VertexTypeArray typeArray) {
    mDistance = 0;
    configure(typeArray);
  } // Constructor(int)

  /**
   * Configures the data structures of <em>this</em> TilingSequence.
   * @param typeArray array of {@link VertexTypes} for this TilingSequence
   */
  protected void configure(final VertexTypeArray typeArray) {
    mTypeArray = typeArray;
    mTypeArray.complete();
    initialize(1);
  } // initialize(VertexTypeArray)

  /**
   * Initializes the tiling's dynamic data structures only.
   * @param baseIndex {@link Vertex} for the start of the coordination sequence
   */
  protected void initialize(final int baseIndex) {
    mBaseIndex  = baseIndex;
    mPosMap     = new PositionMap();
    mVertexList = new VertexList();
    mQueue.add(addVertex(new Vertex(mTypeArray.get(baseIndex))));
    mShellCount = 1;
  } // initialize(int)

  /**
   * Gets a {@link VertexType}
   * @param index of the VertexType, 0=A, 1=B and so on.
   * @return a number &gt;= 0, 
   */
  public VertexType getVertexType(final int index) {
    return mTypeArray.get(index);
  } // getVertexType

  /**
   * Adds an existing {@link Vertex} to the array of known vertices, and to the HashMap for {@link Position}s of vertices
   * @param vertex existing Vertex
   * @return index of added Vertex in {@link #mVertices}
   */
  public int addVertex(final Vertex vertex) {
    vertex.index = mVertexList.size();
    mVertexList.put(vertex);
    mPosMap    .put(vertex);
    return vertex.index;
  } // addVertex

  /**
   * Returns a JSON representation of the tiling
   * @return JSON for all major data structures
   */
  public String toxJSON() {
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
  public int attach(final Vertex focus, final int iedge, final int distance) {
    int result = -1; // future result; assume that the successor already exists
    if (focus.proxies[iedge] == null) { // proxy for this edge not yet determined
      final Position proxyPos = focus.getProxyPosition(iedge);
      Vertex proxy = mPosMap.get(proxyPos);
      if (proxy != null) { // found, old 
        result = -1; // do not enqueue it
      } else { // not found - create new 
        proxy = focus.createProxy(iedge, proxyPos);
        result = addVertex(proxy); // enqueue new
      } // not found
      focus.proxies[iedge] = proxy; // attach it
      if (SVGFile.sEnabled) {
        SVGFile.writeEdge(focus, proxy, distance, 0); // normal
      }
      focus.fixedEdges ++;
    // else focus.proxies[iedge] != null - ignore
    }
    return result;
  } // attach

  /**
   * Gets the next term of the sequence.
   * Creates and connects all vertices of the next shell, and returns their count.
   */
  // @Override
  public Z next() {
    Z result = Z.valueOf(mShellCount); // return previous shell count
    mShellCount = 0; // start to count vertices in next shell
    int mustProcess = mQueue.size();
    while (mustProcess > 0 && mQueue.size() > 0) { // mQueue not empty
      final int ifocus = mQueue.poll(); // index of next vertex to be processed
      mustProcess --;
      final Vertex focus = mVertexList.get(ifocus);
      focus.distance = mDistance;
      for (int iedge = 0; iedge < focus.vtype.edgeNo; iedge ++) {
        int iproxy = attach(focus, iedge, mDistance);
        if (iproxy >= 0) { // did not yet exist
          mShellCount ++;
          mQueue.add(iproxy);
        // else successor existed - ignore
        }
      } // for iedge
    } // while portion not exhausted and mQueue not empty
    mDistance ++;
    return result;
  } // next()

} // class TilingSequence

