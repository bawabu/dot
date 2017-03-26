#!/bin/bash

# CONSTANTS
EDI_DIR='workdir && cd slade360'
INTEGRATION_DIR='workdir && cd integration-services'
POID_DIR='workdir && cd poid/sil-provider-portal'


# FUNCTIONS

function edi {
    local SESSION=$1
    local START_EDI_SERVER='gunicorn --bind 127.0.0.1:8000 sil_edi.config.wsgi --access-logfile - --error-logfile - --log-level info --timeout 300 --graceful-timeout 300'

    # create session
    tmux -2 new-session -d -s $SESSION

    # create window for edi server
    tmux new-window -t $SESSION:0 -n 'edi'
    tmux select-pane -t 0
    tmux send-keys "$EDI_DIR && workon slade360 && . env/provider.env && $START_EDI_SERVER" C-m


    # create window for poid
    tmux new-window -t $SESSION:1 -n 'poid'
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
    tmux new-window -t $SESSION:2 -n 'authserver'
    tmux select-pane -t 0
    tmux send-keys "workon auth-server && export AUTH_SERVER_DEBUG=true && authserver_manage runserver 9000" C-m
    
    # default window
    tmux select-window -t $SESSION:0
    
    # attach to session
    tmux -2 attach-session -t $SESSION
}

function integration {
    local SESSION=$1
    local START_EDI_SERVER='gunicorn --bind 127.0.0.1:8090 sil_edi.config.wsgi --access-logfile - --error-logfile - --log-level info --timeout 300 --graceful-timeout 300'

    # create session
    tmux -2 new-session -d -s $SESSION

    # create window for edi server
    tmux new-window -t $SESSION:0 -n 'edi'
    tmux select-pane -t 0
    tmux send-keys "$EDI_DIR && workon slade360 && . env/provider.env && $START_EDI_SERVER" C-m

    # create window for authserver
    tmux new-window -t $SESSION:1 -n 'authserver'
    tmux select-pane -t 0
    tmux send-keys "workon auth-server && export AUTH_SERVER_DEBUG=true && authserver_manage runserver 9000" C-m

    # create window for integration
    tmux new-window -t $SESSION:2 -n 'integration'
    tmux select-pane -t 0
    tmux send-keys "$INTEGRATION_DIR && workon integration-services && . .env && ./manage.py runserver" C-m
    
    # default window
    tmux select-window -t $SESSION:2
    
    # attach to session
    tmux -2 attach-session -t $SESSION
}

case $1 in
    edi)
        edi slade360
        ;;
    integration)
        integration integration-services
        ;;
    *)
        echo choose either edi or integration
        ;;
esac
