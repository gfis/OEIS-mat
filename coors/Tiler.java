/* Generate tilings from Galebach's list
 * @(#) $Id$
 * Copyright (c) 2020 Dr. Georg Fischer
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
import java.util.TreeMap;
import java.util.Iterator;
import java.util.LinkedList;
// import  org.apache.log4j.Logger;

/**
 * Class for the generation of tilings and their coordinations sequences.
 * @author Georg Fischer
 */
public class Tiler implements Serializable {
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
    protected static int sDebug;

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

    /** current number of generated edges (1 based) */
    private int mNumEdges;

    /** Maximum distance from origin */
    private int mMaxDistance;

    /** Offset1 of the sequences */
    private int mOffset;

    /** Allowed vertex types for this tiling */
    public static VertexType[] mVertexTypes; // [0] is reserved
    /** first free allowed VertexType */
    public static int ffVertexTypes;

    /** Allocated vertices */
    public static ArrayList<Vertex> mVertices; // [0] is reserved
    /** first free index in vertices */
    public static int ffVertices;

    /** Maps exact {@link Position}s of vertices to their index in {@link mVertices}.
     *  Used for the detection of duplicate target vertices.
     */
    public static TreeMap<Position, Integer> mPosiVertex;

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

    /** Whether an SVG image file should be written */
    private boolean mSVG;

    /** HOw many &gt;line&lt; elements should be written */
    private int mSVGCount;

    /** Writer for SVG output */
    private PrintWriter mSVGWriter;

    /**
     * Writes some portion of an SVG file.
     * @param param one or more complete SVG XML elements, or
     * "&gt;x-head&lt;filename&gt;/x-head&lt;" for file open and SVG prelude, or
     * "&gt;x-tail /&lt;" for SVG postlude and file close.
     */
    private void writeSVG(String param) {
        if (mSVG) {
            String text = param;
            try {
                if (! param.startsWith("<x-")) { // normal SVG XML element(s)
                    if (mNumEdges <= mSVGCount) { // number of <line> elements can be limited
                        mSVGWriter.println(text);
                    }
                } else if (param.startsWith("<x-head")) { // special tag
                    int w1 = 8;
                    int w2 = 2 * w1;
                    param = param.replaceAll("\\<[^\\>]+\\>([^\\<]+)\\<.*", "$1");
                    mSVGCount = mNumTerms;
                    if (param.equals("-")) { // stdout
                         mSVGWriter = new PrintWriter(Channels.newWriter(Channels.newChannel(System.out), sEncoding));
                    } else { // not stdout
                         WritableByteChannel channel = (new FileOutputStream (param, false)).getChannel();
                         mSVGWriter = new PrintWriter(Channels.newWriter(channel, sEncoding));
                    } // not stdout
                    text = ""
                    + "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
                    + "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\"\n"
                    + " \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\" [\n"
                    + " <!ATTLIST svg xmlns:xlink CDATA #FIXED \"http://www.w3.org/1999/xlink\">\n"
                    + "]>\n"
                    + "<!--\n"
                    + "    Tiler - Georg Fischer. Do NOT edit here!\n"
                    + "-->\n"
                    + "<?xml-stylesheet type=\"text/css\" href=\"tiling.css\" ?>\n"
                    + "<svg width=\"192mm\" height=\"192mm\"\n"
                    + "viewBox=\"-" + w1 + "-" + w1 + " " + w2 + " " + w2 + "\" \n"
                    + "xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
                    + "\n"
                    + "<title>Tiling</title>\n"
                    + "<g id=\"tile\">\n"
                    + "<rect class=\"l8\" fill=\"black\" x=\"-" + w1 +"\" y=\"-" + w1 + "\" width=\"" + w2 +"\" height=\"" + w2 + "\" />\n"
                    ;
                    mSVGWriter.println(text);
                } else if (param.startsWith("<x-tail")) { // special tag
                    text = ""
                    + "</g>\n"
                    + "</svg>\n"
                    ;
                    mSVGWriter.println(text);
                    mSVGWriter.close();
                }
            } catch (Exception exc) {
                // log.error(exc.getMessage(), exc);
                System.err.println(exc.getMessage());
                exc.printStackTrace();
            } // try
        } // SVG output planned and not yet finished
    } // writeSVG

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
    protected  class Position implements Serializable, Comparable<Position> {
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
         * Determines whether <em>this</em> Position is equal to a second
         * @param pos2 second Position
         * @return true if the underlaying arrays have the same values
         */
        public boolean equals(Position pos2) {
            boolean result = true; // assume succes
            int ipos = 0;
            while (result && ipos < 4) {
                result =   xtuple[ipos] == pos2.xtuple[ipos]
                        && ytuple[ipos] == pos2.ytuple[ipos];
                ipos ++;
            } // while ipos
            return result;
        } // equals

