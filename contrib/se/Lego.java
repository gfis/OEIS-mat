//
// main.cpp
// plainvanillalego
//
// Created by Søren Eilers on 17/09/2018.
// Copyright © 2018 Søren Eilers. All rights reserved.
//

public class Lego {
  private static final int[][] oeis = { // provides links to all known counts in the OEIS
    {0,123762,123770,123778,123786,123794,123802,123810},
    {0,123818,123824,112389},
    {0,0,123832},
    {0,0,0,123838},
    {0,0,0,0,123844}
    };
  private static final int MAX_BLOCKS = 100;  //Maximal number of bricks (unattainable unless b=w=1)

  private int b, w, options;  // The size of the bricks studied, and the number of ways to attach one such under another
  private int n, placed;  // The total number of bricks to place, and the number placed this far
  private int[] x = new int [MAX_BLOCKS];
  private int[] y = new int [MAX_BLOCKS];
  private int[] z = new int [MAX_BLOCKS];  // Location of bricks placed (lower sw corner). The entry at index placed is used as workspace.
  private boolean[] hz = new boolean[MAX_BLOCKS];  // Direction of bricks placed in xy-plane. true means w x b, false means b x w
  private int[] paired = new int[MAX_BLOCKS];  // Used when checking symmetry
  private long counter;  // Total count of configurations. Overflow is unlikely, so no tests are done.

  /**
   * Computes a brick position which is attachable to the brick at entry given by at, using i as an index.
   * i must be between 0 and 2*options-1. As i increases, we go over first bricks over and then under the given one.
   * When the brick size is not square, the instances where the two bricks are parallel are taken first.
   */
  private void placeRelative(int at, int i) {
    int b0,w0;
    if (i >= options) { // Downwards
      i -=options;
      z[placed]=z[at]-1;
    } else { // Upwards
      z[placed]=z[at]+1;
    }
    if (i >= (2*w-1)*(2*b-1)) {
      // Perpendicularly (not square)
      i -= (2*w-1)*(2*b-1);
      hz[placed]=!hz[at];
      w0=i/(b+w-1);
      b0=i%(b+w-1);
    } else {
      // Parallely (or square)
      b0=i/(2*w-1);
      w0=i%(2*w-1);
      hz[placed]=hz[at];
    }
    if (hz[placed]) {
      x[placed]=x[at]+w0-w+1;
      y[placed]=y[at]+b0-b+1;
    } else {
      y[placed]=y[at]+w0-w+1;
      x[placed]=x[at]+b0-b+1;
    }
  }

  private int xdim(int i) {
    return hz[i] ? w : b;
  }

  private int ydim(int i) {
    return hz[i] ? b : w;
  }

  // true when the xy-projections of bricks at i and j overlap
  private boolean meetsXY(int i, int j) {
    return (!(x[i]+xdim(i) <= x[j] || y[i]+ydim(i) <= y[j] || x[i] >= x[j]+xdim(j) || y[i] >= y[j]+ydim(j)));
  }

  // true when the brick in workspace (i.e. at index placed) can be attached to building.
  // It must not collide with any other brick, nor could have been attached at an earlier time in the
  // computation.
  private boolean placeable(int attachable) {
    int i;
    for (i=0; i<placed; i++) {
      if (meetsXY(i,placed)) {
        switch (z[i]-z[placed])
        {
        case 0:
          // Colission
          return false;
        case 1:
        case -1:
          if (i<attachable) {
             // Could have been placed before
            return false;
          }
        }
      }
    }
    return true;
  }

