# "The end justifies the means. But what if there never is an end? All we have is means." 
#     - Ursula K. Le Guin, The Lathe of Heaven

# ISIF 7... ISIF 2... ISIF... arggh!
# Accelerated convergence of MAPI structures
# A work in progress - Jarvist Moore Frost

VASP="mpirun -np 24 /opt/vasp5.3.5-gamma"

# IBRION = 1 ; RMM-DIIS
# IBRION = 2 ; conjugate gradients. STEP=1, forces, STEP=2, Trial, STEP=3, correction, and so on. 
# IBRION = 3 ; Damped MD. Supply SMASS and POTIM

# ISIF = 2 ; Move atoms only
# ISIF = 3 ; Move atoms, change unit cell shape and volume
# ISIF = 5 ; Cell shape only
# ISIF = 6 ; Cell shape and volume
# ISIF = 7 ; Cell volume only

recipe[1]="IBRION = 1
POTIM = 0.15
ISIF = 7 
NSW = 3"

recipe[2]="IBRION = 1
POTIM = 0.15
ISIF = 5 
NSW = 3"

recipe[3]="IBRION = 2
POTIM = 0.15
ISIF = 2
NSW = 7"

recipe[4]="IBRION = 1
POTIM = 0.15
ISIF = 6 
NSW = 5"

recipe[5]="IBRION = 2
POTIM = 0.15
ISIF = 3 
NSW = 9"

recipes=5

for id in ` seq ${recipes} `
do
    recipefolder="recipe-${id}"
    echo "Cooking up ===> " "${recipefolder}"
    echo "${recipe[$id]}"

    # OK, make a sub folder
    mkdir "${recipefolder}"
    # Construct the full INCAR
    cat INCAR > "${recipefolder}/INCAR"
    echo "${recipe[$id]}" >> "${recipefolder}/INCAR"
    # Copy KPOINTS, POTCAR, POSCAR
    cat POSCAR > "${recipefolder}/POSCAR"
    cat KPOINTS > "${recipefolder}/KPOINTS"
    cp -a POTCAR "${recipefolder}/POTCAR"

    # OK; now run vasp!
    cd "${recipefolder}"
    echo "Here goes VASP!"
    "${VASP}"
    echo "VASP finished (or crashed... =)"
    # recycle CONTCAR --> POSCAR for next round
    cp -a CONTCAR ../POSCAR
    cd -
done