        /**
         * Comapres <em>this</em> Position with a second
         * @param pos2 second Position
         * @return -1, 0, 1 if this < = > pos2 in lexicographical order of the tuple elements
         */
        public int compareTo(Position pos2) {
            int result = 29; // undefined so far
            int ipos = 0;
            while (result == 29 && ipos < 4) { // as long as there is no difference
                if (false) {
                } else if (xtuple[ipos] < pos2.xtuple[ipos]) {
                    result = -1;
                } else if (xtuple[ipos] > pos2.xtuple[ipos]) {
                    result =  1;
                } else { // x =
                    if (false) {
                    } else if (ytuple[ipos] < pos2.ytuple[ipos]) {
                        result = -1;
                    } else if (ytuple[ipos] > pos2.ytuple[ipos]) {
                        result =  1;
                    }
                } // else check next position
                ipos ++;
            } // while ipos
            if (result == 29) { // no difference found
                result = 0;
            }
            return result;
        } // compareTo

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
         * @return a tuple "[x0,x1,x2,x3 ,y0,y1,y2,y3]" of short integers
         */
        public String toString() {
            StringBuffer result = new StringBuffer(64);
            int ip;
            result.append('(');
            result.append(getX());
            result.append(',');
            result.append(getY());
        /*
            for (ip = 0; ip < 4; ip ++) {
                result.append(',');
                result.append(String.valueOf(xtuple[ip]));
            } // for ip
            result.append(' ');
            for (ip = 0; ip < 4; ip ++) {
                result.append(',');
                result.append(String.valueOf(ytuple[ip]));
            } // for ip
        */
            result.append(')');
            result.setCharAt(0, '(');
            return result.toString();
        } // toString

        /**
         * Gets the cartesian x coordinate (to the right) from <em>this</em> Position
         * @return a String with 4 decimal digits
         */
        public String getX() {
            return String.format("%.4f", cartesian(xtuple)).replaceAll("\\,", "."); // for German Locale
        } // getX

        /**
         * Gets the cartesian y coordinate (downwards, because of SVG) from <em>this</em> Position
         * @return a String with 4 decimal digits
         */
        public String getY() {
            return String.format("%.4f", cartesian(ytuple)).replaceAll("\\,", "."); // for German Locale
        } // getY

        /**
         * Moves <em>this</em> Position by a unit distance in some angle
         * @param angle in degrees 0..360
         * @return new Position
         */
        public Position moveUnit(int angle) {
            int icircle = Math.round(angle / 15) % 24;
            return this.add(mUnitCirclePoints[icircle]);
        }

    } // class Position

    /** Positions in the unit circle = increments for the next {@link Vertex} */
    private final Position[] mUnitCirclePoints = new Position[]
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

    /** Angles in degrees for regular polygones */
    private static final int[] mRegularAngles = new int[] { 0
            , 360 // [ 1] full circle
            , 180 // [ 2] half circle
            ,  60 // [ 3] triangle
            ,  90 // [ 4] square
            , 108 // [ 5] pentagon
            , 120 // [ 6] hexagon
            ,   0 // [ 7] (heptagon)
            , 135 // [ 8] octogon
            , 140 // [ 9] nonagon
            , 144 // [10] decagon
            ,   0 // [11] (hendecagon)
            , 150 // [12] dodecagon
            };

    /**
     * Gets the sum of two angles
     * @param angle1 first angle
     * @param angle2 second angle
     * @return (non-negative) sum of the two angles modulo 360 degrees.
     */
    public static int angleSum(int angle1, int angle2) {
        return Math.floorMod(angle1 + angle2, 360);
    } // angleSum

