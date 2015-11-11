# "The end justifies the means. But what if there never is an end? All we have is means." 
#     - Ursula K. Le Guin, The Lathe of Heaven

# ISIF 7... ISIF 2... ISIF... arggh!
# Accelerated convergence of MAPI structures
# A work in progress - Jarvist Moore Frost

VASPGAMMA="mpirun -np 24 /opt/vasp5.3.5-gamma"
VASP="mpirun -np 24 /opt/vasp5.3.5"

k_gamma="1 1 1"
k_222="2 2 2"
k_final="6 6 6"

# IBRION = 1 ; RMM-DIIS
# IBRION = 2 ; conjugate gradients. STEP=1, forces, STEP=2, Trial, STEP=3, correction, and so on.
#              i.e. NSW=3,5,7,9 etc.
# IBRION = 3 ; Damped MD. Supply SMASS and POTIM

# ISIF = 2 ; Move atoms only
# ISIF = 3 ; Move atoms, change unit cell shape and volume
# ISIF = 5 ; Cell shape only
# ISIF = 6 ; Cell shape and volume
# ISIF = 7 ; Cell volume only

# Coarse volume of unit cell, with 3 steps RMM-DIIS
recipe[1]="ISIF = 7 
IBRION = 1
POTIM = 0.15
NSW = 3"
k_points[1]="$k_gamma"

# Coarse shape of unit cell, with 3 steps RMM-DIIS
recipe[2]="ISIF = 5 
IBRION = 1
POTIM = 0.15
NSW = 3"
k_points[2]="$k_gamma"

# Conjugate gradient volume of unit cell
recipe[3]="ISIF = 2
IBRION = 2
POTIM = 0.15
NSW = 7"
k_points[3]="$k_gamma"

# RMM-DIIS of volume and shape of unit cell
recipe[4]="ISIF = 6 
IBRION = 1
POTIM = 0.15
NSW = 5"
k_points[4]="$k_gamma"

# Conjugate gradient of ion posn
recipe[5]="ISIF = 2 
IBRION = 2
POTIM = 0.15
NSW = 21"
k_points[5]="$k_gamma"

# OK; best guess at Gamma!

recipe[6]="ISIF = 2 
IBRION = 2
POTIM = 0.15
NSW = 9"
k_points[6]="$k_222"

recipe[7]="ISIF = 6 
IBRION = 1
POTIM = 0.15
NSW = 5"
k_points[7]="$k_222"

recipe[8]="ISIF = 2 
IBRION = 2
POTIM = 0.15
NSW = 21"
k_points[8]="$k_222"

# OK, final k-mesh

recipe[9]="ISIF = 6 
IBRION = 1
POTIM = 0.15
NSW = 5"
k_points[9]="$k_final"

recipe[10]="ISIF = 2 
IBRION = 2
POTIM = 0.15
NSW = 21"
k_points[10]="$k_final"

recipes=10

for id in ` seq -w ${recipes} `
do
    recipefolder="recipe-${id}"
    echo "Cooking up ===> " "${recipefolder}"
    echo "${recipe[$id]}"

    # OK, make a sub folder
    mkdir "${recipefolder}"
    
    # Construct the full INCAR
    ## Header of INCAR
    cat INCAR > "${recipefolder}/INCAR"
    ## Recipe lines as specified above...
    echo "${recipe[$id]}" >> "${recipefolder}/INCAR"
    
    # Copy POTCAR, POSCAR
    cp -a POSCAR "${recipefolder}/POSCAR"
    cp -a POTCAR "${recipefolder}/POTCAR"
    
    # Compose KPOINTS file
    cat  > "${recipefolder}/KPOINTS" << EOF
Automatic mesh
0
Gamma
  ${k_points[$id]} 
0.  0.  0.
EOF

    # OK; now run vasp!
    cd "${recipefolder}"
    
    if [ "${k_points[$id]}" == "${k_gamma}" ]
    then
        echo "Here goes VASP-GAMMA!"
        ${VASPGAMMA}
    else
        echo "Here goes VASP!"
        ${VASP}
    fi

    echo "VASP finished (or crashed... =)"
    # recycle CONTCAR --> POSCAR for next round
    cp -a CONTCAR ../POSCAR
    cd -
done

cat << EOF

"The end justifies the means. But what if there never is an end? All we have is means." 
     - Ursula K. Le Guin, The Lathe of Heaven

EOF

