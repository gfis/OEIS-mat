/* Node in a tiling 
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
 * 2020-05-15, Georg Fischer: extracted from Tiler.java
 */
// package org.teherba.ramath.tiling
// import Position;
// import SVGFile;
// import VertexType;
import java.io.Serializable;
import java.util.Arrays;

/**
 * This class represents a vertex in a tiling. 
 * A vertex is a node where 3 to 6 (for uniform tilings) edges meet.
 * @author Georg Fischer
 */
public class Vertex implements Serializable {
  public final static String CVSID = "@(#) $Id: Vertex.java $";

  /** Debugging mode: 0=none, 1=some, 2=more */
  public static int sDebug;
  
  int index; // in mVertices
  VertexType vtype; // general properties for the vertex
  int iType; // index of vtype; 0, 1 are reserved; iType is even for clockwise, odd for counter-clockwise variant
  int flip;  // 0 for clockwise, 1 for counter-clockwise orientation
  int distance; // length of shortest path to origin, for coloring
  int rotate; // the vertex type was rotated clockwise by so many degrees
  Position expos; // exact Position of the Vertex
  int fixedEdges; // number of allocated neighbours = edges
  Vertex[] proxies; // array of neighbouring vertices at the end of the edges
  int[] succs; // array of indices of proxies
/*
  int[] shapes; // list of indices in left shapes
  int[] preds; // list of indices in predecessor vertices
*/
  int bedge; // temporary edge pointing backwards to the last focus of this successor

  /**
   * Empty constructor, not used
   */
  public Vertex() {
    iType = 0;
  } // Vertex()

  /**
   * Constructor with a {@link VertexType}.
   * @param vtype type of vertex with general properties,
   * is even for clockwise, odd for clockwise orientation
   */
  public Vertex(VertexType vtype) {
    this.vtype = vtype;
    iType      = vtype.index;
    flip       = iType & 1; // lowest bit
    distance   = 0;
    rotate     = 0;
    expos      = new Position();
    int edgeNo = iType == 0 ? 0 : getType().edgeNo;
    proxies    = new Vertex[edgeNo];
    succs      = new int[edgeNo];
    Arrays.fill(succs , 0);
  /*
    shapes     = new int[edgeNo];
    preds      = new int[edgeNo];
    Arrays.fill(shapes, 0);
    Arrays.fill(preds , 0);
  */
   } // Vertex(VertexType)

  /**
   * Gets the type of <em>this</em> Vertex
   * @return a {@link VertexType}
   */
  public VertexType getType() {
    return vtype;
  } // getType

  /**
   * Gets the some VertexType
   * @return a {@link VertexType}
   */
  public VertexType getType(int index) {
    return Tiling.mVertexTypes[index];
  } // getType

  /**
   * Gets the name (via the {@link #VertexType}) of <em>this</em> Vertex
   * @return uppercase letter (for non-flipped) or lowercase letter (for flipped)
   */
  public String getName() {
    return flip == 0 
        ? getType().name
        : getType().name.toLowerCase();
  } // getName

  /**
   * Returns a JSON representation of the Vertex
   * @return JSON for all properties
   */
  public String toJSON() {
    Tiling.pushIndent();
    String result
        = "{ \"i\": "        + String.format("%4d", index)
        + ", \"type\": "     + String.format("%2d", iType)
      //  + ", \"name\": "     + String.format("%2d", getName()
        + ", \"rot\": "      + String.format("%3d", rotate)
        + ", \"fix\": "      + fixedEdges
        + ", \"succs\": \""  + Tiling.join(",", succs ) + "\""
      //  + ", \"preds\": \""  + Tiling.join(",", preds ) + "\""
      //  + ", \"shapes\": \"" + Tiling.join(",", shapes) + "\""
        + ", \"pos\": \""    + expos.toString()  + "\""
        + ", \"dist\": \""   + distance + "\""
        + " }\n";
    Tiling.popIndent();
    return result;
  } // Vertex.toJSON

  /**
   * Returns a representation of the Vertex
   * @return JSON for edges
   */
  public String toString() {
    return index + getName() + " @" + rotate + expos + "->" + Tiling.join(",", succs).replaceAll("[\\[\\]]", "");
  } // Vertex.toString

 /**
   * Normalizes an angle
   * @param angle in degrees, maybe negative or >= 360
   * @return non-negative degrees mod 360
   */
  private static int normAngle(int angle) {
    while (angle < 0) {
      angle += 360;
    }
    return angle % 360;
  } // normAngle

