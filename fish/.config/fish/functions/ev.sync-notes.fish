function ev.sync-notes
    # To make this function cross-machine compatible, add prompt for file path, export var.

     set dirPath ~/Documents/dev/notes
     set fileName inbox.md
     cd $dirPath
     git pull origin master
     set cardNames (curl 'https://api.trello.com/1/lists/60ff3f53e417325df584cf73/cards?fields=name&key=22c37678f9ab7cec6b6c1e9cf982fac8&token=14803be4874efa2bc22852f211fde90e3af27d58601d12fbdf5474993403e836' | jq 'map("- [ ] " + .name) | join("\n")')

     # Hack: I tried quite a few different ways and couldn't get an intial new line to work :(
     printf \n >> $fileName
     printf $cardNames | tr -d \" >> $fileName

     git add .
     git commit -m "Inbox Sync: Pushing to remote"
     git push origin master

    curl --request POST \
        --url 'https://api.trello.com/1/lists/60ff3f53e417325df584cf73/archiveAllCards?key=22c37678f9ab7cec6b6c1e9cf982fac8&token=14803be4874efa2bc22852f211fde90e3af27d58601d12fbdf5474993403e836'

    # Sync dotfiles 
    cd ~/dotfiles
    git add .
    git commit -m "Dotfiles Sync: Pushing to remote"
    git push origin main
    cd $dirPath
 end