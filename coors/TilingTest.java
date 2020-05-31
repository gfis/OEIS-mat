/* Generate tilings from Galebach's list https://oeis.org/A250120/a250120.html
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-29: -mode, drawNet
 * 2020-05-15: splitted in different classes
 * 2020-05-14: new colors
 * 2020-05-12: mHashPosition only, comparing Position.toString()
 * 2020-05-08: -a aseqno
 * 2020-04-30: cleaned
 * 2020-04-29: 4th version, flipped straight from backwards
 * 2020-04-21, Georg Fischer
 */
// package $(PACK);
// import $(PACK).BFile;
// import $(PACK).EdgeList;
// import $(PACK).SVGFile;
// import $(PACK).TilingSequence;
// import $(PACK).VertexList;
// import $(PACK).VertexType;
// import $(PACK).VertexTypeArray;
// import $(PACK).Z;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.util.LinkedList;
// import  org.apache.log4j.Logger;

/**
 * Class for the generation of tilings and their coordinations sequences.
 * @author Georg Fischer
 */
public class TilingTest implements Serializable {
  private static final long serialVersionUID = 3L;
  public final static String CVSID = "@(#) $Id: TilingTest.java $";
  /** log4j logger (category) */
  // private Logger log;

  /**
   * Empty constructor.
   */
  protected TilingTest() {
    // log = Logger.getLogger(TilingTest.class.getName());
    BFile.setPrefix("./");
    mOperation   = "net";
    mGalId       = null;
    mSeqNo       = 900000; // start of preliminary A-numbers
    mMaxDistance = 16;
    mTiling      = null;
    mBaseEdge    = -1; // not specified
    mMode        =  0; // baseIndex
  } // TilingTest()

  /** Debugging mode: 0=none, 1=some, 2=more */
  protected static int sDebug;

  /** preliminary OEIS A-number */
  private int mSeqNo;

  /** Number of the edge of the Vertex with baseIndex which defines the base polygon */
  private int mBaseEdge;

  /** Number of vertices defined as the base set */
  private int mMaxBase;

  /** Encoding of the input file */
  private static final String sEncoding = "UTF-8";

  /** Brian Galebach's identification of a VertexType, of the form "Gal.u.t.v" */
  private String mGalId;

  /** Maximum distance from origin */
  private int mMaxDistance;

  /** 
   * Defines the set of vertices for the initial shell:
   * <ul>
   * <li>0 = one base vertex</li>
   * <li>1 = polygon defined by the base vertex and the edge - the polygon is to the right</li>
   * <li>2 = all polygons around the base vertex</li>
   * <li>3 = the base vertex and the proxy at the end of the edge</li>
   * <li>4 = all pairs base vertex, proxy</li>
   * </ul>
   */
  private int mMode;

  /** Operation to be performed: "net", "bfile", "note" ... */
  private String mOperation;

  /** Current {@link TilingSequence} */
  private TilingSequence mTiling;

  /** Current {@link VertexTypeArray} */
  private VertexTypeArray mTypeNotas;

  private static final int MAX_ERROR = 2;

  /**
   * Computes the neighbourhood of the start {@link Vertex} up to some distance
   * @param mTiling data structures for the tiling to be computed
   * @param baseIndex index of the initial {@link VertexType}
   */
  public void computeNet(final TilingSequence mTiling, final int baseIndex) {
    final VertexType baseType = mTiling.getVertexType(baseIndex);
    int errorCount = MAX_ERROR;
    mMaxBase = mTiling.defineBaseSet(mMode, baseIndex, mBaseEdge);
    final int[] terms = baseType.getSequence();
    final int termNo  = terms.length;
    if (mMaxDistance == -1) {
      mMaxDistance    = termNo - 1;
    }
    int shellCount = mMaxBase;
    StringBuffer termList = new StringBuffer(256);
    termList.append(String.valueOf(shellCount));
    int distance = 0;
    while (distance <= mMaxDistance) {
      shellCount = mTiling.next().intValue();
      termList.append(',');
      termList.append(String.valueOf(shellCount));
      if (distance < terms.length && terms[distance] != shellCount && errorCount > 0) {
        System.out.println("# ** assertion 6: " + baseType.aSeqNo + " " + baseType.galId
            + ":\tdifference in terms[" + distance + "], expected " + terms[distance] + ", computed " + shellCount);
        errorCount --;
      }
      distance ++;
    } // while distance

    final int vlSize = mTiling.mVertexList.size();
    if (mTiling.mPosMap.size() != vlSize) {
      if (sDebug >= 0) {
        System.err.println("# ** assertion 3 in tiling.toString: " + mTiling.mPosMap.size()
            + " different positions, but " + vlSize + " vertices\n");
      }
    }
    if (errorCount == MAX_ERROR || mMaxDistance == termNo - 1) { // was -1
      System.err.println("# " + baseType.aSeqNo + " " + baseType.galId + ":\t"
          + String.valueOf(mMaxDistance + 1) + " terms verified");
    }
    
    System.out.println(baseType.aSeqNo + "\ttiltes\t0\t" + baseType.galId
          + "\t" + baseType.vertexId + "\t" + termList.toString());
    System.err.println("# " + mTiling.mVertexList.size() + " vertices generated");
  } // computeNet