  /**
   * Gets the absolute angle where an edge of <em>this</em> {@link #Vertex}
   * (which is already rotated) is pointing to.
   * This is the only place where the orientation of the Vertex is relevant.
   * The orientation is implemented by a proper access to <em>sweeps</em>.
   * This method corresponds with {@link #getEdge}.
   * @param iedge number of the edge
   * @return degrees [0..360) where the edge points to,
   * relative to a right horizontal edge from (x,y)=(0,0) to (x,y)=(0,1),
   * turning clockwise := positive (downwards, because of SVG's y axis)
   */
  public int getAngle(int iedge) {
    VertexType vtype = getType();
    int siType  = vtype.tipes[
        vtype.isFlipped() ? vtype.normEdge(- iedge) : vtype.normEdge(+ iedge)
        ];
    if (vtype.isFlipped()) {
      siType ^= 1;
    }
    VertexType suType = getType(siType);
    int sum       = rotate;
    int swFlipped = - vtype.sweeps[vtype.normEdge(- iedge)];
    int swNormal  =   vtype.sweeps[vtype.normEdge(+ iedge)];
    boolean foFlip =  vtype.isFlipped();
    boolean suFlip = suType.isFlipped();
    if (foFlip) {
      if (suFlip) {
        sum += - vtype.sweeps[vtype.normEdge(- iedge)];
      } else {
        sum += - vtype.sweeps[vtype.normEdge(- iedge)];
      }
    } else {
      if (suFlip) {
        sum += + vtype.sweeps[vtype.normEdge(+ iedge)];
      } else {
        sum += + vtype.sweeps[vtype.normEdge(+ iedge)];
      }
    }
    sum = normAngle(sum);
    if (sDebug >= 2) {
        System.out.println("#         getAngle(iedge " + iedge + ")." + index + getName() + "@" + rotate + expos
            + ", suType " + suType.toString()
            + " -> swNormal " + normAngle(swNormal) + ", swFlipped " + normAngle(swFlipped)
            + ", focus.flipped " + vtype.isFlipped() + ", succ.flipped " + suType.isFlipped()
            + ", sum " + sum);
    }
    return sum;
  } // getAngle

  /**
   * Gets the matching edge of <em>this</em> {@link Vertex} (which is already rotated)
   * for a given absolute angle, or -1 if no such edge was found
   * This method corresponds with {@link #getAngle}.
   * @param angle degrees 0..360 where the edge points to,
   * already inverted,
   * counted from (x,y)=(0,0) to (x,y)=(0,1), clockwise
   * @return iedge=0..edgeNo -1 if a fitting edge was found, or -1 otherwise
   */
  public int getEdge(int angle) {
    angle = normAngle(angle);
    VertexType vtype = getType();
    if (sDebug >= 3) {
        System.out.println("#       try getEdge(angle " + angle + ")." + index + getName() + "@" + rotate + " ?");
    }
    int iedge = 0;
    boolean busy = true;
    while (busy && iedge < vtype.edgeNo) {
      int edgeAngle = getAngle(iedge);
      if (sDebug >= 3) {
        System.out.println("#         compare " + edgeAngle + " with " + angle);
      }
      if (edgeAngle == angle) {
        busy = false;
      } else { // angles still different
        iedge ++;
      } // still different
    } // while +
    if (busy) {
      iedge = -1; // no matching angle found
    }
    if (sDebug >= 2) {
      if (iedge >= 0) {
        System.out.println("#       getEdge(angle " + angle + ")." + index + getName() + "@" + rotate + expos
            + " -> " + iedge + " -> "
            + getType(vtype.tipes[iedge]).name);
      } else {
        System.out.println("# ** assertion 5: getEdge(angle " + angle + ")." + index + getName() + "@" + rotate + expos
            + " -> " + iedge + " -> edge not found");
      }
    }
    return iedge;
  } // getEdge

  /**
   * Creates and returns a new successor {@link #Vertex} of <em>this</em> Vertex (which is already rotated).
   * @param iedge=0..edgeNo -1; the successor is at the end of this edge
   * @return successor Vertex which is properly rotated and linked back to <em>this</em>
   */
  public Vertex getSuccessor(int iedge) {
    VertexType vtype = getType(); // of the focus
    int siType  = vtype.tipes[vtype.isFlipped() 
        ? vtype.normEdge(- iedge) 
        : vtype.normEdge(+ iedge)];
    if (vtype.isFlipped()) {
      siType ^= 1; // normal -> flipped or flipped -> normal
    }
    VertexType suType = getType(siType);
    int suRota  = normAngle(vtype.rotas[vtype.isFlipped() 
        ? vtype.normEdge(- iedge) 
        : vtype.normEdge(+ iedge)
        ] * (vtype.isFlipped() ? -1 : +1));
    int fAngle  = getAngle(iedge); // points to the successor
    if (sDebug >= 2) {
      System.out.println("#     getSuccessor(iedge " + iedge + ")." + index + getName() + "@" + rotate + expos
          + " start: siType " + siType + ", suRota " + suRota);
    }
    Vertex succ = new Vertex(suType); // create a new Vertex
    succ.expos  = expos.moveUnit(fAngle);
    succ.rotate = normAngle(rotate + suRota);
    int bangle  = normAngle(fAngle + 180); // points backwards to the focus
    succ.bedge  = succ.getEdge(bangle);
    if (sDebug >= 2) {
      System.out.println("#             got (iedge " + iedge + ")." + index + getName() + "@" + rotate + expos
          + " -> " + succ.toString() + ", fAngle " + fAngle + ", bangle " + bangle + ", bedge " + bedge);
    }
    return succ;
  } // getSuccessor
  
} // class Vertex

