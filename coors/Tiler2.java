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
// package ;
// import BFile;
// import Position;
// import SVGFile;
// import Tiling;
// import Vertex;
// import VertexType;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
// import  org.apache.log4j.Logger;

/**
 * Class for the generation of tilings and their coordinations sequences.
 * @author Georg Fischer
 */
public class Tiler2 implements Serializable {
  private static final long serialVersionUID = 3L;
  public final static String CVSID = "@(#) $Id: Tiler2.java $";
  /** log4j logger (category) */
  // private Logger log;
 
  /**
   * Empty constructor.
   */
  protected Tiler2() {
    // log = Logger.getLogger(Tiler2.class.getName());
    BFile.setPrefix("./");
    mGalId       = null;
    mASeqNo      = null; // not specified
    mMaxDistance = 16;
    mTiling      = null;
  } // Tiler2()

  /** Debugging mode: 0=none, 1=some, 2=more */
  protected static int sDebug;

  /** OEIS A-number of the coordination sequence */
  private String mASeqNo;

  /** Brian Galebach's identification of a VertexType, of the form "Gal.u.t.v" */
  private String mGalId;

  /** Maximum distance from origin */
  private int mMaxDistance;

  /** Encoding of the input file */
  private static final String sEncoding = "UTF-8";
  
  /** Current tiling */
  private Tiling mTiling;

  /**
   * Process one record from the file
   * @param line record to be processed
   */
  private void processRecord(String line) {
    // e.g. line = A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4; A 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
    String[] fields   = line.split("\\t");
    int ifield = 0;
    String aSeqNo     = fields[ifield ++];
    String galId      = fields[ifield ++];
    ifield ++; // skip standard notation
    String vertexId   = fields[ifield ++];
    String taRotList  = fields[ifield ++];
    String sequence   = fields[ifield ++];
    try {                                 //  0      1    2    3
      String[] gutv = galId.split("\\."); // "Gal", "2", "9", "1"
      if (gutv[3].equals("1")) { // first of new tiling
        mTiling = new Tiling(Integer.parseInt(gutv[1]), mMaxDistance, mASeqNo);
      }
      mTiling.mTypeArray.setAngleNotation(aSeqNo, galId, vertexId, taRotList, sequence); // increments mTAFree
      if (gutv[3].equals(gutv[1])) { // last of new tiling
        if (sDebug >= 1) {
          System.out.println(mTiling.toJSON());
        }
        mTiling.mTypeArray.complete();

        // compute the nets
        int netCount = 0;
        for (int ind = 0; ind < mTiling.mTypeArray.size(); ind ++) {
          if (mGalId == null || mTiling.getVertexType(ind).galId.equals(mGalId)) { 
            // either all in the input file, or only the specified mGalId
            if (SVGFile.sEnabled) {
              SVGFile.open(mMaxDistance, mGalId);
            }
            mTiling.computeNet(ind);
            netCount ++;
            if (SVGFile.sEnabled) {
              SVGFile.close(); 
            }
          }
        } // for itype
        if (netCount == 0) {
          System.err.println("# assertion 9: no net computed");
        }
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
   * Main method, filters a file, selects a VertexType group for a tiling,
   * dumps the progress of the tilings' generation and
   * possibly writes an SVG drawing file.
   * @param args command line arguments
   */
  public static void main(String[] args) {
    long startTime  = System.currentTimeMillis();
    Tiler2 tiler    = new Tiler2();
    BFile bFile     = new BFile();
    SVGFile svgFile = new SVGFile();
    sDebug = 0;
    try {
      int iarg = 0;
      String fileName = "-"; // assume STDIN/STDOUT
      while (iarg < args.length) { // consume all arguments
        String opt            = args[iarg ++];
        if (false) {
        } else if (opt.equals("-a")     ) {
          tiler.mASeqNo       = args[iarg ++];
        } else if (opt.equals("-bfile") ) {
          BFile.sEnabled      = true;
          BFile.setPrefix(      args[iarg ++]);
        } else if (opt.equals("-dist")  ) {
          tiler.mMaxDistance = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-d")     ) {
          sDebug             = Integer.parseInt(args[iarg ++]);
        } else if (opt.equals("-f")     ) {
          fileName           = args[iarg ++];
        } else if (opt.equals("-id")    ) {
          tiler.mGalId       = args[iarg ++];
        } else if (opt.equals("-n")     ) {
          String dummy       = args[iarg ++]; // ignore
        } else if (opt.equals("-svg")   ) {
          SVGFile.sEnabled   = true;
          SVGFile.sFileName  = args[iarg ++];
        } else {
          System.err.println("??? invalid option: \"" + opt + "\"");
        }
      } // while args
      Tiling    .sDebug = sDebug;
      Vertex    .sDebug = sDebug;
      VertexType.sDebug = sDebug;
      tiler.processFile(fileName);
    } catch (Exception exc) {
      // log.error(exc.getMessage(), exc);
      System.err.println(exc.getMessage());
      exc.printStackTrace();
    }
    System.err.println("# elapsed: " + String.valueOf(System.currentTimeMillis() - startTime) + " ms");
  } // main

} // Tiler2