    /**
     * Tests the computation of {@link Position}s
     */
    public void testCirclePositions() {
        Position origin = new Position();
        for (int ipos = 0; ipos < mUnitCirclePoints.length + 1; ipos ++) {
            Position pos = origin.moveUnit(ipos * 15);
            System.out.println(String.format("[%2d], %3d = %s", ipos, ipos * 15, pos.toString()));
            writeSVG("<line class=\"k" + String.valueOf(ipos % 8)
                    + " x1=\"0.0\" y1=\"0.0\" x2=\"" + pos.getX() + "\" y2=\"" + pos.getY()
                    + "\"><title>" + mNumEdges
                    + "</title></line>");
        } // for ipos
        for (int ipos = 0; ipos < mUnitCirclePoints.length; ipos += 4) {
            int ipos8 = (ipos + 8) % 24;
            Position hexPos = mUnitCirclePoints[ipos].add(mUnitCirclePoints[ipos8]);
            System.out.println(String.format("[%2d] + [%2d] = %8s,%8s"
                    , ipos, ipos8, hexPos.getX(), hexPos.getY()));
        } // for ipos
    } // testCirclePositions

    /**
     * Class for an allowed vertex type.
     */
    protected class VertexType implements Serializable { // numbered 1, 2, 3 ... ; 0 is not used
        int    index; // even for normal type, odd for flipped version
        String name; // for example "A" for normal or "a" (lowercase) for flipped version
        String galId; // e.g. "Gal.2.1.1"
        String sequence; // list of terms of the coordination sequence
        int    edgeNo; // number of edges; the following arrays are indexed by iedge=0..edgeNo-1
        int[]  polys; // number of corners of the regular (3,4,6,8, or 12) polygones (shapes)
                // are arranged clockwise (for SVG, counter-clockwise by Galebach)
                // around this vertex type.
                // First edge goes from (x,y)=(0,0) to (1,0); the shape is to the left of the edge
        int[]  taVtis; // VertexType indices of target vertices (normally even, odd if flipped / C')
        int[]  taRots; // how many degrees must the target vertices be rotated, from Galebach
        int[]  sweeps; // positive angles from iedge to iedge+1 for (iedge=0..edgeNo) mod edgeNo

        /**
         * Empty constructor
         */
        VertexType() {
            index    = 0;
            name     = "Z";
            galId    = "Gal.0.0.0";
            sequence = "";
            edgeNo   = 0;
            polys    = new int[0];
            taVtis   = new int[0];
            taRots   = new int[0];
            sweeps   = new int[0];
        } // VertexType()

        /**
         * Constructor
         * @param pGalId Galebach's identification of a vertex type: "Gal.u.t.v"
         * @param vertexId clockwise dot-separated list of
         *     the polygones followed by the list of types and angles
         * @param taRotList clockwise semicolon-separated list of
         *     vertex type names and angles (and apostrophe if flipped)
         * @param sequence a list of initial terms of the coordination sequence
         */
        VertexType(String pGalId, String vertexId, String taRotList, String sequence) {
            // for example: A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4 tabA 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
            String[] corners = vertexId.split("\\.");
            String[] parts   = taRotList.split("\\;\\s*");
            index    = ffVertexTypes; // even = not flipped
            name     = "ZABCDEFGHIJKLMNOP".substring(index / 2, index / 2 + 1);
            galId    = pGalId;
            sequence = sequence;
            edgeNo   = parts.length;
            polys    = new int[edgeNo];
            taVtis   = new int[edgeNo];
            taRots   = new int[edgeNo];
            for (int iedge = 0; iedge < edgeNo; iedge ++) {
                try {
                    taVtis[iedge] = (parts[iedge].charAt(0) - 'A' + 1) * 2; // even, A -> 2
                    if (parts [iedge].endsWith("'")) { // is flipped
                        taVtis[iedge] ++; // make it odd
                        parts [iedge] = parts[iedge].replaceAll("\\'","");
                    }
                    polys [iedge] = 0;
                    taRots[iedge] = 0;
                    polys [iedge] = Integer.parseInt(corners[iedge]);
                    taRots[iedge] = Integer.parseInt(parts[iedge].substring(2));
                } catch (Exception exc) {
                    System.err.println("# ** assertion 4: descriptor for \"" + pGalId + "\" bad");
                }
            } // for iedge
            fillSweeps();
        } // VertexType(String, String, String)

        /**
         * Returns a new, flipped version of <em>this</em> VertexType,
         * which must be normal.
         * @return a VertexType with the first edge (-> (x+1,y+0)) identical,
         * but the following edges taken from the end backwards
         */
        public VertexType flip() {
            VertexType result = new VertexType();
            result.index    = index + 1;
            result.name     = name.toLowerCase();
            result.galId    = galId; // + "s";
            result.sequence = sequence;
            result.edgeNo   = edgeNo;
            result.polys    = new int[edgeNo];
            result.taVtis   = new int[edgeNo];
            result.taRots   = new int[edgeNo];
            for (int iedge = 0; iedge < edgeNo; iedge ++) {
                if (false && iedge == 0) {
                    result.polys [iedge] =         polys [iedge];
                    result.taVtis[iedge] = flipped(taVtis[iedge]);
                    result.taRots[iedge] =         taRots[iedge];
                } else {
                    result.polys [iedge] =         polys [edgeNo - 1 - iedge];
                    result.taVtis[iedge] = flipped(taVtis[edgeNo - 1 - iedge]);
                    result.taRots[iedge] =         taRots[edgeNo - 1 - iedge];
                }
            } // for iedge
            result.fillSweeps();
            return result;
        } // flip

