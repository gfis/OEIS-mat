/* Store vertices under positions
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-16, Georg Fischer: extracted from Tiling.java
 */
// package ;
// import Position;
// import Vertex;
import java.util.HashMap;
import java.util.Iterator;

/**
 * This class provides a store for mappings from an exact {@link Position} 
 * to a {@link Vertex}.t6-are-linearly-independent-ove
 * @author Georg Fischer
 */
public class PositionMap {
  public  final static String CVSID = "@(#) $Id: PositionMap.java $";
  
  /**
   * Maps exact {@link Position}s of vertices to the {@link Vertex} at that position
   */
  private HashMap<String, Vertex> mLocationHash;

  /** 
   * Empty Constructor.
   */
  public PositionMap() {
    mLocationHash = new HashMap<String, Vertex>(1024);
  } // Constructor()
  
  /**
   * Number of stored {@link Position}s
   * @return the size of the internal HashMap
   */
  public int size() {
    return mLocationHash.size();
  } // size

  /**
   * Stores a {@link Vertex} at some {@link Position}.
   */
  public void put(Vertex vertex) {
    mLocationHash.put(vertex.expos.toString(), vertex);
  } // put

  /**
   * Determines whether a {@link Vertex} exists at some {@link Position}.
   * @param expos the Position where a vertex is expected
   * @return the Vertex at expos, or null if the position is empty
   */
  public Vertex get(Position expos) {
    return mLocationHash.get(expos.toString());
  } // get

  /**
   * Returns a JSON representation of the tiling
   * @return JSON for {@link #mVertexTypes} and {@link #mVertices}
   */
  public String toJSON() {
    String sep = "  , ";
    String result  = "{ \"size\": " + mLocationHash.size() + ", \"mLocationHash\": \n";
    Iterator<String> piter = mLocationHash.keySet().iterator();
    while (piter.hasNext()) {
      String pos = piter.next();
      int ind = mLocationHash.get(pos).index;
      result += (ind == 0 ? "  [ " : sep) + "{ \"pos\": \"" + pos + ", index: " + ind + " }\n";
    } // while piter
    result += "  ]\n}\n";
    return result;
  } // toJSON

  /**
   * Main method - tests the unit circle Positions.
   * @param args command line arguments: -circle
   */
  public static void main(String[] args) {
    try {
      int iarg = 0;
      while (iarg < args.length) { // consume all arguments
        String opt        = args[iarg ++];
        if (false) {
        } else if (opt.equals("-circle")) {
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

} // class PositionMap