  /**
   * Expands and prints the sequence(s) for <em>this</em> tiling.
   * @param mode defines the set of vertices for the initial shell:
   * <ul>
   * <li>0 = one base vertex</li>
   * <li>1 = polygon defined by the base vertex and the edge - the polygon is to the right</li>
   * <li>2 = all polygons around the base vertex</li>
   * <li>3 = the base vertex and the proxy at the end of the edge</li>
   * <li>4 = all pairs base vertex, proxy</li>
   * </ul>
   */
  public void drawNet(final int mode) {
    final int elSize = mTiling.mEdgeList.size();
    SVGFile.open(mMaxDistance, mGalId);
    for (int ind = 0; ind < elSize; ind ++) { // draw all edges
      Edge edge = mTiling.mEdgeList.get(ind);
      Vertex focus = mTiling.mVertexList.get(edge.ifocus);
      Vertex proxy = mTiling.mVertexList.get(edge.iproxy);
      SVGFile.writeEdge(focus, proxy, edge.iedge, edge.distance, sDebug);
    } // for edges
    
    final int vlSize = mTiling.mVertexList.size();
    for (int ind = 0; ind < vlSize; ind ++) { // draw all vertices
      Vertex focus = mTiling.mVertexList.get(ind);
      SVGFile.writeVertex(focus, mMaxBase, sDebug);
    } // for vertices
    SVGFile.close();
  } // drawNet
  
  /**
   * Process one record from the file
   * @param line record to be processed
   */
  private void processRecord(final String line) {
    // e.g. line = A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4; A 180'; A 120'; B 90 tab 1,3,6,9,11, ...
    final String[] fields    = line.split("\\t");
    int ifield = 0;
    final String aSeqNo      = fields[ifield ++];
    final String galId       = fields[ifield ++];
    final String stdNotation = fields[ifield ++];
    final String vertexId    = fields[ifield ++];
    final String taRotList   = fields[ifield ++];
    final String sequence    = fields[ifield ++];
    int tilingNo = 0;
    try {
      tilingNo = Integer.parseInt(fields[ifield ++]);
    } catch (Exception exc) { // ignore
    }
    final String[] gutv        //         u    t    v
        = galId.split("\\.");  // "Gal", "2", "9", "1"; the trailing v runs from 1 to u, the t is the sequential number in u
    if (gutv[3].equals("1")) { // first of new tiling
      try {                                 //  0      1    2    3
        mTypeNotas = new VertexTypeArray(Integer.parseInt(gutv[1]));
      } catch(Exception exc) {
        System.err.println(exc.getMessage());
      }
    } // first
    mTypeNotas.decodeNotation(aSeqNo, galId, stdNotation, vertexId, taRotList, sequence, tilingNo); // increments mTAFree
    if (gutv[3].equals(gutv[1])) { // last of new tiling - save it, and perform some operation

      TilingSequence .sDebug = sDebug;
      mTiling = new TilingSequence(mMode == 0 ? 0 : 1, mTypeNotas);
      if (SVGFile.sEnabled) {
        mTiling.mStoreEdges = true;
      }
      // compute the net(s)
      int baseIndex = 0; 
      while (baseIndex < mTypeNotas.size()) {
        if (mGalId == null || mTiling.getVertexType(baseIndex).galId.equals(mGalId)) {
          // either all in the input file, or only the specified mGalId
          final VertexType baseType = mTiling.getVertexType(baseIndex);
          if (false) { // switch for different operations
          //--------
          } else if (mOperation.startsWith("bfile")) {
            mMaxBase = mTiling.defineBaseSet(mMode, baseIndex, mBaseEdge); 
            BFile.open(baseType.aSeqNo);
            for (int index = 0; index < mMaxDistance; index ++) {
              BFile.write(index + " " + mTiling.next());
            } // for index
            BFile.close();
          //--------
          } else if (mOperation.startsWith("net"  )) {
            computeNet(mTiling, baseIndex);
            if (SVGFile.sEnabled) {
              drawNet(mMode);
            }
          //--------
          } else if (mOperation.startsWith("notae")) {
            System.out.print(mTiling.mTypeArray.toString());
            baseIndex = mTypeNotas.size(); // break while loop
          //--------
          } else if (mOperation.startsWith("seq")) {
            mTiling.printSequences(mMode, mTiling.getVertexType(baseIndex).galId, baseIndex, mBaseEdge, mMaxDistance);
          //--------
          } else {
            System.err.println("# TilingTest: invalid operation \"" + mOperation + "\"");
          } // switch for operations
        }
        baseIndex ++;
      } // while baseIndex
      if (sDebug >= 1) {
        System.out.println("final net:\n" + mTiling.toJSON());
      }
    } // last of new tiling - operation performed
  } // processRecord

