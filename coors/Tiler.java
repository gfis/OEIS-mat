/* Generate tilings from Galebach's list
 * 2020-04-21, Georg Fischer
 */
import  java.io.BufferedReader;
import  java.io.FileInputStream;
import  java.io.InputStreamReader;
import  java.io.Serializable;
import  java.nio.channels.Channels;
import  java.nio.channels.ReadableByteChannel;
import  java.math.BigInteger;
import  java.util.ArrayList;
import  java.util.Arrays;
// import  org.apache.log4j.Logger;

/**
 * @author Georg Fischer
 */
public class Tiler {
  private static final long serialVersionUID = 3L;
  public final static String CVSID = "@(#) $Id: Tiler.java $";
  /** log4j logger (category) */
  // private Logger log;

  /** Debugging mode: 0=none, 1=some, 2=more */
  protected static int sDebug = 0;

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

  /** Offset1 of the sequences */
  private int mOffset;

  /** Join an array of integers 
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

  /** Class for an allowed vertex type.
   */ 
  protected  class VertexType { // numbered 1, 2, 3 ... ; 0 is not used
    String galId; // e.g. "Gal.2.1.1"
    int edgeNo; // number of edges
    int[] gones; // number of corners of the regular (3,4,6,8,12) polygones (shapes) which are 
        // arranged counter-clockwise around this vertex type.
        // First edge goes from (x,y)=(0,0) to (1,0); the shape is to the left of the edge
    int[] tars; // target vertex type indices (counter-clockwise if positive, clockwise if negative)
    int[] angles; // how many degrees must the target vertex type be rotated
    String sequence; // list of terms of the coordination sequence
    
    /** Empty constructor
     */
    VertexType() {
      galId    = "(reserved)";
      edgeNo   = 0;
      gones    = new int[0];
      tars     = new int[0];
      angles   = new int[0];
      sequence = "";
    } // Constructor()
    
    /** Constructor 
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
      gones  = new int[edgeNo];
      tars   = new int[edgeNo];
      angles = new int[edgeNo];
      String[] corners = parts[0].split("\\.");
      for (int iedge = 0; iedge < edgeNo; iedge ++) {
        try {
          gones [iedge] = 0;
          tars  [iedge] = parts[iedge + 1].charAt(0) - 'A' + 1;
          if (parts[iedge + 1].endsWith("'")) {
            tars[iedge]  = - tars[iedge];
            parts[iedge + 1] = parts[iedge+ 1].replaceAll("\\'","");
          }
          angles[iedge] = 0;
          gones [iedge] = Integer.parseInt(corners[iedge]);
          angles[iedge] = Integer.parseInt(parts[iedge + 1].substring(2));
        } catch (Exception exc) {
          System.err.println("descriptor \"" + descriptor + "\" bad");
        }
      } // for iedge
    } // Constructor(int)
    
    /** Returns a representation of the VertexType
     * @return JSON
     */
    public String toString() {
      pushIndent();
      String result =           "{ \"galId\":\t\""       + galId              + "\"\n"
                    + sIndent + ", \"gones\":\t"         + join(",", gones)   + "\n"
                    + sIndent + ", \"tars\":\t"          + join(",", tars)    + "\n"
                    + sIndent + ", \"angles\":\t"        + join(",", angles)  + "\n"
                    + sIndent + "}\n";
      popIndent();
      return result;
    } // toString
  } // VertexType
  
  /** Class for an allocated vertex.
   */ 
  protected class Vertex { // numbered 1, 2, 3 ... ; 0 is not used
    int typeIndex; // 1, 2, 3 ... (0 is reserved)
    int fixedEdges; // number of allocated neighbours = edges
    int[] shapeIndices; // list of indices in left shapes
    int[] succs; // list of indices in successor vertices
    int[] preds; // list of indices in predecessor vertices
    
    public Vertex() { // Constructor
      typeIndex    = 0;
      fixedEdges   = 0;
      shapeIndices = new int[0];
      succs        = new int[0];
      preds        = new int[0];
    } // Constructor()
    
    /** Returns a representation of the Vertex
     * @return JSON for edges
     */
    public String toString() {
      pushIndent();
      String result =           "{ \"index\":\t"         + typeIndex     + "\n"
                    + sIndent + ", \"fixedEdges\":\t"    + fixedEdges    + "\n"
                    + sIndent + ", \"shapeIndices\":\t"  + join(",", shapeIndices)  + "\n"
                    + sIndent + ", \"succs\":\t"         + join(",", succs       )  + "\n"
                    + sIndent + ", \"preds\":\t"         + join(",", preds       )  + "\n"
                    + sIndent + "}\n";
      popIndent();
      return result;
    } // toString
  } // Vertex
  
