if status is-interactive
	# Add the personal bin to path if it exists
	if [ -d "$HOME/bin" ] 
		set PATH "$HOME/bin:$PATH"
	end

	# If this is in WSL, change some things
	if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ]
		set BROWSER wslview
	end

	if [ -d "/home/linuxbrew/.linuxbrew/bin" ]
		set PATH "$PATH:/home/linuxbrew/.linuxbrew/bin"
	else
		echo "Missing homebrew"
	end

	set -gx VISUAL nvim
	set -gx EDITOR $VISUAL

	# Add custom keybinds
	bind \b backward-kill-word

	# Commands to run in interactive sessions can go here
	function prof
		edit ~/.config/fish/config.fish
	end

	function funcdel
		set -l fun_name $argv[1]
		set -l fun_file ~/.config/fish/functions/{$fun_name}.fish

		functions --erase $fun_name
		if test -e $fun_file
			rm $fun_file
		end
	end

	function cdd
		cd ..
	end

	function cdh
		cd ~/$argv[1]
	end

	function edit
		sensible-editor $argv[1]
	end

	function reload
		source ~/.config/fish/config.fish
	end

	function reloadall
		set -l fundir ~/.config/fish/personal_functions

		# Load the functions from the "personal_functions" folder
		if test -d $fundir
			echo the folder exists
			for file in $fundir/*.fish
				echo running $file
				fish {$file}
			end
		end
	end

	function cx
		chmod +x $argv[1]
	end
	
	# APT aliases
	function sai
		sudo apt-get install $argv[1]
	end
	function saiy
		sudo apt-get install -y $argv[1]
	end
	function sau
		sudo apt-get update
	end

	# Git
	function gph
		git push $argv
	end
	function gpl
		git pull $argv
	end
	function gf
		git fetch $argv
	end
	function gs
		git status $argv
	end
	function gas
		git add "*" $argv
	end
	function gcp
		git checkout $argv[1] && git pull
	end
	function gcb
		git checkout -b $argv
	end
	function gcm
		git commit -m $argv
	end
	function gcam
		git add "*" && git commit -m $argv
	end
	function gca
		git commit --amend --no-edit
	end
	function gcaa
		git add "*" && git commit --amend --no-edit
	end
	function gbclean
		set -l ignore dev qa prod main master
		set -l branches (git branch --merged)
		for branch in $branches
			set -l trimmed (string trim $branch)
			if string match -q '*' $trimmed
				continue
			end
			if contains $trimmed $ignore
				continue
			end
			git branch -D $trimmed
		end
	end
	function gblist
		git branch --list $argv
	end
	function glog
		git log --graph --oneline --decorate $argv
	end
	function gtree
		git log --graph --oneline --all
	end
	function gr
		git rebase HEAD~$argv[1]
	end
	function gri
		git rebase -i HEAD~$argv[1]
	end
	function grom
		git fetch && git rebase origin/main
	end
	function gsm
		git switch -
	end

end

