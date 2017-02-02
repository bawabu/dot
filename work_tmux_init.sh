#!/bin/bash
SESSION='work'
EDI_DIR='workdir && cd slade360'
POID_DIR='workdir && cd poid/sil-provider-portal'

# create session
tmux -2 new-session -d -s $SESSION

# create window for edi code
tmux new-window -t $SESSION:0 -n 'code'
tmux select-pane -t 0
tmux send-keys "$EDI_DIR && vim" C-m

# create window for slade360
tmux new-window -t $SESSION:1 -n 'slade360'
tmux select-pane -t 0
tmux send-keys "$EDI_DIR && workon slade360 && . env/provider.env" C-m

# create window for poid
tmux new-window -t $SESSION:2 -n 'poid'
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "$POID_DIR && . env/provider.env && npm run build" C-m
tmux split-window -v
tmux select-pane -t 1
tmux send-keys "$POID_DIR && . env/provider.env && npm run start-dev" C-m
tmux select-pane -t 2
tmux send-keys "$POID_DIR && . env/payer.env && npm run build" C-m
tmux split-window -v
tmux select-pane -t 3
tmux send-keys "$POID_DIR && . env/payer.env && npm run start-dev" C-m

# create window for authserver
tmux new-window -t $SESSION:3 -n 'authserver'
tmux select-pane -t 0
tmux send-keys "workon auth-server && export AUTH_SERVER_DEBUG=true && authserver_manage runserver 9000" C-m

# default window
tmux select-window -t $SESSION:0

# attach to session
tmux -2 attach-session -t $SESSION
