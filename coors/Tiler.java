/* Generate tilings from Galebach's list
 * 2020-04-21, Georg Fischer
 */
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
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
    mOffset = 0;
    sDebug = 1;
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

  /** Current tiling */
  private Tiling mTiling;

  /** number of terms to be generated */
  private int mNumTerms;

  /** Maximum nesting level  */
  private int mMaxLevel;

  /** Offset1 of the sequences */
  private int mOffset;

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
    public Position moveDegrees(int angle) {
      return this.add(circlePos[Math.round(angle / 15) % 24]);
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

  /** 
   * Class for an allowed vertex type.
   */
  protected  class VertexType { // numbered 1, 2, 3 ... ; 0 is not used
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
     * @param descriptor counter-clockwise list the polygones followed by the list of types and angles
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
    int[] shapeIndices; // list of indices in left shapes
    int[] succs; // list of indices in successor vertices
    int[] preds; // list of indices in predecessor vertices

    /**
     * Empty constructor, only a placeholder in order to avoid vertex index 0
     */
    public Vertex() {
      this(0);
    /*
      typeIndex    = 0; // reserved
      angle        = 0;
      expos        = new Position();
      fixedEdges   = 0;
      int edgeNo   = 0;
      shapeIndices = new int[edgeNo];
      succs        = new int[edgeNo];
      preds        = new int[edgeNo];
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
      typeIndex    = itype; // may be negative
      itype        = Math.abs(itype); // now positive
      angle        = 0;
      expos        = new Position();
      int edgeNo   = itype == 0 ? 0 : mTiling.vertexTypes[itype].edgeNo;
      shapeIndices = new int[edgeNo];
      succs        = new int[edgeNo];
      preds        = new int[edgeNo];
      Arrays.fill(shapeIndices, 0);
      Arrays.fill(succs       , 0);
      Arrays.fill(preds       , 0);
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
          + ", \"preds\": "  + join(",", preds       )
          + ", \"shapes\": " + join(",", shapeIndices)
          + ", \"x\": "      + expos.getX()
          + ", \"y\": "      + expos.getY()
          + " }\n";
      popIndent();
      return result;
    } // toString
        
  } // class Vertex

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
          result += sIndent + (ind == 0 ? "  [ " : sep) + vertices.get(ind).toString();
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
     * @return index of successor vertex 
     */
    public int attach(int ifocus, int iedge) {
      int isucc = 0; // future result
      Vertex focus = vertices.get(ifocus);
      VertexType fotype = focus.getType();
      if (focus.succs[iedge] == 0) {
        Vertex succ = new Vertex(fotype.tars[iedge]);
        isucc = ffVertex;
        vertices.add(succ);
        ffVertex ++;
        focus.succs[iedge] = isucc;
        succ.angle = fotype.angles[iedge];
        // succ.preds[
        focus.fixedEdges ++;
      } else { 
      	isucc = focus.succs[iedge];// already linked 
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
        System.out.println("/* compute neighbours of vertex type " + istart + " up to distance " + mNumTerms + "*/");
      }
      queue.add(addVertex(istart));
      int nestLevel = 1; 
      while (nestLevel <= mMaxLevel) {
      	int levelPortion = queue.size();
        if (sDebug >= 1) {
          System.out.println("/* level " + nestLevel + ": process " + levelPortion + " vertices */");
        }
        while (levelPortion > 0 && queue.size() > 0) { // queue not empty
          int ifocus = queue.poll();
          levelPortion --;
          Vertex focus = vertices.get(ifocus);
          VertexType fotype = focus.getType();
          for (int iedge = 0; iedge < fotype.edgeNo; iedge ++) {
            int isucc = attach(ifocus, iedge);
            queue.add(isucc);
          } // for iedge
        } // while queue not empty
        nestLevel ++;
      } // while nestLevel
      System.out.println("/* final net */\n" + toString());
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
          mTiling.computeNet(itype);
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
   * Filters a file and writes the modified output lines.
   * @param fileName name of the input file, or "-" for STDIN
   */
  private void processFile(String fileName) {
    BufferedReader lineReader; // Reader for the input file
    String srcEncoding = "UTF-8"; // Encoding of the input file
    String line = null; // current line from text file
    try {
      if (fileName == null || fileName.length() <= 0 || fileName.equals("-")) {
        lineReader = new BufferedReader(new InputStreamReader(System.in, srcEncoding));
      } else {
        ReadableByteChannel lineChannel = (new FileInputStream(fileName)).getChannel();
        lineReader = new BufferedReader(Channels.newReader(lineChannel , srcEncoding));
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

  /** 
   * Main method, filters a file and dumps the prgress of the tilings' generation
   * @param args command line arguments: filename, or "-" or none for STDIN
   */
  public static void main(String[] args) {
    Tiler tiler = new Tiler();
    try {
      int iarg = 0;
      String fileName = "-"; // assume STDIN
      while (iarg < args.length) { // consume all arguments
        String opt = args[iarg ++];
        if (false) {
        } else if (opt.equals    ("-d")     ) {
          sDebug = 1;
          sDebug = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-f")     ) {
          fileName = args[iarg ++];
          tiler.processFile(fileName);
        } else if (opt.equals    ("-m")     ) {
          tiler.mMaxLevel = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-n")     ) {
          tiler.mNumTerms = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-pos")     ) {
          for (int ipos = 0; ipos < tiler.circlePos.length + 1; ipos ++) {
            String pos = tiler.circlePos[0].moveDegrees(ipos * 15).toString();
            System.out.println(String.format("[%2d], %3d = %s", ipos, ipos * 15, pos));
          } // for ipos
          for (int ipos = 0; ipos < tiler.circlePos.length; ipos += 4) {
            int ipos8 = (ipos + 8) % 24;
            Position hexPos = tiler.circlePos[ipos].add(tiler.circlePos[ipos8]);
            System.out.println(String.format("[%2d] + [%2d] = %8s,%8s"
                , ipos, ipos8, hexPos.getX(), hexPos.getY()));
          } // for ipos
        } else {
            System.err.println("??? invalid option: \"" + opt + "\"");
        }
      } // while args
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
  } // main

} // Tiler