  /**
   * Compute the weight of the configuration:
   * 4 if it is invariant under a rotation of 90 degrees,
   * 2 if it is invariant under a rotation of 180 degrees but not 90,
   * 1 if it isn't invariant under a rotation of 180.
   */
  private int symmetryWeight() {
    int i,j,xmax,xmin,ymax,ymin,x0,y0;
    // Initialization: Compute the smallest box containing all bricks at the same z-level as the first one placed,
    // and set all values of paired[i] to -1
    xmin = x[0];
    ymin = y[0];
    xmax = x[0]+xdim(0);
    ymax = y[0]+ydim(0);
    paired[0] = -1;
    for (i=1; i<placed; i++) {
      paired[i] = -1;
      if (z[i] == z[0]) {
        if (x[i]<xmin) {
          xmin = x[i];
        }
        if (y[i]<ymin) {
          ymin = y[i];
        }
        if (x[i]+xdim(i)>xmax) {
          xmax = x[i]+xdim(i);
        }
        if (y[i]+ydim(i)>ymax) {
          ymax = y[i]+ydim(i);
        }
      }
    }
    // Pass one: If the configuration is symmetric after a 180 degree rotation, the center of this rotation
    // must be the center of the box. Test that all bricks are either rotated back to themselves or are rotated
    // to another brick this way. Place index of matching brick(s) in paired-array.
    // Return with 1 if this fails at any stage, indicated by a -1 persisting after having tried to find a match.
    for (i=0; i<placed; i++) {
      if (paired[i]<0) {
        // Coordinates of rotated brick
        x0=xmax+xmin-x[i]-xdim(i);
        y0=ymax+ymin-y[i]-ydim(i);
        for (j=i;  j<placed;  j++) {
          if (x[j] == x0 && y[j] == y0 && z[j] == z[i] && hz[j] == hz[i] ) {
            paired[i]=j;
            paired[j]=i;
            break;
          }
          if (paired[i]<0) {
            return 1;
          }
        }
      }
    }
    // Pass two: We now know the configuration is symmetric after a rotation of 180 degrees and must determine if it is even
    // symmetric after a rotation of 90 degrees. This is only possible if the box is square. We use the pairing found in the
    // first pass: bricks paired with themselves are possible exactly when the bricks are square, so if this is
    // the case we flag back to -1. For the rest we look for the brick which is a 90 degree rotation of the given one. If it
    // exists, it cannot be paired with itself, and all the four involved bricks are flagged with -1.
    // We return 2 if this process fails at any stage, indicated by a persisting non-negative index, and 4 if it doesn't.
    if ((xmax-xmin)!=(ymax-ymin)) {
      return 2;
    }
    for (i=0;  i<placed;  i++) {
      if (paired[i] >= 0) {
        if (paired[i] == i) {
          if (w == b) {
            paired[i]=-1;
          } else {
            return 2;
          }
        }
        x0 = -y[i]+(ymax+ymin+xmax+xmin)/2-ydim(i);
        y0 = x[i]+(ymax+ymin-xmax-xmin)/2;
        for (j=i+1; j<placed; j++) {
          if (x[j] == x0 && y[j] == y0 && z[j] == z[i] && (w == b || hz[j] != hz[i]) ) {
            paired[paired[i]] = -1;
            paired[paired[j]] = -1;
            paired[i] = -1;
            paired[j] = -1;
            break;
          }
          if (paired[i] >= 0) {
            return 2;
          }
        }
      }
    }
    return 4;
  }

  /**
   * Count configurations recursively adding bricks to index attachfrom. If indexfrom is positive the bricks added
   * to the brick at attachfrom must have index bigger than or equal to indexfrom, in the sense of the placeRelative()
   * method. Several global variables are used for efficiency.
   */
  private void count(int attachfrom, int indexfrom) {
    int buildon,i;
    if (n == placed) {
      // Configuration finished, compute and add weight
      counter += symmetryWeight();
    } else {
      // Go through all options for adding the next brick
      for (buildon = attachfrom;  buildon<placed;  buildon++) {
        for (i = indexfrom; i<2*options; i++) {
          placeRelative(buildon,i);
          if (placeable(buildon)) {
            // Place brick and continue recursively
            placed++;
            count(buildon,i+1);
            placed--;
          }
        }
        indexfrom = 0;
      }
    }
  }

  /**
   * Process the parameters.
   * @param w width
   * @param b breadth
   */
  public void process(final int w, final int b) {
    if (oeis[w-1][b-1]>0) {
      System.out.println("[All known terms available at oeis.org/A" + oeis[w-1][b-1] + "]");
    }
    if (w!=b && oeis[b-1][w-1]>0) {
      System.out.println("[All known terms available at oeis.org/A" + oeis[b-1][w-1] + "]");
    }

    // Initialization
    options = ((w == b) ? (w+b-1)*(w+b-1) : (w+b-1)*(w+b-1)+(2*w-1)*(2*b-1));
    x[0] = 0;
    y[0] = 0;
    z[0] = 0;
    hz[0] = true;

    // Compute as far as possible. This will grind to a halt (unless b=w=1) much before MAX_BLOCKS is reached
    for (n=1; n <= MAX_BLOCKS; n++) {
      counter = 0;
      placed = 1;
      count(0,0);
      // Every non-symmetric configuration will be counted 2n times if the bricks are non-square,
      // 4n if they are square. The symmetric ones will be counted fewer times as corrected by the
      // symmetryWeight() function.
      System.out.println(n + " " + (counter/(n*((b == w) ? 4 : 2))));
    }
  }

  /** Main method
   * @param args command line arguments: w b
   */
  public static void main(String[] args) {
    int iarg = 0;
    int w = 1;
    int b = 1;
    while (iarg < args.length) { // consume all arguments
      String opt = args[iarg ++];
      if (false) {
      } else if (opt.equals  ("-w")   ) {
        try {
          w = Integer.parseInt(args[iarg ++]);
        } catch (Exception exc) { // take default
        }
      } else if (opt.equals  ("-b")   ) {
        try {
          b = Integer.parseInt(args[iarg ++]);
        } catch (Exception exc) { // take default
        }
      } else {
        System.err.println("??? invalid option: \"" + opt + "\"");
      }
    } // while args
    new Lego().process(w, b);
  }
}
