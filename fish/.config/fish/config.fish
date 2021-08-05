if status is-interactive
  set PATH $PATH /usr/local/opt/ruby/bin 
  set PATH $PATH /usr/local/lib/ruby/gems/3.0.0/bin
  set PATH $PATH $HOME/.gem/ruby/3.0.0/bin
  status --is-interactive; and source (rbenv init -|psub)
end