        /**
         * Fills the cummulative angles for the edges of <em>this</em> VertexType,
         * The angles are positive and sweep from 0 to iedge+1 for (iedge=0..edgeNo) mod edgeNo.
         * The last sweeping angle must always be 360 degrees.
         */
        private void fillSweeps() {
            int sum = 0;
            sweeps  = new int[edgeNo];
            for (int iedge = 0; iedge < edgeNo; iedge ++) {
                sum += mRegularAngles[polys[iedge]];
                sweeps[iedge] = sum;
            } // for iedge
        } // fillSweeps

        /**
         * Returns a representation of the VertexType
         * @return JSON
         */
        public String toString() {
            pushIndent();
            String result
                    = "{ \"i\": \""     + index + "\""
                    + ", \"name\": \""  + name  + "\""
                    + ", \"taRots\": "  + join(",", taRots)
                    + ", \"sweeps\": "  + join(",", sweeps)
                    + ", \"taVtis\": "  + join(",", taVtis)
                    + ", \"polys\": "   + join(",", polys)
                    + ", \"galId\": \"" + galId + "\""
                    + " }\n";
            popIndent();
            return result;
        } // toString

    } // class VertexType

    /**
     * Class for an allocated vertex.
     */
    protected class Vertex implements Serializable { // numbered 1, 2, 3 ... ; 0 is not used
        int index; // in mVertices
        int typeIndex; // 1, 2, 3 ... for counter-clockwise orientation (0 is reserved), or -1, -2 for clockwise
        int rotate; // the vertex type was rotated counter-clockwise by so many degrees
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
        } // Vertex()

        /**
         * Constructor with an index of a VertexType
         * @param itype index of type of the new vertex, is positive for counter-clockwise,
         * negative for clockwise orientation
         * @param ipred index of predecessor vertex which needs <em>this</em> new successor vertex
         * @param iedge which edge of the predecessor leads to <em>this</em> new successor vertex
         */
        public Vertex(int itype) {
            // setting 'index' is postponed to addVertex
            typeIndex  = itype; // may be negative
            rotate      = 0;
            expos      = new Position();
            int edgeNo = itype == 0 ? 0 : getVertexType(itype).edgeNo;
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
            return getVertexType(typeIndex);
        } // getType

