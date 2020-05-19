/* Store for vertices
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-16, Georg Fischer: extracted from Tiling.java
 */
// package ;
// import Vertex;
import java.util.ArrayList;

/**
 * This class provides an expandable array which allows 
 * access to all {@link Vertex}es by their index.
 * @author Georg Fischer
 */
public class VertexList {
  public final static String CVSID = "@(#) $Id: VertexList.java $";
  
  /** Allocated vertices */
  private ArrayList<Vertex> mVertices; // [0] is reserved

  /** 
   * Empty Constructor.
   */
  public VertexList() {
    mVertices = new ArrayList<Vertex>(1024);
  } // Constructor()
  
  /**
   * Number of stored {@link Vertex}es
   * @return the size of the internal ArrayList
   */
  public int size() {
    return mVertices.size();
  } // size

  /**
   * Stores a {@link Vertex} at the next free element.
   */
  public void put(Vertex vertex) {
    mVertices.add(vertex);
  } // put
 
  /**
   * Gets a {@link Vertex} specified by its index.
   * @param index sequential number (0 is reserved)
   * @return the Vertex with that index
   */
  public Vertex get(int index) {
    return mVertices.get(index);
  } // get

  /**
   * Returns a JSON representation of <em>this</em> VertexList
   * @return JSON for all vertices in linear order
   */
  public String toJSON() {
    final int ffVertices = mVertices.size();
    String result  = "{ \"size\": " + ffVertices + "\n" +  ", \"mVertices\":\n";
    for (int ind = 0; ind < ffVertices; ind ++) {
      result += (ind == 0 ? "  [ " : "  , ") + mVertices.get(ind).toJSON();
    } // for vertices
    result += "  ]\n}\n";
    return result;
  } // toJSON

} // class VertexList
