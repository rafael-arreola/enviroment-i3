#!/bin/sh

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

install_script () {
    user="$(id -un 2>/dev/null || true)"
    sh_c='sh -c'
    if [ "$user" != 'root' ]; then
		if command_exists sudo; then
			sh_c='sudo -E sh -c'
		elif command_exists su; then
			sh_c='su -c'
		else
			cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
			exit 1
		fi
	fi
	rm -rf ~/.i3
	cp -r i3 ~/.i3
	xdotool key super+shift+r # Reload I3
	$sh_c 'cp ./systemd/numlock /usr/local/bin/numlock'
	$sh_c 'cp ./systemd/numlock.service /etc/systemd/system/numlock.service'
	
	$sh_c 'pacman --remove palemoon-bin'
	$sh_c 'pacman -S --noconfirm firefox numlockx'
	
	echo "###################################################"
	echo "##########          Dependencies         ##########"
	echo "###################################################"
	$sh_c 'pacman -S --noconfirm zip unzip unrar nautilus calibre rofi'
    
	echo "###################################################"
	echo "##########        Configure Audio        ##########"
	echo "###################################################"
	$sh_c 'pacman -S --noconfirm alsa-utils paprefs pavucontrol'

	echo "###################################################"
	echo "##########    Configure dev enviroment   ##########"
	echo "###################################################"
	$sh_c 'pacman -S --noconfirm git zsh libsecret gnome-keyring'
	yay -S --noconfirm visual-studio-code-bin datagrip alacritty
	
	# cat ssh/bash_settings >> ~/.zshrc
	
	
	cp /etc/xdg/autostart/{gnome-keyring-secrets.desktop,gnome-keyring-ssh.desktop} ~/.config/autostart/
	sed -i '/^OnlyShowIn.*$/d' ~/.config/autostart/gnome-keyring-secrets.desktop
	sed -i '/^OnlyShowIn.*$/d' ~/.config/autostart/gnome-keyring-ssh.desktop
	git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
	git config core.fileMode false

	echo "###################################################"
	echo "##########              ZSH              ##########"
	echo "###################################################"
	$sh_c 'rm -rf ~/.oh-my-zsh'
	$sh_c 'rm -rf ~/.zshrc'
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	cat ssh/gnome-keyring-daemon >> ~/.zshrc
	
	echo "###################################################"
	echo "##########          NVM & SDKMAN         ##########"
	echo "###################################################"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
	
	echo -e 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc	
	echo -e '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
	echo -e '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc

	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

	curl -s "https://get.sdkman.io" | bash
	source "$HOME/.sdkman/bin/sdkman-init.sh"

	nvm install 12
	sdk install java 8.0.252.j9-adpt
	sdk install gradle 6.4.1
	npm install -g yarn


	echo -e 'export REACT_EDITOR=code' >> ~/.zshrc
	echo -e 'export TERM=xterm-256color' >> ~/.zshrc
	echo -e 'export JAVA_HOME=$HOME/.sdkman/candidates/java/current/' >> ~/.zshrc
	echo -e 'export GRADLE_HOME=$HOME/.sdkman/candidates/gradle/current/' >> ~/.zshrc
	echo -e 'export PATH="$PATH:$(yarn global bin)"' >> ~/.zshrc
	echo -e 'export PATH="$PATH:$JAVA_HOME/bin"' >> ~/.zshrc
	echo -e 'export PATH="$PATH:$GRADLE_HOME/bin"' >> ~/.zshrc

	echo "###################################################"
	echo "##########            RUST LANG          ##########"
	echo "###################################################"
	sh -c 'curl https://sh.rustup.rs -sSf | sh -s -- -y'

	echo ""
	echo ""
	echo ""
	echo "Please add 'zsh-autosuggestions zsh-syntax-highlighting' on plugins into ~/.zshrc "

}

install_script
