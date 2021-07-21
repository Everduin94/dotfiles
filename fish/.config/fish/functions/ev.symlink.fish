function ev.symlink 

    set source $argv[1]
    set target $argv[2]
    mv $target $source
    ln -s $source $target
	
 end