  /**
   * Reads a file and processes all input lines.
   * @param fileName name of the input file, or "-" for STDIN
   */
  private void processFile(final String fileName) {
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
        if (! line.matches("\\s*(\\#.*)?")) { // is not a comment and not empty
          if (sDebug >= 2) {
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
   * Main method, filters a file, selects a {@link VertexTypeArray} for a tiling,
   * dumps the progress of the tilings' generation and
   * possibly writes an SVG drawing file.
   * @param args command line arguments
   */
  public static void main(String[] args) {
    final long startTime    = System.currentTimeMillis();
    final TilingTest tester = new TilingTest();
    tester.mMode = 0; 
    sDebug = 0;
    try {
      int iarg = 0;
      String fileName = "-"; // assume STDIN/STDOUT
      while (iarg < args.length) { // consume all arguments
        String opt             = args[iarg ++];
        if (false) {
        } else if (opt.startsWith("-back")  ) {
          TilingSequence.sBackLink = true;
        } else if (opt.startsWith("-bf")    ) {
          BFile.setPrefix(       args[iarg ++]);
          BFile.sEnabled       = true;
          tester.mOperation    = "bfile";
        } else if (opt.equals    ("-dist")  ) {
          tester.mMaxDistance  = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-d")     ) {
          sDebug               = Integer.parseInt(args[iarg ++]);
        } else if (opt.startsWith("-edge")  ) {
          tester.mBaseEdge     = Integer.parseInt(args[iarg ++]) - 1; // internal edge numbers start at 0
        } else if (opt.equals    ("-f")     ) {
          fileName             = args[iarg ++];
        } else if (opt.equals    ("-id")    ) {
          tester.mGalId        = args[iarg ++];
        } else if (opt.startsWith("-mode")  ) {
          tester.mMode         = Integer.parseInt(args[iarg ++]);
        } else if (opt.startsWith("-n")     ) { // net, nota, note, notae
          tester.mOperation    = opt.substring(1);
        } else if (opt.equals    ("-svg")   ) {
          SVGFile.sEnabled     = true;
          SVGFile.sFileName    = args[iarg ++];
        } else if (opt.startsWith("-seq")   ) { 
          tester.mOperation    = opt.substring(1);
        } else {
          System.err.println("# ??? TilingTest, invalid option: \"" + opt + "\"");
        }
      } // while args
      tester.processFile(fileName);
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
    System.out.println("# elapsed: " + String.valueOf(System.currentTimeMillis() - startTime) + " ms");
  } // main

} // TilingTest
