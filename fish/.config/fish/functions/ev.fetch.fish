function ev.fetch 
	git checkout main
    git fetch upstream
    git merge upstream/main
 end