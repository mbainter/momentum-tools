# What is Multitail #

> [MultiTail](http://www.vanheusden.com/multitail/) lets you view one or multiple files like the original tail program. The difference is that it creates multiple windows on your console (with ncurses). It can also monitor wildcards: if another file matching the wildcard has a more recent modification date, it will automatically switch to that file. That way you can, for example, monitor a complete directory of files. Merging of 2 or even more logfiles is possible. It can also use colors while displaying the logfiles (through regular expressions), for faster recognition of what is important and what is not.

# Useful Commandline Examples #

## Singlenode ##

    # Streaming view of mail traffic on a singlenode system
    % multitail -CS momentum -i /var/log/ecelerity/mainlog.ec -I /var/log/ecelerity/bouncelog.ec -i /var/log/ecelerity/rejectlog.ec -i /var/log/ecelerity/paniclog.ec

## Cluster ##

    # Streaming view of mail traffic on a cluster manager for a given <node>
    % multitail -CS momentum -i /var/log/eccluster/`date +%Y/%m/%d`/mainlog/default/<node> -I /var/log/eccluster/`date +%Y/%m/%d`/bouncelog/default/<node> -i /var/log/eccluster/`date +%Y/%m/%d`/rejectlog/default/<node> -i /var/log/eccluster/`date +%Y/%m/%d`/paniclog/default/<node>
    

# Configuration Snippets #

## Color Scheme ##

### Scheme Identification ###
    colorscheme:momentum:http://messagesystems.com/
    scheme:momentum:/var/log/ecelerity/(mainlog|rejectlog|bouncelog).ec
    scheme:momentum:/var/log/eccluster/[0-9/]+/(mainlog|rejectlog|bouncelog)/.*

### General Color Matching ###
    # Mark Receptions and Deliveries in green
    cs_re_s:green:^[0-9]+@([-0-9A-F/]+)@([-0-9A-F/]+)@([-0-9A-F/]+)@(R|D)@.*
    # Mark transfers between nodes in a cluster with underlined blue
    cs_re_s:blue,,underline:^[0-9]+@([-0-9A-F/]+)@([-0-9A-F/]+)@([-0-9A-F/]+)@(X)@.*
    # Mark Transfails in Yellow
    cs_re_s:yellow:^[0-9]+@([-0-9A-F/]+)@([-0-9A-F/]+)@([-0-9A-F/]+)@(T)@.*
    # Mark Permfails in Red
    cs_re_s:red:^[0-9]+@([-0-9A-F/]+)@([-0-9A-F/]+)@([-0-9A-F/]+)@(P)@.*
    # Mark Bounces in Magenta
    cs_re_s:magenta:^[0-9]+@([-0-9A-F/]+)@([-0-9A-F/]+)@([-0-9A-F/]+)@(B)@.*



### 'R' log entries ###

    # Mark binding to the default binding in red
    cs_re_s:red:^[-0-9A-F@/]+R@[^@]+@[^@]+@[^@]+@[^@]+@[0-9\.]+@[0-9]+@[^@]+@(default)@(default)
    # Highlight important destination domains
    cs_re_s:,,bold:^[-0-9A-F@/]+R@[^@]+@((gmail|aol|hotmail|yahoo)\.[^@]+)@.*
    # Highlight important sender domains
    cs_re_s:,,bold:^[-0-9A-F@/]+R@[^@]+@[^@]+@[^@]+@((mycorpdomain|mysitedomain)\.[^@]+)@.*
    # Highlight messages greater than 50k in size
    cs_re_s:red:^[-0-9A-F@/]+R@[^@]+@[^@]+@[^@]+@[^@]+@[0-9\.]+@(([0-9]{2,}|[5-9])[0-9]{4,})@.*

### 'D', 'T' and 'P' log entries ###
    # Mark binding to the default binding in red
    cs_re_s:red:^[-0-9A-F@/]+[DTP]@[^@]+@[0-9]+@(default)@(default)@.*
    # Mark retries under 2 in green, 2-5 in yellow, others in red
    # Deliveries
    cs_re_val_less:green:3:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@([0-9]+)@.*
    cs_re_val_less:yellow:6:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@([0-9]+)@.*
    cs_re_val_bigger:red:5:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@([0-9]+)@.*
    # Failures
    cs_re_val_less:green:3:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+)@.*
    cs_re_val_less:yellow:6:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+)@.*
    cs_re_val_bigger:red:5:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+)@.*
    # Mark messages less than 5 seconds in the queue in green. 
    cs_re_val_less:green:5:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+\.[0-9]+)@.*
    cs_re_val_less:green:5:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+\.[0-9]+)@.*
    # Less than 59 seconds in yellow
    cs_re_val_less:yellow:60:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+\.[0-9]+)@.*
    cs_re_val_less:yellow:60:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@([0-9]+\.[0-9]+)@.*
    # More than 59 seconds in red
    cs_re_val_bigger:red:59:^[-0-9A-F@/]+[D]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@[0-9]+@([0-9]+\.[0-9]+)@.*
    cs_re_val_bigger:red:59:^[-0-9A-F@/]+[TP]@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@[0-9]+@([0-9]+\.[0-9]+)@.*

### 'T' and 'P' log entries ###
    # Flag AOL Suspensions
    cs_re_s:yellow:^[-0-9A-F@/]+T@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@[0-9\.]+@[0-9\.]@([0-9]+\ [0-9\.]+\ \:\ ([^\)]+) http://postmaster.info.aol.com/.*)
    cs_re_s:red:^[-0-9A-F@/]+P@[^@]+@[0-9]+@[^@]+@[^@]+@[0-9]+@[0-9\.]+@[0-9\.]@([0-9]+\ [0-9\.]+\ \:\ ([^\)]+) http://postmaster.info.aol.com/.*)

### Rejectlog Entries ###
    cs_re_s:green:^[0-9]+: R=[^ ]+ L=[^ ]+ C=[^ ]+ .*([internal\] discarded by policy)
    cs_re_s:yellow:^[0-9]+: R=([^ ]+) L=[^ ]+ C=[^ ]+ .*\] (relaying denied)
    cs_re_s:red:^[0-9]+: R=[^ ]+ L=[^ ]+ C=[^ ]+ .* CTXMESS=\[([^\]])\][ ]+(mail loop detected)

### 'B' log entries
    # Flag default bindings
    cs_re_s:red:^[-0-9A-F@/]+B@[^@]+@[^@]+@[^@]+@[^@]+@(default)@(default)
    # Flag bounces caused by policy or manual failing
    cs_re_s:green:^[-0-9A-F@/]+(B)@[^@]+@[^@]+@[^@]+@[^@]+@[^@]+@[^@]+@[0-9]+@(25)@.*
    # Flag unsubscribe requests and timeouts
    cs_re_s:magenta:^[-0-9A-F@/]+(B)@[^@]+@[^@]+@[^@]+@[^@]+@[^@]+@[^@]+@[0-9]+@(24|90)@.*
    # Flag bounces for attachment filtering and relaying controls and unknown reasons
    cs_re_s:yellow:^[-0-9A-F@/]+(B)@[^@]+@([^@]+)@[^@]+@[^@]+@[^@]+@[^@]+@[0-9]+@(53|54|40)@.*
    # Flag bounces due to mail/spam blocking
    cs_re_s:red:^[-0-9A-F@/]+(B)@[^@]+@([^@]+)@[^@]+@[^@]+@[^@]+@[^@]+@[0-9]+@(50|51|52)@.*

