cat <<EOF

The Xilinx ML Suite git repository is cloned in ~/ml-suite

For more information, please see:
    https://github.com/Xilinx/ml-suite/tree/master/examples/classification

- The ml-suite conda environment has already been set up activated
- By using this environment you agree to the terms of the Anaconda EULA:
    /opt/anaconda2/LICENSE.txt

EOF

source activate ml-suite

# symlink fix
if [ "$PWD" = "/usr/src/ml-suite/examples/classification" ]; then
    cd
    cd ml-suite/examples/classification
fi

    
