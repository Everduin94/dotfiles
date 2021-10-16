function ev.main-sync 
    	
     set dirPath ~/Documents/dev/cx-cloud-ui-worktree/main
     cd $dirPath
     bash --login
     git pull -r upstream main
     npm ci

 end
