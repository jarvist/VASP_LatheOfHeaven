#! /usr/bin/awk -f

# extract optimisation steps from a set of OUTCARs provided on command line, and output a multi-molecule XYZ with sequential positions.
# Most easily then viewed in Pymol or similar.

BEGIN{j=0}
{
   if (($1=="POSITION" && $2=="TOTAL-FORCE")) {
   getline
   getline
   i=0
   while (NF!=1) {
      i++
      x[i]=$1
      y[i]=$2
      z[i]=$3
      getline
      }

   print i
   print ""
   for (k=1;k<=i;k++) {
      print "C", x[k], y[k], z[k]
    }
   
   }

}
END{
}