        /**
         * Returns a representation of the Vertex
         * @return JSON for edges
         */
        public String toString() {
            pushIndent();
            String result
                    = "{ \"i\": "        + String.format("%4d", index)
                    + ", \"type\": "     + String.format("%2d", typeIndex)
                    + ", \"rot\": "      + String.format("%3d", rotate)
                    + ", \"fix\": "      + fixedEdges
                    + ", \"succs\": \""  + join(",", succs ) + "\""
                //  + ", \"preds\": \""  + join(",", preds ) + "\""
                //  + ", \"shapes\": \"" + join(",", shapes) + "\""
                    + ", \"pos\": \""    + expos.toString()  + "\""
                    + " }\n";
            popIndent();
            return result;
        } // toString

    } // class Vertex

    /**
     * Returns a representation of the tiling
     * @return JSON for types and vertices
     */
    public String toString() {
        // pushIndent();
        String result  = sIndent + "{ \"ffVertexTypes\": " + ffVertexTypes  + "\n"
                                     + sIndent + ", \"mVertexTypes\":\n";
        try {
            String sep = "  , ";
            for (int ind = 0; ind < ffVertexTypes; ind ++) { // even (normal) and odds (flipped) versions
                result += sIndent + (ind == 0 ? "  [ " : sep) + getVertexType(ind).toString();
            } // for types
            result += sIndent + "  ]\n";

            result += sIndent + ", \"ffVertices\": " + ffVertices + "\n"
                         +  sIndent + ", \"mVertices\":\n";
            for (int ind = 0; ind < ffVertices; ind ++) {
                Vertex focus = mVertices.get(ind);
                result += sIndent + (ind == 0 ? "  [ " : sep) + focus.toString();
            } // for vertices
            result += sIndent + "  ]\n";

            result += sIndent + ", \"size\": " + mPosiVertex.size() + ", \"mPosiVertex\": \n";
            Iterator<Position> piter = mPosiVertex.keySet().iterator();
            while (piter.hasNext()) {
                Position pos = piter.next();
                int ind = mPosiVertex.get(pos).intValue();
                result += sIndent + (ind == 0 ? "  [ " : sep) + "{ \"pos\": \"" + pos.toString()
                        + ", index: " + ind + " }\n";
            } // while piter
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

    //----------------------------------------------------------------
    /**
     * Adds an existing VertexType and creates and adds the flipped version
     * @param normalType the VertexType to be added
     * @return typeIndex of the resulting, normal VertexType
     */
    public int addTypeVariants(VertexType normalType) {
        int result = ffVertexTypes;
        mVertexTypes[ffVertexTypes ++] = normalType;
        mVertexTypes[ffVertexTypes ++] = normalType.flip();
        return result;
    } // addTypeVariants

    /**
     * Creates and adds a new VertexType from Galebach's parameters
     * together with the flipped version
     * @param galId Galebach's id "Gal.u.t.v"
     * @param vertexId clockwise dot-separated list of
     *     the polygones followed by the list of types and angles
     * @param taRotList clockwise semicolon-separated list of
     *     vertex type names and angles (and apostrophe if flipped)
     * @param sequence a list of initial terms of the coordination sequence
     * @return typeIndex of the resulting VertexType
     */
    public int addTypeVariants(String galId, String vertexId, String taRotList, String sequence) {
        return addTypeVariants(new VertexType(galId, vertexId, taRotList, sequence));
    } // addTypeVariants

    /**
     * Gets a VertexType
     * @param typeIndex index of type, maybe negative,
     * for example 3 for C or -3 for the flipped version C'.
     * @return the corresponding VertexType with edges rotated clockwise in both versions
     */
    public static VertexType getVertexType(int typeIndex) {
        return mVertexTypes[typeIndex];
    } // getVertexType

    /**
     * Gets the number of allocated {@link VertexType} pairs
     * @return half of {@link #ffVertexTypes}
     * (normal and flipped version count as one)
     */
    public int numVertexTypes() {
        return ffVertexTypes / 2;
    } // numVertexTypes

    /**
     * Gets the type index of the flipped version of a {@link VertexType}
     * (A' for A and A for A')
     * @param typeIndex index in {@link #mVertexTypes}
     * @return typeIndex + 1 for even typeIndex, typeIndex - 1 for odd
     */
    public int flipped(int typeIndex) {
        return (typeIndex & 1) == 0 ? typeIndex + 1 : typeIndex - 1;
    } // flipped

    /**
     * Initializes the dynamic data structures of <em>this</em> Tiling.
     * @param numTypes number of {@link VertexTypes},
     * or 0 if only the dynamic structures are to be cleared
     */
    public void initializeTiling(int numTypes) {
        if (numTypes > 0) { // full
            mVertexTypes  = new VertexType[(numTypes + 1) * 2]; // "+1": [0..1] are not used / reserved
            ffVertexTypes = 0;
            addTypeVariants(new VertexType()); // the reserved elements [0..1]
        } // full
        // clear the dynamic structures:
        sIndent  = "";
        mNumEdges = 1; // used for titles on SVG <line>s and for limitation of number of lines to be output
        mPosiVertex = new TreeMap<Position, Integer>(); // or HashMap<Position, Integer>;
        mVertices = new ArrayList<Vertex>(256);
        ffVertices = 0;
        addVertex(new Vertex()); // [0] is not used / reserved
        addVertex(new Vertex()); // [1] is not used / reserved
    } // initializeTiling

    //----------------------------------------------------------------
    /**
     * Creates and adds a new Vertex
     * @param itype index in {@link mVertexTypes}
     * @return index of added Vertex in {@link mVertices}
     */
    public int addVertex(int itype) {
        return addVertex(new Vertex(itype));
    } // addVertex

    /**
     * Adds a Vertex
     * @param itype index in {@link mVertexTypes}
     * @return index of added Vertex in {@link mVertices}
     */
    public int addVertex(Vertex vertex) {
        vertex.index = ffVertices;
        mVertices.add(vertex);
        mPosiVertex.put(vertex.expos, vertex.index);
        ffVertices = mVertices.size();
        return vertex.index;
    } // addVertex

    /**
     * Gets the angle for an edge of a {@link VertexType}
     * @param iedge number of the edge, zero-based
     * @return angle in degrees, for example 6.4.4.3:
     * <pre>
     * iedge:       0    1    2    3
     * polys[ie.]: [6   .4   .3   .4]
     * type > 0:    0  120   90   60   90  (clockwise = + because of SVG y=downwards, Galebach has it opposite)
     * sweep+:      0  120  210  270  360
     * type < 0:    0  -90  -60  -90 -120  (counter-clockwise)
     * sweep-:      0  -90 -150 -240 -360
     * </pre>
     */
    public int getEdgeAngle(int typeIndex, int iedge) {
        int itype = Math.abs(typeIndex);
        int ipoly = 0;
        int sweep = 0; // the cummulative angle
        int[] polys = getVertexType(itype).polys;
        if (iedge > 0) {
            if (itype == typeIndex) { // positive, clockwise:         6.4.4.3
                while (ipoly < iedge) {
                    sweep = angleSum(sweep, mRegularAngles[polys[ipoly]]);
                    ipoly ++;
                }
            } else {                  // negative, counter-clockwise: 3.4.4.6
                ipoly = polys.length;
                while (ipoly > polys.length - iedge) {
                    ipoly --;
                    sweep = angleSum(sweep, - mRegularAngles[polys[ipoly]]);
                }
            }
            if (sDebug >= 2) {
                System.out.println("# getEdgeAngle(" + typeIndex + ", " + iedge + "): polys[" + ipoly + "]="
                        + polys[ipoly] + "-> sweep=" + sweep);
            }
        } // iedge > 0
        return sweep;
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
        int[] polys = getVertexType(itype).polys;
        int sweep = succ.rotate; // the cummulative angle
        int iedge = 0;
        boolean busy = true;
        if (itype == succ.typeIndex) { // positive, counter-clockwise: 6.4.4.3
            while (busy && iedge < polys.length) { // try to find a matching edge
                if (sDebug >= 2) {
                    System.out.println("# try MatchingEdge+(" + itype + "," + foAngle + "): sweep=" + sweep + ", iedge=" + iedge);
                }
                if ((sweep + 180) % 360 == foAngle) {
                    busy = false; // match found
                } else {// not matched, advance
                    sweep = angleSum(sweep, mRegularAngles[polys[iedge]]);
                    iedge ++;
                } // advance +
            } // while busy +
        } else {                       // negative, clockwise:         3.4.4.6
            iedge = polys.length - 1;
            while (busy && iedge >= 0) { // try to find a matching edge
                if (sDebug >= 2) {
                    System.out.println("# try MatchingEdge+(" + itype + "," + foAngle + "): sweep=" + sweep + ", iedge=" + iedge);
                }
                if ((sweep + 180) % 360 == foAngle) {
                    busy = false; // match found
                } else {// not matched, advance
                    sweep = angleSum(sweep, mRegularAngles[polys[iedge]]);
                    iedge --;
                } // advance -
            } // while busy -
            iedge = polys.length - 1 - iedge;
        } // negative
        if (busy) { // not found
            iedge = -1; // failure
        }
        if (sDebug >= 1) {
            System.out.println("# getMatchingEdge -> " + iedge);
        }
        return iedge;
    } // getMatchingEdge
    //----------------------------------------------------------------
    /**
     * Creates a successor vertex and connects to it
     * @param ifocus index of the vertex which gets the new successor
     * @param iedge attach the successor at this edge
     * @return index of new successor vertex, or 0 if attached to an existing vertex
     */
    public int attach(int ifocus, int iedge) {
        int isucc = 0; // future result; assume that the successor already exists
        Vertex focus = mVertices.get(ifocus);
        VertexType fotype = focus.getType();
        if (focus.succs[iedge] == 0) { // determine successor
            Position pos = focus.expos;
            int foEdgeAngle = angleSum(focus.rotate, getEdgeAngle(focus.typeIndex, iedge));
            int suType = fotype.taVtis[iedge];
            if (focus.typeIndex < 0) {
                // suType = fotype.taVtis[fotype.taVtis.length - iedge];
            }
            Vertex succ = new Vertex(suType); // try a new one
            succ.expos = focus.expos.moveUnit(foEdgeAngle);
            succ.rotate = angleSum(focus.rotate, fotype.taRots[iedge]);
            if (sDebug >= 2) {
                System.out.println("# attach(" + ifocus + ", " + iedge + "): foEdgeAngle=" + foEdgeAngle
                        + ", succ.rotate=" + succ.rotate);
            }
            int suEdgeNo = getMatchingEdge(succ, foEdgeAngle);
            if (suEdgeNo < 0) { // not found
                System.out.println("# ** assertion 1 in attach: no matching edge, succ.expos="
                        + succ.expos.toString() + ", succ.rotate=" + succ.rotate + ", focus=" + focus.index);
            } else { // matching angles
                Integer intTarget = mPosiVertex.get(succ.expos); // does the successor Vertex already exist?
                if (intTarget == null) { // nothing at that position - store new Vertex
                    isucc = addVertex(succ);
                    focus.succs[iedge] = isucc; // set forward link
                } else { // successor Vertex already exist
                    isucc = intTarget.intValue();
                    succ  = mVertices.get(isucc);
                    focus.succs[iedge] = isucc; // set forward link
                    isucc = 0; // do not enqueue it
                } // successor Vertex already exist
                if (succ.succs[suEdgeNo] == 0) { // edge was not yet connected
                    succ.succs[suEdgeNo] = ifocus; // set backward link
                } else if (succ.succs[suEdgeNo] != ifocus) {
                    System.out.println("# ** assertion 2 in attach: no matching edge, succ.expos="
                           + succ.expos.toString() + ", succ.rotate=" + succ.rotate + ", focus=" + focus.index);
                }
                if (sDebug >= 1) {
                    System.out.println("# ifocus=" + ifocus + ", iedge=" + iedge
                            + ", focus.rotate=" + focus.rotate
                            + ", focus.expos="  + focus.expos.toString()
                            + ", getEdgeAngle=" + foEdgeAngle
                            + "\n#  -> isucc="  + isucc
                            + ", succ.rotate="  + succ.rotate
                            + ", succ.expos="   + succ.expos.toString()
                            + ", suEdgeNo="     + suEdgeNo
                            );
                }
                writeSVG("<line class=\"l" + String.valueOf((iedge) % 8)
                        + "\" x1=\"" + focus.expos.getX()
                        + "\" y1=\"" + focus.expos.getY()
                        + "\" x2=\"" + succ.expos.getX()
                        + "\" y2=\"" + succ.expos.getY()
                        + "\"><title>" + mNumEdges
                        + "</title></line>");
                mNumEdges ++;
            } // matching angles
            focus.fixedEdges ++;
        } else { // focus.succs[iedge] != 0 - ignore
          if (sDebug >= 2) {
              System.out.println("# attach(" + ifocus + ", " + iedge + "): ignore attached succ " + focus.succs[iedge]);
          }
        }
        return isucc;
    } // attach

    /**
     * Computes the neighbourhood of the start vertex up to some distance
     * @param iStartType index of the initial vertex type
     */
    public void computeNet(int iStartType) {
        LinkedList<Integer> queue = new LinkedList<Integer>();
        initializeTiling(0); // reset dynamic structures only
        if (sDebug >= 1) {
            System.out.println("# compute neighbours of vertex type " + iStartType + " up to distance " + mNumTerms);
        }
        int distance = 0;
        queue.add(addVertex(iStartType));
        int addedVertices = 1;
        System.out.println(distance + " " + addedVertices); // b-file output

        distance ++;
        while (distance <= mMaxDistance) {
            addedVertices = 0;
            int levelPortion = queue.size();
            while (levelPortion > 0 && queue.size() > 0) { // queue not empty
                int ifocus = queue.poll();
                if (sDebug >= 2) {
                    System.out.println("# dequeue ifocus=" + ifocus);
                }
                Vertex focus = mVertices.get(ifocus);
                VertexType fotype = focus.getType();
                for (int iedge = 0; iedge < fotype.edgeNo; iedge ++) {
                    int isucc = attach(ifocus, iedge);
                    if (isucc > 0) { // did not yet exist
                        addedVertices ++;
                        queue.add(isucc);
                        if (sDebug >= 2) {
                            System.out.println("# enqueue isucc=" + isucc + ", attached to ifocus=" + ifocus + " at edge " + iedge);
                        }
                    }
                } // for iedge
                levelPortion --;
            } // while portion not exhausted and queue not empty
            System.out.println(distance + " " + addedVertices); // b-file output
            if (sDebug >= 1) {
                System.out.println("# distance " + distance + ": " + addedVertices + " vertices added\n");
            }
            distance ++;
        } // while distance
        if (mPosiVertex.size() != ffVertices - 2) {
            System.out.println("# ** assertion 3 in tiling.toString: " + mPosiVertex.size()
                    + " different positions, but " + (ffVertices - 2) + " vertices\n");
        }
        if (sDebug >= 1) {
            System.out.println("# final net\n" + toString());
        }
        if (mSVG) {
            for (int ind = 2; ind < ffVertices; ind ++) { // ignore reserved [0..1]
                Vertex focus = mVertices.get(ind);
                String var = String.valueOf(focus.typeIndex % 8);
                writeSVG("<g><circle class=\"c" + var
                        + "\" cx=\"" + focus.expos.getX()
                        + "\" cy=\"" + focus.expos.getY()
                        + "\" r=\""  + (ind == 2 ? "0.15" : "0.1") + "\">"
                        + "</circle>"
                        + "<text class=\"t"  + var
                        + "\" x=\""  + focus.expos.getX()
                        + "\" y=\""  + focus.expos.getY()
                        + "\" dy=\"0.03px\">" + String.valueOf(ind) + mVertexTypes[focus.typeIndex].name + "</text>"
                    //  + "<title>"  + mVertexTypes[focus.typeIndex].name + "</title>"
                        + "</g>"
                        );
            } // for vertices
        } // SVG
    } // computeNet

    /**
     * Process one record from the file
     * @param line record to be processed
     */
    private void processRecord(String line) {
        // e.g. line = A265035 tab Gal.2.1.1 tab 3.4.6.4; 4.6.12 tab 12.6.4; A 180'; A 120'; B 90 tab 1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
        String[] fields   = line.split("\\t");
        int ifield = 0;
        ifield ++; // skip aseqno
        String galId      = fields[ifield ++];
        ifield ++; // skip standard notation
        String vertexId   = fields[ifield ++];
        String taRotList  = fields[ifield ++];
        String sequence   = fields[ifield ++];
        try {                                     //  0      1    2    3
            String[] gutv = galId.split("\\."); // "Gal", "2", "9", "1"
            if (false) {
            } else if (gutv[3].equals("1")) { // first of new tiling
                initializeTiling(Integer.parseInt(gutv[1]));
                addTypeVariants(galId, vertexId, taRotList, sequence);
            } else if (gutv[3].equals(gutv[1])) { // last of new tiling
                addTypeVariants(galId, vertexId, taRotList, sequence);
                System.out.println(toString());
                // compute the nets
                for (int itype = 2; itype < ffVertexTypes; itype += 2) {
                    if (getVertexType(itype).galId.equals(mGalId)) { // only this one from all VertexTypes in the Tiling
                        computeNet(itype);
                    }
                } // for itype
            } else {
                addTypeVariants(galId, vertexId, taRotList, sequence);
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

    /**
     * Main method, filters a file, selects a VertexType group for a tiling,
     * dumps the progress of the tilings' generation and
     * possibly writes an SVG drawing file.
     * @param args command line arguments
     */
    public static void main(String[] args) {
        Tiler tiler = new Tiler();
        sDebug = 0;
        try {
            int iarg = 0;
            String fileName = "-"; // assume STDIN/STDOUT
            while (iarg < args.length) { // consume all arguments
                String opt        = args[iarg ++];
                if (false) {
                } else if (opt.equals("-circle")     ) {
                    tiler.testCirclePositions();
                } else if (opt.equals("-d")     ) {
                    sDebug          = Integer.parseInt(args[iarg ++]);
                } else if (opt.equals("-dist")     ) {
                    tiler.mMaxDistance = Integer.parseInt(args[iarg ++]);
                } else if (opt.equals("-f")     ) {
                    tiler.processFile(args[iarg ++]);
                } else if (opt.equals("-id")     ) {
                    tiler.mGalId    = args[iarg ++];
                } else if (opt.equals("-n")     ) {
                    tiler.mNumTerms = Integer.parseInt(args[iarg ++]);
                } else if (opt.equals("-svg")   ) {
                    tiler.mSVG = true;
                    tiler.writeSVG("<x-head>" + args[iarg ++] + "</x-head>");
                } else {
                    System.err.println("??? invalid option: \"" + opt + "\"");
                }
            } // while args
            if (tiler.mSVG) {
                tiler.writeSVG("<x-tail />"); // also closes mSVGWriter
            }
        } catch (Exception exc) {
            // log.error(exc.getMessage(), exc);
            System.err.println(exc.getMessage());
            exc.printStackTrace();
        }
    } // main

} // Tiler

