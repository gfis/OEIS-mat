/* Generate tilings from Galebach's list
 * 2020-04-21, Georg Fischer
 */
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Serializable;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.WritableByteChannel;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
// import  org.apache.log4j.Logger;

/**
 * Class for the generation of tilings and their coordinations sequences.
 * @author Georg Fischer
 */
public class Tiler {
  private static final long serialVersionUID = 3L;
  public final static String CVSID = "@(#) $Id: Tiler.java $";
  /** log4j logger (category) */
  // private Logger log;

  /**
   * Empty constructor.
   */
  protected Tiler() {
    // log = Logger.getLogger(Tiler.class.getName());
    mNumTerms = 32;
    mOffset   = 0;
    mSVG      = false;
    mGalId    = "Gal.2.1.1";
  } // Tiler()

  /** Debugging mode: 0=none, 1=some, 2=more */
  protected static int sDebug = 0;

  /**
   * Set the debugging level.
   * @param level code for the debugging level: 0 = none, 1 = some, 2 = more.
   */
  public void setDebug(int level) {
    sDebug = level;
  }

  /** Standard encoding for all files */
  private static final String sEncoding = "UTF-8";

  /** Brian Galebach's identification of a VertexType, of the form "Gal.u.t.v" */
  private String mGalId;

  /** Amount of indenting for JSON output */
  protected static String sIndent = "";

  /** Increase the indent
   */
  protected void  pushIndent() {
    sIndent += "    ";
  } // pushIndent

  /** Decrease the indent
   */
  protected void popIndent() {
    if (sIndent.length() >= 4) {
      sIndent = sIndent.substring(4);
    }
  } // popIndent

  /** number of terms to be generated */
  private int mNumTerms;

  /** Maximum nesting level  */
  private int mMaxLevel;

  /** Offset1 of the sequences */
  private int mOffset;

