/* Generate tilings from Galebach's list
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
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
// import $(PACK).SVGFile;
// import $(PACK).TilingSequence;
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
    mGalId       = null;
    mASeqNo      = null; // not specified
    mMaxDistance = 16;
    mTiling      = null;
    mBaseEdge    = -1; // not specified
  } // TilingTest()

  /** Debugging mode: 0=none, 1=some, 2=more */
  protected static int sDebug;

  /** OEIS A-number of the coordination sequence */
  private String mASeqNo;

  /** Number of the edge of the Vertex with baseIndex which defines the base polygon */
  private int mBaseEdge;

  /** Encoding of the input file */
  private static final String sEncoding = "UTF-8";

  /** Brian Galebach's identification of a VertexType, of the form "Gal.u.t.v" */
  private String mGalId;

  /** Maximum distance from origin */
  private int mMaxDistance;

  /** Operation to be performed: "net", "bfile", "note" ... */
  private String mOperation;

  /** Current {@link TilingSequence} */
  private TilingSequence mTiling;

  /** Current {@link VertexTypeArray} */
  private VertexTypeArray mTypeNotas;

  private static final int MAX_ERROR = 2;

  /**
   * Computes the neighbourhood of the start {@link Vertex} up to some distance
   * @param baseIndex index of the initial {@link VertexType}
   */
  public void computeNet(final TilingSequence mTiling, final int baseIndex) {
    final VertexType baseType = mTiling.getVertexType(baseIndex);
    mASeqNo = baseType.aSeqNo;
    int errorCount = MAX_ERROR;
    LinkedList<Integer> queue = new LinkedList<Integer>();
    int maxBase = 0;
    maxBase = mTiling.setBaseIndex(baseIndex); // 1 base vertex, normal coordination sequence
    if (mBaseEdge >= 0) {
      maxBase = mTiling.setBaseEdge(baseIndex, mBaseEdge); // corners of a polygon are base, "loose" coordination sequence
    }
    final int[] terms = baseType.getSequence();
    final int termNo  = terms.length;
    if (mMaxDistance == -1) {
      mMaxDistance    = termNo - 1;
    }
    if (sDebug >= 3) {
      System.out.println("# compute neighbours of vertex type " + baseIndex + " up to distance " + mMaxDistance);
    }
    int distance = 0; // also index for terms
    for (int ifocus = 0; ifocus < mTiling.mVertexList.size(); ifocus ++) {
      queue.add(ifocus); // those which were stored by setBase(Index|Polygon)
    }
    int shellCount = queue.size();
    StringBuffer coordSeq = new StringBuffer(256);
    coordSeq.append(String.valueOf(shellCount));
    if (BFile.sEnabled) { // data line
      BFile.write(distance + " " + shellCount);
    }

    distance ++;
    while (distance <= mMaxDistance) {
      shellCount = 0;
      int levelPortion = queue.size();
      while (levelPortion > 0 && queue.size() > 0) { // queue not empty
        final int ifocus = queue.poll();
        if (sDebug >= 2) {
          System.out.println("# VertexList: " + mTiling.mVertexList.toJSON());
          System.out.println("# dequeue ifocus " + ifocus);
        }
        final Vertex focus = mTiling.mVertexList.get(ifocus);
        focus.distance = distance;
        for (int iedge = 0; iedge < focus.vtype.edgeNo; iedge ++) {
          if (focus.pxInds[iedge] < 0) { // proxy for this edge not yet determined
            final Vertex proxy = mTiling.attach(focus, iedge);
            if (SVGFile.sEnabled) {
              SVGFile.writeEdge(focus, proxy, iedge, distance, sDebug);
            }
            if (proxy.distance < 0) { // did not yet exist
              proxy.distance = distance;
              shellCount ++;
              queue.add(proxy.index);
              if (sDebug >= 2) {
                System.out.println("# enqueue iproxy " + proxy.index + ", attached to ifocus " + ifocus + " at edge " + iedge);
              }
            }
          } // proxy not yet determined
        } // for iedge
        levelPortion --;
      } // while portion not exhausted and queue not empty
      if (distance < terms.length && terms[distance] != shellCount && errorCount > 0) {
        System.out.println("# ** assertion 6: " + baseType.aSeqNo + " " + baseType.galId
            + ":\tdifference in terms[" + distance + "], expected " + terms[distance] + ", computed " + shellCount);
        errorCount --;
      }
      coordSeq.append(',');
      coordSeq.append(String.valueOf(shellCount));
      if (sDebug >= 2) {
        System.out.println("# distance " + distance + ": " + shellCount + " vertices added\n");
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
    if (sDebug >= 1) {
      System.out.println("# final net\n" + mTiling.toJSON());
    }
    if (true) { // this is always output
      System.out.println(baseType.aSeqNo + "\ttiler\t0\t" + mTiling.mTypeArray.get(baseIndex).galId
          + "\t" + coordSeq.toString());
    }
    if (errorCount == MAX_ERROR || mMaxDistance == termNo - 1) { // was -1
      System.err.println("# " + baseType.aSeqNo + " " + baseType.galId + ":\t"
          + String.valueOf(mMaxDistance + 1) + " terms verified");
    }
    if (SVGFile.sEnabled) {
      for (int ind = 0; ind < vlSize; ind ++) { // ignore reserved [0..1]
        Vertex focus = mTiling.mVertexList.get(ind);
        SVGFile.writeVertex(focus, maxBase, sDebug);
      } // for vertices
    } // SVG
    System.err.println("# " + mTiling.mVertexList.size() + " vertices generated");
  } // computeNet

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
    final String[] gutv        //         u    t    v
        = galId.split("\\.");  // "Gal", "2", "9", "1"; the trailing v runs from 1 to u, the t is the sequential number in u
    if (gutv[3].equals("1")) { // first of new tiling
      try {                                 //  0      1    2    3
        mTypeNotas = new VertexTypeArray(Integer.parseInt(gutv[1]));
      } catch(Exception exc) {
        System.err.println(exc.getMessage());
      }
    } // first
    mTypeNotas.decodeNotation(aSeqNo, galId, stdNotation, vertexId, taRotList, sequence); // increments mTAFree
    if (gutv[3].equals(gutv[1])) { // last of new tiling - save it, and perform some operation

      TilingSequence .sDebug = sDebug;
      Vertex         .sDebug = sDebug;
      VertexType     .sDebug = sDebug;
      VertexTypeArray.sDebug = sDebug;
      mTiling = new TilingSequence(0, mTypeNotas);
      if (sDebug >= 1) {
        System.out.println(mTiling.toJSON());
      }
      // compute the nets
      for (int baseIndex = 0; baseIndex < mTypeNotas.size(); baseIndex ++) {
        if (mGalId == null || mTiling.getVertexType(baseIndex).galId.equals(mGalId)) {
          // either all in the input file, or only the specified mGalId
          final VertexType baseType = mTiling.getVertexType(baseIndex);
          mASeqNo = baseType.aSeqNo;
          if (false) { // switch for different operations
          //--------
          } else if (mOperation.startsWith("bfile")) {
            BFile.open(mASeqNo);
            for (int index = 0; index < mMaxDistance; index ++) {
              BFile.write(index + " " + mTiling.next());
            } // for index
            BFile.close();
          //--------
          } else if (mOperation.equals    ("fini")) {
            // ignore
          //--------
          } else if (mOperation.startsWith("net"  )) {
            if (SVGFile.sEnabled) {
              SVGFile.open(mMaxDistance, mGalId);
            }
            computeNet(mTiling, baseIndex);
            if (SVGFile.sEnabled) {
              SVGFile.close();
            }
          //--------
          } else if (mOperation.startsWith("notae")) {
            System.out.print(mTiling.mTypeArray.toString());
            mOperation = "fini"; // only once
          //--------
          } else {
            System.err.println("# TilingTest: invalid operation \"" + mOperation + "\"");
          } // switch for operations
        }
      } // for itype

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
   * Main method, filters a file, selects a {@link VertexTypeArray] for a tiling,
   * dumps the progress of the tilings' generation and
   * possibly writes an SVG drawing file.
   * @param args command line arguments
   */
  public static void main(String[] args) {
    final long startTime    = System.currentTimeMillis();
    final TilingTest tester = new TilingTest();
    final BFile bFile       = new BFile();
    final SVGFile svgFile   = new SVGFile();
    tester.mOperation = "net"; // default
    sDebug = 0;
    try {
      int iarg = 0;
      String fileName = "-"; // assume STDIN/STDOUT
      while (iarg < args.length) { // consume all arguments
        String opt             = args[iarg ++];
        if (false) {
        } else if (opt.equals    ("-a")     ) {
          tester.mASeqNo       = args[iarg ++];
        } else if (opt.startsWith("-back")  ) {
          TilingSequence.sBackLink = true;
        } else if (opt.startsWith("-bf") ) {
          BFile.sEnabled       = true;
          BFile.setPrefix(       args[iarg ++]);
          tester.mOperation    = "bfile";
        } else if (opt.equals    ("-dist")  ) {
          tester.mMaxDistance  = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-d")     ) {
          sDebug               = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals    ("-f")     ) {
          fileName             = args[iarg ++];
        } else if (opt.equals    ("-id")    ) {
          tester.mGalId        = args[iarg ++];
        } else if (opt.equals    ("-n")     ) {
          String dummy         = args[iarg ++]; // ignore
        } else if (opt.startsWith("-n")     ) { // net, nota, note, notae
          tester.mOperation    = opt.substring(1);
        } else if (opt.equals    ("-poly")  ) {
          tester.mBaseEdge     = Integer.parseInt(args[iarg ++]);
          tester.mBaseEdge --; // external edge numbers start at 1, internal at 0
        } else if (opt.equals    ("-svg")   ) {
          SVGFile.sEnabled     = true;
          SVGFile.sFileName    = args[iarg ++];
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
