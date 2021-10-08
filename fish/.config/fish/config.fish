if status is-interactive
  set PATH $PATH /usr/local/opt/ruby/bin 
  set PATH $PATH /usr/local/lib/ruby/gems/3.0.0/bin
  set PATH $PATH $HOME/.gem/ruby/3.0.0/bin
  status --is-interactive; and source (rbenv init -|psub)
end

# My Variables
set ws_athena_playground $HOME/Documents/dev/cx-cloud-ui-clone/cx-cloud-ui/apps/athena-playground
set ws_cx_cloud_ui $HOME/Documents/dev/cx-cloud-ui/apps/cx-portal
set ws_erxk_playground $HOME/Documents/dev/erxk-article-playground
set ws_notes $HOME/Documents/dev/notes

# Fix TMUX Issue?
set -x SHELL /bin/bash
