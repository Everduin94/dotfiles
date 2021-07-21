function ev.func
	set fileName ev.$argv.fish
	set filePath ~/.config/fish/functions/$fileName
	if test ! -s $filePath
		echo "I am a new file: populating content!"
		printf "function ev.%s \n\t\n end" $argv > $filePath
		code $filePath
	end

	code $filePath
end