  /** Class for an allocated vertex.
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
    
    /** Constructor
     * @param nTypes number of VertexTypes
     */
    public Tiling(int nTypes) { // Constructor
      vertexTypes  = new VertexType[nTypes + 1]; // [0] is not used / reserved
      ffVertexType = 0;
      vertexTypes[ffVertexType ++] = new VertexType();
      vertices = new ArrayList<Vertex>(256);
      vertices.add(new Vertex()); // [0] is not used / reserved
      ffVertex = vertices.size();
    } // Constructor()

    /** Adds a new VertexType 
     * @param galId Galebach's id Gal.u.t.v
     * @param descriptor counter-clockwise list the polygones followed by the list of types and angles
     * @param sequence a list of initial terms of the coordination sequence
     */ 
    public void addVertexType(String galId, String descriptor, String sequence) {
      vertexTypes[ffVertexType ++] = new VertexType(galId, descriptor, sequence);
    } // addVertexType
    
    /** Returns a representation of the Tiling
     * @return JSON for types and vertices
     */
    public String toString() {
      pushIndent();
      String result  = sIndent + "  \"ffVertexType\":\t" + ffVertexType  + "\n"
                     + sIndent + ", \"vertexTypes\": [\n";
      try {
        String sep = "  , ";
        for (int ind = 0; ind < ffVertexType; ind ++) {
          result += sIndent + (ind > 0 ? sep : "    ") + vertexTypes[ind].toString();
        } // for types
        result += sIndent + "  ]\n";
        result += sIndent + ", \"ffVertex\":\t" + ffVertex + "\n"
               +  sIndent + ", \"vertices\": [\n";
        for (int ind = 0; ind < ffVertex; ind ++) {
          result += sIndent + (ind > 0 ? sep : "    ") + vertices.get(ind).toString();
        } // for vertices
        result += sIndent + "  ]\n";
      } catch(Exception exc) {
        // log.error(exc.getMessage(), exc);
        System.err.println("partial result: " + result);
        System.err.println(exc.getMessage());
        exc.printStackTrace();
      }
      popIndent();
      return result;
    } // toString
  } // Tiling

  /**
   * Initialize the tiling.
   * @param vtypeIndex index of the VertexType for the first vertex
   */
  private void initialize() {
  } // initialize


  /**
   * Empty constructor.
   */
  protected Tiler() {
    // log = Logger.getLogger(Tiler.class.getName());
  }

  /** 
   * Set the debugging level.
   * @param level code for the debugging level: 0 = none, 1 = some, 2 = more.
   */
  public void setDebug(int level) {
    sDebug = level;
  }
  
  /** Process one record from the file
   *  @param line record to be processed
   */
  private void processRecord(String line) {
    VertexType vtype = null;
    String[] fields = line.split("\\t");
    // for example: A265035 Gal.2.1.1   3.4.6.4; 4.6.12 12.6.4; A 180'; A 120'; B 90    1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
    int ifield = 1;
    String galId      = fields[ifield ++];
    String[] galIds   = galId.split("\\.");
    ifield ++; // skip standard notation
    String descriptor = fields[ifield ++];
    String sequence   = fields[ifield ++];
    try {
      if (false) {
      } else if (galIds[3].equals("1")) { // first of new tiling
        mTiling = new Tiling(Integer.parseInt(galIds[1]));
        mTiling.addVertexType(galId, descriptor, sequence);
      } else if (galIds[3].equals(galIds[1])) { // last of new tiling
        mTiling.addVertexType(galId, descriptor, sequence);
        System.out.println("{\n" + mTiling.toString() + "}\n");
        // compute the net
      } else {
        mTiling.addVertexType(galId, descriptor, sequence);
      }
    } catch(Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
  } // processRecord

  /** Filters a file and writes the modified output lines.
   *  @param fileName name of the input file, or "-" for STDIN
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

  /** Main method, filters a file and writes the copy to STDOUT.
   *  @param args command line arguments: filename, or "-" or none for STDIN
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
          } else if (opt.equals    ("-n")     ) {
          } else {
              System.err.println("??? invalid option: \"" + opt + "\"");
          }
      } // while args
      tiler.processFile(fileName);
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
  } // main

} // Tiler