  /** Current tiling */
  private Tiling mTiling;
  /**
   * Join an array of integers
   * @param delim delimiter
   * @param vector integer array
   * @return a String of the form "[elem1,elem2.elem3]"
   */
  protected static String join(String delim, int[] vector) {
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

  private static final Double SQRT2 = Math.sqrt(2.0);
  private static final Double SQRT3 = Math.sqrt(3.0);
  private static final Double SQRT6 = SQRT2 * SQRT3;

  /**
   * Class for an exact position of a {@link Vertex}.
   * The x axis is to the right and the y axis leads downwards (SVG coordinate system).
   * The x and y coordinates are represented by tuples (a,b,c,d)
   * such that (a + b*sqrt(2) + c*sqrt(3) + d*sqrt(6)) / 4 give the
   * real value for a position.
   */
  protected  class Position {
    protected short[] xtuple;
    protected short[] ytuple;

    /**
     * Empty constructor - creates the origin (0,0).
     */
    public Position() {
      xtuple = new short[4];
      ytuple = new short[4];
      Arrays.fill(xtuple, (short) 0);
      Arrays.fill(ytuple, (short) 0);
    } // Position()

    /**
     * Constructor
     * @param xparm tuple for exact x representation
     * @param yparm tuple for exact y representation
     */
    public Position(short[] xparm, short[]yparm) {
      xtuple = xparm;
      ytuple = yparm;
    } // Position(short[], short[])

    /**
     * Computes the cartesian coordinate value from an exact position tuple
     * @return a double value
     */
    public Double cartesian(short[] tuple) {
      return ( tuple[0]
             + tuple[1] * SQRT2
             + tuple[2] * SQRT3
             + tuple[3] * SQRT6
             ) / 4.0;
    } // cartesian

    /**
     * Adds a Position to <em>this</em> Position.
     * @param pos2 Position to be added
     * @return this + pos2
     */
    public Position add(Position pos2) {
      Position result = new Position();
      for (int ipos = 0; ipos < 4; ipos ++) {
        result.xtuple[ipos] = (short) (this.xtuple[ipos] + pos2.xtuple[ipos]);
        result.ytuple[ipos] = (short) (this.ytuple[ipos] + pos2.ytuple[ipos]);
      } // for ipos
      return result;
    } // add

    /**
     * Subtracts a Position from <em>this</em> Position.
     * @param pos2 Position to be subtracted
     * @return this - pos2
     */
    public Position subtract(Position pos2) {
      Position result = new Position();
      for (int ipos = 0; ipos < 4; ipos ++) {
        result.xtuple[ipos] = (short) (this.xtuple[ipos] - pos2.xtuple[ipos]);
        result.ytuple[ipos] = (short) (this.ytuple[ipos] - pos2.ytuple[ipos]);
      } // for ipos
      return result;
    } // subtract

    /**
     * Returns a representation of the Position
     * @return a tuple "(x,y)" with 4 decimals
     */
    public String toString() {
      return String.format("(%.4f;%.4f)", cartesian(xtuple), cartesian(ytuple))
          .replaceAll("\\,", ".").replaceAll("\\;", ",");
    } // toString

    /**
     * Gets the cartesian x coordinate (to the right) from <em>this</em> Position
     * @return a String with 4 decimal digits
     */
    public String getX() {
      return String.format("%.4f", cartesian(xtuple))
          .replaceAll("\\,", ".");
    } // getX

    /**
     * Gets the cartesian x coordinate (to the right) from <em>this</em> Position
     * @return a String with 4 decimal digits
     */
    public String getY() {
      return String.format("%.4f", cartesian(ytuple))
          .replaceAll("\\,", ".");
    } // getY

    /**
     * Moves <em>this</em> Position by a unit distance in some angle
     * @param angle in degrees 0..360
     * @return new Position
     */
    public Position moveUnit(int angle) {
      int icircle = Math.round(angle / 15) % 24;
      return this.add(circlePos[icircle]);
    }

  } // class Position

  /** Positions in the unit circle = increments for the next {@link Vertex} */
  private final Position[] circlePos = new Position[]
      { new Position(new short[] { 4, 0, 0, 0}, new short[] { 0, 0, 0, 0}) // [ 0]   0     1.0000,    0.0000
      , new Position(new short[] { 0, 1, 0, 1}, new short[] { 0,-1, 0, 1}) // [ 1]  15     0.9659,    0.2588
      , new Position(new short[] { 0, 0, 2, 0}, new short[] { 2, 0, 0, 0}) // [ 2]  30     0.8660,    0.5000
      , new Position(new short[] { 0, 2, 0, 0}, new short[] { 0, 2, 0, 0}) // [ 3]  45     0.7071,    0.7071
      , new Position(new short[] { 2, 0, 0, 0}, new short[] { 0, 0, 2, 0}) // [ 4]  60     0.5000,    0.8660
      , new Position(new short[] { 0,-1, 0, 1}, new short[] { 0, 1, 0, 1}) // [ 5]  75     0.2588,    0.9659
      , new Position(new short[] { 0, 0, 0, 0}, new short[] { 4, 0, 0, 0}) // [ 6]  90     0.0000,    1.0000
      , new Position(new short[] { 0, 1, 0,-1}, new short[] { 0, 1, 0, 1}) // [ 7] 105    -0.2588,    0.9659
      , new Position(new short[] {-2, 0, 0, 0}, new short[] { 0, 0, 2, 0}) // [ 8] 120    -0.5000,    0.8660
      , new Position(new short[] { 0,-2, 0, 0}, new short[] { 0, 2, 0, 0}) // [ 9] 135    -0.7071,    0.7071
      , new Position(new short[] { 0, 0,-2, 0}, new short[] { 2, 0, 0, 0}) // [10] 150    -0.8660,    0.5000
      , new Position(new short[] { 0,-1, 0,-1}, new short[] { 0,-1, 0, 1}) // [11] 165    -0.9659,    0.2588
      , new Position(new short[] {-4, 0, 0, 0}, new short[] { 0, 0, 0, 0}) // [12] 180    -1.0000,    0.0000
      , new Position(new short[] { 0,-1, 0,-1}, new short[] { 0, 1, 0,-1}) // [13] 195    -0.9659,   -0.2588
      , new Position(new short[] { 0, 0,-2, 0}, new short[] {-2, 0, 0, 0}) // [14] 210    -0.8660,   -0.5000
      , new Position(new short[] { 0,-2, 0, 0}, new short[] { 0,-2, 0, 0}) // [15] 225    -0.7071,   -0.7071
      , new Position(new short[] {-2, 0, 0, 0}, new short[] { 0, 0,-2, 0}) // [16] 240    -0.5000,   -0.8660
      , new Position(new short[] { 0, 1, 0,-1}, new short[] { 0,-1, 0,-1}) // [17] 255    -0.2588,   -0.9659
      , new Position(new short[] { 0, 0, 0, 0}, new short[] {-4, 0, 0, 0}) // [18] 270     0.0000,   -1.0000
      , new Position(new short[] { 0,-1, 0, 1}, new short[] { 0,-1, 0,-1}) // [19] 285     0.2588,   -0.9659
      , new Position(new short[] { 2, 0, 0, 0}, new short[] { 0, 0,-2, 0}) // [20] 300     0.5000,   -0.8660
      , new Position(new short[] { 0, 2, 0, 0}, new short[] { 0,-2, 0, 0}) // [21] 315     0.7071,   -0.7071
      , new Position(new short[] { 0, 0, 2, 0}, new short[] {-2, 0, 0, 0}) // [22] 330     0.8660,   -0.5000
      , new Position(new short[] { 0, 1, 0, 1}, new short[] { 0, 1, 0,-1}) // [23] 345     0.9659,   -0.2588
      };

  /** Angles in degrees for the 5 polygones:   triangle, square, hexagon, octogon,   dodecagon */
  //                                          0 1 2   3       4 5      6 7      8 9 10 11   12
  private final int[] polyAngles = new int[] {0,0,0, 60,     90,0,   120,0,   135,0, 0, 0, 150};

  /**
   * Tests the computation of {@link Position}s
   */
  public void testCirclePositions() {
    Position origin = new Position();
    for (int ipos = 0; ipos < circlePos.length + 1; ipos ++) {
      Position pos = origin.moveUnit(ipos * 15);
      System.out.println(String.format("[%2d], %3d = %s", ipos, ipos * 15, pos.toString()));
      writeSVG("<line class=\"k" + String.valueOf(ipos % 8) 
          + " x1=\"0.0\" y1=\"0.0\" x2=\"" + pos.getX() + "\" y2=\"" + pos.getY() + "\" />");
    } // for ipos
    for (int ipos = 0; ipos < circlePos.length; ipos += 4) {
      int ipos8 = (ipos + 8) % 24;
      Position hexPos = circlePos[ipos].add(circlePos[ipos8]);
      System.out.println(String.format("[%2d] + [%2d] = %8s,%8s"
          , ipos, ipos8, hexPos.getX(), hexPos.getY()));
    } // for ipos
  } // testCirclePositions

  /**
   * Class for an allowed vertex type.
   */
  protected class VertexType { // numbered 1, 2, 3 ... ; 0 is not used
    String galId; // e.g. "Gal.2.1.1"
    int edgeNo; // number of edges
    int[] polys; // number of corners of the regular (3,4,6,8,12) polypolys (shapes) which are
        // arranged counter-clockwise around this vertex type.
        // First edge goes from (x,y)=(0,0) to (1,0); the shape is to the left of the edge
    int[] tars; // target vertex type indices (counter-clockwise if positive, clockwise if negative)
    int[] angles; // how many degrees must the target vertex type be rotated
    String sequence; // list of terms of the coordination sequence

    /**
     * Empty constructor
     */
    VertexType() {
      galId    = "Gal.0.0.0";
      edgeNo   = 0;
      polys    = new int[0];
      tars     = new int[0];
      angles   = new int[0];
      sequence = "";
    } // VertexType()

    /**
     * Constructor
     * @param galId Galebach's id Gal.u.t.v
     * @param descriptor counter-clockwise list of the polygones followed by the list of types and angles
     * @param sequence a list of initial terms of the coordination sequence
     */
    VertexType(String galId, String descriptor, String sequence) {
      // for example: A265035   Gal.2.1.1   3.4.6.4; 4.6.12 12.6.4; A 180'; A 120'; B 90    1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
      this.galId = galId;
      this.sequence = sequence;
      String[] parts = descriptor.split("\\;\\s*");
      edgeNo = parts.length - 1;
      polys  = new int[edgeNo];
      tars   = new int[edgeNo];
      angles = new int[edgeNo];
      String[] corners = parts[0].split("\\.");
      for (int iedge = 0; iedge < edgeNo; iedge ++) {
        try {
          polys [iedge] = 0;
          tars  [iedge] = parts[iedge + 1].charAt(0) - 'A' + 1;
          if (parts[iedge + 1].endsWith("'")) {
            tars[iedge]  = - tars[iedge];
            parts[iedge + 1] = parts[iedge+ 1].replaceAll("\\'","");
          }
          angles[iedge] = 0;
          polys [iedge] = Integer.parseInt(corners[iedge]);
          angles[iedge] = Integer.parseInt(parts[iedge + 1].substring(2));
        } catch (Exception exc) {
          System.err.println("descriptor \"" + descriptor + "\" bad");
        }
      } // for iedge
    } // VertexType(String, String, String)

    /**
     * Returns a representation of the VertexType
     * @return JSON
     */
    public String toString() {
      pushIndent();
      String result
          = "{ \"galId\": \"" + galId + "\""
          + ", \"polys\": "   + join(",", polys)
          + ", \"tars\": "    + join(",", tars)
          + ", \"angles\": "  + join(",", angles)
          + " }\n";
      popIndent();
      return result;
    } // toString

  } // class VertexType

  /**
   * Class for an allocated vertex.
   */
  protected class Vertex { // numbered 1, 2, 3 ... ; 0 is not used
    int typeIndex; // 1, 2, 3 ... for counter-clockwise orientation (0 is reserved), or -1, -2 for clockwise
    int angle; // the vertex type was rotated counter-clockwise by so many degrees
    Position expos; // exact Position of the Vertex
    int fixedEdges; // number of allocated neighbours = edges
    int[] shapes; // list of indices in left shapes
    int[] succs; // list of indices in successor vertices
    int[] preds; // list of indices in predecessor vertices

    /**
     * Empty constructor, only a placeholder in order to avoid vertex index 0
     */
    public Vertex() {
      this(0);
    /*
      typeIndex  = 0; // reserved
      angle      = 0;
      expos      = new Position();
      fixedEdges = 0;
      int edgeNo = 0;
      shapes     = new int[edgeNo];
      succs      = new int[edgeNo];
      preds      = new int[edgeNo];
    */
    } // Vertex()

    /**
     * Constructor with an index of a VertexType
     * @param itype index of type of the new vertex, is positive for counter-clockwise,
     * negative for clockwise orientation
     * @param ipred index of predecessor vertex which needs <em>this</em> new successor vertex
     * @param iedge which edge of the predecessor leads to <em>this</em> new successor vertex
     */
    public Vertex(int itype) {
      typeIndex  = itype; // may be negative
      itype      = Math.abs(itype); // now positive
      angle      = 0;
      expos      = new Position();
      int edgeNo = itype == 0 ? 0 : mTiling.vertexTypes[itype].edgeNo;
      shapes     = new int[edgeNo];
      succs      = new int[edgeNo];
      preds      = new int[edgeNo];
      Arrays.fill(shapes, 0);
      Arrays.fill(succs , 0);
      Arrays.fill(preds , 0);
    } // Vertex(int)

    /**
     * Gets the type of <em>this</em> Vertex
     * @return a {@link VertexType}
     */
    public VertexType getType() {
      return mTiling.vertexTypes[Math.abs(typeIndex)];
    } // getType

    /**
     * Returns a representation of the Vertex
     * @return JSON for edges
     */
    public String toString() {
      pushIndent();
      String result
          = "{ \"type\":"    + String.format("%3d", typeIndex)
          + ", \"angle\": "  + String.format("%3d", angle)
          + ", \"fixed\": "  + fixedEdges
          + ", \"succs\": "  + join(",", succs       )
      //  + ", \"preds\": "  + join(",", preds       )
      //  + ", \"shapes\": " + join(",", shapes)
          + ", \"x\": "      + expos.getX()
          + ", \"y\": "      + expos.getY()
          + " }\n";
      popIndent();
      return result;
    } // toString

  } // class Vertex

  /**
   * Gets the angle for an edge of a {@link VertexType}
   * @param iedge number of the edge, zero-based
   * @return angle in degrees, for example 6.4.4.3:
   * <pre>
   * iedge       =  0   1   2   3
   * polys     s = [6  .4  .4  .3]
   * type > 0:  0 120  90  90  60  (counter-clockwise)
   * type < 0:  0 120  60  90  90  (clockwise)
   * </pre>
   */
  public int getEdgeAngle(int typeIndex, int iedge) {
    int itype = Math.abs(typeIndex);
    int ipoly = 0;
    int angle = 0;
    int[] polys = mTiling.vertexTypes[itype].polys;
    if (iedge > 0) {
      if (itype == typeIndex) { // positive, counter-clockwise: 6.4.4.3
        while (ipoly < iedge) {
          angle += polyAngles[polys[ipoly]];
          ipoly ++;
        }
      } else {                  // negative, clockwise:         3.4.4.6
        ipoly = polys.length;
        while (ipoly > polys.length - iedge) {
          ipoly --;
          angle += polyAngles[polys[ipoly]];
        }
      }
      if (sDebug >= 2) {
        System.out.println("# getEdgeAngle(" + typeIndex + ", " + iedge + "): polys[" + ipoly + "]=" 
            + polys[ipoly] + ", new angle=" + angle);
      }
    } // iedge > 0
    return angle;
  } // getEdgeAngle

  /**
   * Gets the edge number (zero based) of a rotated successor {@link Vertex}
   * which matches an angle from the focus Vertex.
   * @param succ rotated successor Vertex
   * @param foAngle angle of an edge from the rotated focus Vertex
   * @return zero based edge number of the successor, or -1 if not matched
   */
  public int getMatchingEdge(Vertex succ, int foAngle) {
    int itype = Math.abs(succ.typeIndex);
    int[] polys = mTiling.vertexTypes[itype].polys;
    int angle = succ.angle;
    int iedge = 0;
    boolean busy = true;
    if (itype == succ.typeIndex) { // positive, counter-clockwise: 6.4.4.3
      while (busy && iedge < polys.length) { // try to find a matching edge
        if (sDebug >= 2) {
          System.out.println("# getMatchingEdge+(" + itype + "," + foAngle + "): angle=" + angle + ", iedge=" + iedge);
        }
        if ((angle + 180) % 360 == foAngle) {
          busy = false; // match found
        } else {// not matched, advance
          angle += polyAngles[polys[iedge]];
          iedge ++;
        } // advance +
      } // while busy +
    } else {                       // negative, clockwise:         3.4.4.6
      iedge = polys.length - 1;
      while (busy && iedge >= 0) { // try to find a matching edge
        if (sDebug >= 2) {
          System.out.println("# getMatchingEdge+(" + itype + "," + foAngle + "): angle=" + angle + ", iedge=" + iedge);
        }
        if ((angle + 180) % 360 == foAngle) {
          busy = false; // match found
        } else {// not matched, advance
          angle += polyAngles[polys[iedge]];
          iedge --;
        } // advance -
      } // while busy -
    } // negative
    if (busy) { // not found
      iedge = -1; // failure
    }
    if (sDebug >= 1) {
      System.out.println("# getMatchingEdge -> " + iedge);
    }
    return iedge;
  } // getMatchingEdge

  /**
   * Class for an allocated vertex.
   */
  protected class Tiling {
    /** first free allowed VertexType */
    public int ffVertexType;
    /** Allowed vertex types for this tiling */
    public VertexType[] vertexTypes; // [0] is reserved
    /** first free index in vertices */
    public int ffVertex;
    /** Allocated vertices */
    public ArrayList<Vertex> vertices; // [0] is reserved

    /**
     * Constructor
     * @param nTypes number of VertexTypes
     */
    public Tiling(int nTypes) { // Constructor
      vertexTypes  = new VertexType[nTypes + 1]; // [0] is not used / reserved
      ffVertexType = 0;
      vertexTypes[ffVertexType ++] = new VertexType(); // the reserved element [0]
      initialize();
    } // Tiling()

    /**
     * Initializes the dynamic data structures of <em>this</em> Tiling.
     */
    public void initialize() {
      sIndent  = "";
      vertices = new ArrayList<Vertex>(256);
      vertices.add(new Vertex()); // [0] is not used / reserved
      ffVertex = vertices.size();
    } // initialize

    /**
     * Adds a new VertexType
     * @param galId Galebach's id Gal.u.t.v
     * @param descriptor counter-clockwise list the polygones followed by the list of types and angles
     * @param sequence a list of initial terms of the coordination sequence
     */
    public void addVertexType(String galId, String descriptor, String sequence) {
      vertexTypes[ffVertexType ++] = new VertexType(galId, descriptor, sequence);
    } // addVertexType

    /**
     * Adds a new Vertex
     * @param itype index in {@link vertexTypes}
     * @return index in {@link vertices}
     */
    public int addVertex(int itype) {
      vertices.add(new Vertex(itype));
      ffVertex = vertices.size();
      return ffVertex - 1;
    } // addVertex

    /**
     * Returns a representation of the Tiling
     * @return JSON for types and vertices
     */
    public String toString() {
      // pushIndent();
      String result  = sIndent + "{ \"ffVertexType\": " + ffVertexType  + "\n"
                     + sIndent + ", \"vertexTypes\":\n";
      try {
        String sep = "  , ";
        for (int ind = 0; ind < ffVertexType; ind ++) {
          result += sIndent + (ind == 0 ? "  [ " : sep) + vertexTypes[ind].toString();
        } // for types
        result += sIndent + "  ]\n";
        result += sIndent + ", \"ffVertex\": " + ffVertex + "\n"
               +  sIndent + ", \"vertices\":\n";
        for (int ind = 0; ind < ffVertex; ind ++) {
          Vertex focus = vertices.get(ind);
          result += sIndent + (ind == 0 ? "  [ " : sep) + focus.toString();
        } // for vertices
        result += sIndent + "  ]\n}\n";
      } catch(Exception exc) {
        // log.error(exc.getMessage(), exc);
        System.err.println("partial result: " + result);
        System.err.println(exc.getMessage());
        exc.printStackTrace();
      }
      // popIndent();
      return result;
    } // toString

    /**
     * Creates a successor vertex and connects to it
     * @param ifocus index of the vertex which gets the new successor
     * @param iedge attach the successor at this edge
     * @return index of new successor vertex, or 0 if attached to an existing vertex
     */
    public int attach(int ifocus, int iedge) {
      int isucc = 0; // future result
      Vertex focus = vertices.get(ifocus);
      VertexType fotype = focus.getType();
      if (focus.succs[iedge] == 0) {
        focus.fixedEdges ++;
        Vertex succ = new Vertex(fotype.tars[iedge]);

        isucc = ffVertex;
        vertices.add(succ);
        ffVertex ++;
        focus.succs[iedge] = isucc;

        Position pos = focus.expos;
        int foEdgeAngle = (focus.angle + getEdgeAngle(focus.typeIndex, iedge)) % 360;
        succ.expos = focus.expos.moveUnit(foEdgeAngle);
        succ.angle = (focus.angle + fotype.angles[iedge]) % 360;
        int suEdgeNo = getMatchingEdge(succ, foEdgeAngle);
        if (sDebug >= 1) {
          System.out.println("# iedge=" + iedge
              + ", focus.angle="  + focus.angle
              + ", focus.expos="  + focus.expos.toString()
              + ", getEdgeAngle=" + foEdgeAngle
              + ", succ.angle="   + succ.angle
              + ", succ.expos="   + succ.expos.toString()
              + ", suEdgeNo="     + suEdgeNo
              );
        }
        if (suEdgeNo >= 0) {
          succ.succs[suEdgeNo] = ifocus;
        }
        if (sDebug >= 3) {
          System.out.println("# line: k" + String.valueOf(iedge % 8) 
              + "," + focus.expos.getX()
              + "," + focus.expos.getY()
              + "," +  succ.expos.getX()
              + "," +  succ.expos.getY()
              );
        }
        writeSVG("<line class=\"l" + String.valueOf((iedge) % 8) 
            + "\" x1=\"" + focus.expos.getX()
            + "\" y1=\"" + focus.expos.getY()
            + "\" x2=\"" +  succ.expos.getX() 
            + "\" y2=\"" +  succ.expos.getY() + "\" />");
      } else {
        // isucc = focus.succs[iedge];// already linked
      }
      return isucc;
    } // attach

    /**
     * Computes the neighbourhood of the start vertex up to some distance
     * @param istart index of the initial vertex type
     */
    public void computeNet(int istart) {
      LinkedList<Integer> queue = new LinkedList<Integer>();
      initialize();
      if (sDebug >= 1) {
        System.out.println("# compute neighbours of vertex type " + istart + " up to distance " + mNumTerms);
      }
      queue.add(addVertex(istart));
      int nestLevel = 1;
      while (nestLevel <= mMaxLevel) {
        int levelPortion = queue.size();
        if (sDebug >= 1) {
          System.out.println("# level " + nestLevel + ": process " + levelPortion + " vertices");
        }
        while (levelPortion > 0 && queue.size() > 0) { // queue not empty
          int ifocus = queue.poll();
          levelPortion --;
          Vertex focus = vertices.get(ifocus);
          VertexType fotype = focus.getType();
          for (int iedge = 0; iedge < fotype.edgeNo; iedge ++) {
            int isucc = attach(ifocus, iedge);
            if (isucc > 0) { // did not yet exist
              queue.add(isucc);
            }
          } // for iedge
        } // while queue not empty
        nestLevel ++;
      } // while nestLevel
      if (sDebug >= 1) {
        System.out.println("# final net\n" + toString());
      }
      if (mSVG) {
        for (int ind = 1; ind < ffVertex; ind ++) { // ignore [0]
          Vertex focus = vertices.get(ind);
          int fotype = Math.abs(focus.typeIndex);
          writeSVG("<circle class=\"c" + String.valueOf((fotype) % 8)
              + (fotype != focus.typeIndex ? " dash" : "")
              + "\" cx=\"" + focus.expos.getX()
              + "\" cy=\"" + focus.expos.getY()
              + "\" r=\""  + (ind == 1 ? "0.15" : "0.1") + "\" />");
        } // for vertices
      } // SVG 
    } // computeNet

  } // class Tiling

  /**
   * Process one record from the file
   * @param line record to be processed
   */
  private void processRecord(String line) {
    // e.g. line = A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4; A 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
    String[] fields = line.split("\\t");
    int ifield = 1; // skip aseqno
    String galId      = fields[ifield ++];
    ifield ++; // skip standard notation
    String descriptor = fields[ifield ++];
    String sequence   = fields[ifield ++];
    try {
      String[] gutv   = galId.split("\\.");
      if (false) {
      } else if (gutv[3].equals("1")) { // first of new tiling
        mTiling = new Tiling(Integer.parseInt(gutv[1]));
        mTiling.addVertexType(galId, descriptor, sequence);
      } else if (gutv[3].equals(gutv[1])) { // last of new tiling
        mTiling.addVertexType(galId, descriptor, sequence);
        System.out.println(mTiling.toString());
        // compute the net
        for (int itype = 1; itype < mTiling.ffVertexType; itype ++) {
          if (mTiling.vertexTypes[itype].galId.equals(mGalId)) { // only this one from all VertexTypes in the Tiling
            mTiling.computeNet(itype);
          }
        } // for itype
      } else {
        mTiling.addVertexType(galId, descriptor, sequence);
      }
    } catch(Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
  } // processRecord

  /**
   * Reads a file and processes all input lines.
   * @param fileName name of the input file, or "-" for STDIN
   */
  private void processFile(String fileName) {
    BufferedReader lineReader; // Reader for the input file
    String line = null; // current line from text file
    try {
      if (fileName == null || fileName.length() <= 0 || fileName.equals("-")) {
        lineReader = new BufferedReader(new InputStreamReader(System.in, sEncoding));
      } else {
        ReadableByteChannel lineChannel = (new FileInputStream(fileName)).getChannel();
        lineReader = new BufferedReader(Channels.newReader(lineChannel , sEncoding));
      }
      while ((line = lineReader.readLine()) != null) { // read and process lines
        if (! line.matches("\\s*#.*")) { // is not a comment
           if (sDebug >= 1) {
            System.out.println(line); // repeat it unchanged
          }
          processRecord(line);
        } // is not a comment
      } // while ! eof
      lineReader.close();
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    } // try
  } // processFile
  
  /** Whether an SVG image file should be written */
  private boolean mSVG;
  
  /** HOw many &gt;line&lt; elements should be written */
  private int mSVGCount;
  
  /** Writer for SVG output */
  private PrintWriter mSVGWriter;
  
  /**
   * Writes some portion of an SVG file.
   * @param xml one or more complete SVG XML elements, or 
   * "head" for SVG prelude, or 
   * "tail" for SVG postlude.
   */
  private void writeSVG(String xml) {
    if (mSVG) {
      String text = null;
      if (xml.startsWith("<")) { // complete XML element(s)
        text = xml;
        if (mSVGCount > 0) { 
          if (xml.startsWith("<line")) {
            mSVGCount --; // limit the number of line segments which are written
          }
        }
      } else if (xml.equals("head")) {
      	int w1 = 8;
      	int w2 = 2 * w1;
        text = ""
        + "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
        + "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\"\n"
        + " \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\" [\n"
        + " <!ATTLIST svg xmlns:xlink CDATA #FIXED \"http://www.w3.org/1999/xlink\">\n"
        + "]>\n"
        + "<!--\n"
        + "    Tiler - Georg Fischer. Do NOT edit here!\n"
        + "-->\n"
        + "<svg width=\"192mm\" height=\"192mm\"\n"
        + "  viewBox=\"-" + w1 + "-" + w1 + " " + w2 + " " + w2 + "\" \n"
        + "  xmlns=\"http://www.w3.org/2000/svg\" \n"
        + "  >\n"
        + "  <defs>\n"
        + "    <style type=\"text/css\"><![CDATA[\n"
        + "      rect, line { stroke-width:0.05    }\n"
        + "      circle     { stroke-width:0.02    }\n"
        + "      .dash      { stroke-dasharray:0.04}\n"
        + "      .l0 { fill: crimson     ; stroke: crimson     }\n"
        + "      .l1 { fill: yellow      ; stroke: yellow      }\n"
        + "      .l2 { fill: orange      ; stroke: orange      }\n"
        + "      .l3 { fill: lime        ; stroke: lime        }\n"
        + "      .l4 { fill: turquoise   ; stroke: turquoise   }\n"
        + "      .l5 { fill: blue        ; stroke: blue        }\n"
        + "      .l6 { fill: darkblue    ; stroke: darkblue    }\n"
        + "      .l7 { fill: darkmagenta ; stroke: darkmagenta }\n"
        + "      .l8 { fill: black       ; stroke: black       }\n"
        + "      .c0 { fill: black       ; stroke: white       }\n"
        + "      .c1 { fill: crimson     ; stroke: white       }\n"
        + "      .c2 { fill: yellow      ; stroke: black       }\n"
        + "      .c3 { fill: orange      ; stroke: white       }\n"
        + "      .c4 { fill: lime        ; stroke: black       }\n"
        + "      .c5 { fill: turquoise   ; stroke: black       }\n"
        + "      .c6 { fill: blue        ; stroke: white       }\n"
        + "      .c7 { fill: darkblue    ; stroke: white       }\n"
        + "      .c8 { fill: darkmagenta ; stroke: white       }\n"
        + "    ]]></style>\n"
        + "  </defs>\n"
        + "<title>Tiling</title>\n"
        + "<g id=\"graph0\" >\n"
        + "    <rect x=\"-" + w1 +"\" y=\"-" + w1 + "\" width=\"" + w2 +"\" height=\"" + w2 + "\" />\n"
        ;
      } else if (xml.equals("tail")) {
        text = ""
        + "</g>\n"
        + "</svg>\n"
        ;
      }
      try {
        // mSVGWriter.print(text);
        System.err.println(text);
      } catch (Exception exc) {
        // log.error(exc.getMessage(), exc);
        System.err.println(exc.getMessage());
        exc.printStackTrace();
      } // try
    } // SVG output planned and not yet finished
  } // writeSVG
  
  /**
   * Main method, filters a file and dumps the prgress of the tilings' generation
   * @param args command line arguments: filename, or "-" or none for STDIN
   */
  public static void main(String[] args) {
    Tiler tiler = new Tiler();
    sDebug = 1;
    try {
      int iarg = 0;
      String fileName = "-"; // assume STDIN/STDOUT
      while (iarg < args.length) { // consume all arguments
        String opt        = args[iarg ++];
        if (false) {
        } else if (opt.equals("-d")     ) {
          sDebug          = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-f")     ) {
          tiler.processFile(args[iarg ++]);
        } else if (opt.equals("-i")     ) {
          tiler.mGalId    = args[iarg ++];
        } else if (opt.equals("-l")     ) {
          tiler.mMaxLevel = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-n")     ) {
          tiler.mNumTerms = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-circle")     ) {
          tiler.testCirclePositions();
        } else if (opt.equals("-svg")   ) {
          tiler.mSVG = true;
          fileName        = args[iarg ++];
          if (fileName.equals("-")) { // stdout
            tiler.mSVGWriter = new PrintWriter(Channels.newWriter(Channels.newChannel(System.out), tiler.sEncoding));
          } else { // not stdout
            WritableByteChannel channel = (new FileOutputStream (fileName, false)).getChannel();
            tiler.mSVGWriter = new PrintWriter(Channels.newWriter(channel, tiler.sEncoding));
          } // not stdout
          tiler.mSVGCount = tiler.mNumTerms;
          tiler.writeSVG("head");
        } else {
          System.err.println("??? invalid option: \"" + opt + "\"");
        }
      } // while args
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
    if (tiler.mSVG) {
      tiler.writeSVG("tail"); // also closes mSVGWriter
      tiler.mSVGWriter.close();
    }
  } // main

} // Tiler

