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
// import $(PACK).Sequence;
// import $(PACK).Z;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * This class generates coordination sequences for k-uniform tilings
 * in the OEIS as specified by Brian Galebach.
 * A uniform tiling is built from a subset of the regular polygons
 * triangle, square, hexagon and dodecagon (other regular polygons like
 * the pentagon cannot be used). All edges are of unit length.
 * At the corners one of the 11 archimedian vertex types occur,
 * maybe in reverse (flipped) orientation. 
 * A coordination sequence enumerates the number of vertices
 * which have a certain minimal distance to the base vertex.
 *
 * @author Georg Fischer
 */
public class TilingSequence implements Serializable, Sequence
    {
  public final static String CVSID = "@(#) $Id: Vertex.java $";

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;

  /** index of the first sequence element */
  protected int mOffset;

  /** Possible {@link VertexType}s in this tiling */
  public VertexTypeArray mTypeArray;
  
  /** Allocated vertices */
  public VertexList mVertexList;

  /** Positions to vertices */
  public PositionMap mPosMap; 

  /** Index of the base {@link Vertex} for the coordination sequence */
  public int mBaseIndex; 

  /** Queue for vertices which must be investigated for next shell */
  private LinkedList<Integer> mQueue;
  
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
   * Constructor from {@link VertexTypeArray}.
   * Initializes the data structures of <em>this</em> TilingSequence.
   * @param offset index of first sequence element
   * @param typeArray array of {@link VertexTypes} for this TilingSequence
   */
  public TilingSequence(final int offset, final VertexTypeArray typeArray) {
    mOffset = offset;
    mDistance = 0;
    mShellCount = 0;
    configure(typeArray);
  } // Constructor(int)

  /**
   * Constructor from pairs of Strings.
   * Initializes the data structures of <em>this</em> TilingSequence.
   * @param offset index of first sequence element
   * @param pairs String array of (vertexId, taRotList)
   */
  public TilingSequence(final int offset, String[] pairs) {
    mOffset = offset;
    final int vertexTypeNo = pairs.length;
    VertexTypeArray typeArray = new VertexTypeArray(vertexTypeNo);
    for (int ipair = 0; ipair < vertexTypeNo; ipair ++) {
      typeArray.decodeNotation(pairs[ipair]);
    } // for ipair
    mDistance = 0;
    mShellCount = 0;
    Vertex         .sDebug = sDebug;
    VertexType     .sDebug = sDebug;
    VertexTypeArray.sDebug = sDebug;
    configure(typeArray);
  } // Constructor(int)

  /**
   * Configures the data structures of <em>this</em> {@link TilingSequence},
   * and sets the first {@link VertexType} as base vertex.
   * @param typeArray array of VertexType for this TilingSequence
   */
  protected void configure(final VertexTypeArray typeArray) {
    mTypeArray = typeArray;
    mTypeArray.complete();
    setBaseIndex(0);
  } // configure(VertexTypeArray)

  /**
   * Sets one base index, and initializes the tiling's dynamic data structures.
   * @param baseIndex {@link Vertex} for the start of the coordination sequence.
   * This index starts at 0! 
   * @return number of queued vertices (1)
   */
  public int setBaseIndex(final int baseIndex) {
    mBaseIndex  = baseIndex;
    mPosMap     = new PositionMap();
    mVertexList = new VertexList();
    mQueue      = new LinkedList<Integer>();
    int ifocus  = addVertex(new Vertex(mTypeArray.get(baseIndex)));
    mQueue.add(ifocus);
    mShellCount = mQueue.size();
    if (sDebug >= 1) {
        System.out.println(toJSON());
    }
    return mShellCount;
  } // setBaseIndex(int)

  /**
   * Sets one base index, and initializes the tiling's dynamic data structures.
   * @param baseIndex {@link Vertex} for the start of the coordination sequence.
   * @param baseEdge number of an edge of the vertex with {@link VertexType} index <em>baseIndex</em>;
   * the polygon is to the right of this edge viewed in the direction of the proxy
   * at the end of the edge.<br />
   * All vertices belonging to this polygon constitute the first shell
   * (with offset 1), so these "loose" coordination sequences start with either 
   * 3, 4, 6 or 12.<br />
   * <em>baseIndex</em> and <em>iedge</em> start at 0! 
   * @return number of queued vertices (number of corners of base polygon)
   */
  public int setBasePolygon(final int baseIndex, final int baseEdge) {
    int ifocus = setBaseIndex(baseIndex) - 1;
    final int distance = 1;
    Vertex focus = mVertexList.get(ifocus);
    focus.distance = distance;
    int iedge = baseEdge;
    final int cornerNo = focus.vtype.polys[baseEdge]; // number of corners of the polygon to the right of the edge
    for (int ipoly = 1; ipoly < cornerNo; ipoly ++) { // enqueue all corners of the polygon
      final Vertex proxy = attach(focus, iedge);
      mQueue.add(proxy.index);
      iedge = focus.vtype.pxEdges[iedge] - proxy.orient;
      if (iedge < 0) {
        iedge += proxy.vtype.edgeNo;
      } else if (iedge >= proxy.vtype.edgeNo) {
        iedge = 0;
      }
      focus = proxy;
      focus.distance = distance;
    } // for ipoly
    mShellCount = mQueue.size();
    if (sDebug >= 1) {
        System.out.println(toJSON());
    }
    return mShellCount;
  } // setBasePolygon(int)

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
    final int result = mVertexList.add(vertex);
    mPosMap.put(vertex);
    return result;
  } // addVertex

  /**
   * Returns a JSON representation of the tiling
   * @return JSON for all major data structures
   */
  public String toJSON() {
    return mTypeArray .toJSON()
        +  mVertexList.toJSON()
        +  mPosMap    .toJSON()
        +  "\n, mBaseIndex: " + mBaseIndex;
  } // toJSON

  /**
   * Creates a successor {@link Vertex} of the focus and connects the successor back to the focus
   * @param focus the Vertex which gets the new proxy (successor)
   * @param iedge attach the proxy at this edge of the focus
   * @return proxy vertex, either already existing or new created.
   */
  public Vertex attach(final Vertex focus, final int iedge) {
    final VertexType foType = focus.vtype;
    final int pxAngle       = // focus.getAngle(iedge); // points to the proxy
        Vertex.normAngle(focus.rotate + focus.orient * foType.sweeps[iedge]); 
    final Position proxyPos = focus.expos.moveUnit(pxAngle);
    int iproxy              = mPosMap.get(proxyPos); // future result
    final int pxEdge        = foType.pxEdges[iedge];
    Vertex proxy = null;
    if (iproxy >= 0) { // found old
      proxy  = mVertexList.get(iproxy);
    } else { // iproxy < 0: not found, create new 
      // *** begin inlined method: iproxy = createProxy(focus, iedge, proxyPos); // sets back link to focus
      proxy              = new Vertex(mTypeArray.get(foType.pxTinds[iedge]), focus.orient * foType.pxOrients[iedge]); // create a new Vertex
      proxy.expos        = focus.expos.moveUnit(pxAngle);
      final int pxRota   = focus.orient * foType.pxRotas[iedge];
      proxy.rotate       = Vertex.normAngle(focus.rotate + pxRota);
      if (sDebug >= 2) {
        System.out.println("#     createProxy(iedge " + iedge + "proxyPos " + proxyPos.toString()
            + ")." + focus.index + focus.getName() + "@" + focus.rotate + focus.expos
            + " -> pxType " + proxy.vtype.index + ", pxRota " + pxRota + ", pxAngle " + pxAngle
            + " => " + proxy.toString());
      }
      iproxy = addVertex(proxy);
      // *** end inlined method: return result;
      proxy  = mVertexList.get(iproxy); 
    } // not found
    focus.pxInds[iedge] = proxy.index; // attach it - link forward to the proxy
    final int trialEdge = proxy.normEdge(pxEdge);
    int backLink = proxy.pxInds[trialEdge]; 
    if (// false && 
        backLink != focus.index) { // correct the link back to the focus
      if (backLink >= 0) { // was set previously, but differently
      	final int foundEdge = focus.findProxyEdge(proxy);
        if (sDebug >= 1) {
          System.out.println("# assertion 10: dist=" + focus.distance + " focus " + focus.getName() + focus.index 
              + "\texpected in proxy " + proxy.getName() + proxy.index + ".vtInds[" + trialEdge + "] " 
              + "\tbut found in [" + foundEdge + "]");
        } else {
          System.out.println("# assertion 10: dist=" + focus.distance + " focus " + focus.getName() + focus.index 
              + "\texpected in proxy " + proxy.getName() + proxy.index + ".vtInds[" + trialEdge + "] " 
              + "\tbut found in [" + foundEdge + "]");
        }
        if (foundEdge >= 0) {
          proxy.pxInds[foundEdge] = focus.index;
        }
      } else { // backLink < 0
        proxy.pxInds[trialEdge] = focus.index;
      }
    } // else backLink is ok
    return proxy;
  } // attach

  /**
   * Gets the next term of the sequence.
   * Creates and connects all vertices of the next shell, and returns their count.
   */
  // @Override
  public Z next() {
    final Z result = Z.valueOf(mShellCount); // return previous shell count
    mShellCount = 0; // start to count vertices in next shell
    int mustProcess = mQueue.size();
    while (mustProcess > 0 && mQueue.size() > 0) { // mQueue not empty
      final int ifocus = mQueue.poll(); // index of next vertex to be processed
      mustProcess --;
      final Vertex focus = mVertexList.get(ifocus);
      focus.distance = mDistance;
      for (int iedge = 0; iedge < focus.vtype.edgeNo; iedge ++) {
        if (focus.pxInds[iedge] < 0) { // proxy for this edge not yet determined
          final Vertex proxy = attach(focus, iedge);
          if (proxy.distance < 0) { // is not yet in the set of shells
            proxy.distance = mDistance;
            mQueue.add(proxy.index);
            mShellCount ++;
          }
        } // proxy not yet determined
      } // for iedge
    } // while portion not exhausted and mQueue not empty
    mDistance ++;
    return result;
  } // next()
  
  /**
   * Main method, filters a file, selects a {@link VertexTypeArray] for a tiling,
   * dumps the progress of the tilings' generation and
   * possibly writes an SVG drawing file.
   * @param args command line arguments
   */
  public static void main(String[] args) {
    final long startTime  = System.currentTimeMillis();
    int mMaxDistance = 16;
    int basePoly     = -1; // not specified
    int id           =  0;
    try {
      int iarg = 0;
      while (iarg < args.length) { // consume all arguments
        String opt       = args[iarg ++];
        if (false) {
        } else if (opt.equals("-dist")  ) {
          mMaxDistance          = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-d")     ) {
          TilingSequence.sDebug = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-id")    ) {
          id                    = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-poly")  ) {
          basePoly              = Integer.parseInt(args[iarg ++]);
        } else {
          System.err.println("??? invalid option: \"" + opt + "\"");
        }
      } // while args
      
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }

    final TilingSequence mTiling = new TilingSequence(0, new String[] // Gal.2.1.1:
        { "12.6.4;A180-,A120-,B90+"
        , "6.4.3.4;A270+,A210-,B120+,B240+"
        });
    if (basePoly < 0) {
      mTiling.setBaseIndex  (id);
    } else {
      mTiling.setBasePolygon(id, basePoly);
    }
    for (int index = 0; index < mMaxDistance; index ++) {
      System.out.print((index == 0 ? "" : ",") + mTiling.next());
    } // for index
    System.out.println();

    System.err.println("# elapsed: " + String.valueOf(System.currentTimeMillis() - startTime) + " ms");
  } // main

} // class TilingSequence
