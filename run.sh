source $HOME/mailinabox-extend/miab-extend.sh
source $HOME/mailinabox-extend/miab.sh

cd $HOME/mailinabox
setup/start.sh

cd $HOME/mailinabox-extend
bash spreedme.sh
bash collabora.sh
bash fixes.sh

